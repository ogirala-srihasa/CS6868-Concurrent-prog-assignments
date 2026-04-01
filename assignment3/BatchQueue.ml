(** Batch Bounded Blocking Queue

    A bounded blocking queue where enqueue and dequeue operate on
    batches of elements atomically, with strict FIFO fairness and
    head-of-line blocking for both enqueue and dequeue waiters.

    Uses a single mutex with per-waiter condition variables. *)

(** A blocked enqueuer waiting for enough free space. *)
type 'a enq_waiter = {
  items : 'a array;       (** The batch of items this thread wants to enqueue *)
  cond : Condition.t;     (** Private condition variable — signaled when this
                              waiter reaches the head and space may be available *)
}

(** A blocked dequeuer waiting for enough items. *)
type 'a deq_waiter = {
  amount : int;           (** Number of items this thread wants to dequeue *)
  cond : Condition.t;     (** Private condition variable — signaled when this
                              waiter reaches the head and items may be available *)
}

type 'a t = {
  mutex : Mutex.t;
  buffer : 'a Queue.t;                   (** Items currently in the queue *)
  capacity : int;
  enq_waiters : 'a enq_waiter Queue.t;   (** FIFO queue of blocked enqueuers *)
  deq_waiters : 'a deq_waiter Queue.t;   (** FIFO queue of blocked dequeuers *)
}

(** [create capacity] initializes a new queue. Validate capacity, then
    initialize all fields of the ['a t] record. *)
let create _capacity = 
  if _capacity <= 0 then 
  invalid_arg "BatchQueue: capacity of queue must be positive"
  else
    let r = { mutex = Mutex.create (); buffer = Queue.create () ; capacity = _capacity; enq_waiters = Queue.create(); deq_waiters = Queue.create ()} in r


let validate_enq_count q n =
  if n <= 0 then
    invalid_arg "BatchQueue: batch size must be positive";
  if n > q.capacity then
    invalid_arg "BatchQueue: batch size exceeds capacity"

let validate_deq_count q n =
  if n <= 0 then
    invalid_arg "BatchQueue: dequeue count must be positive";
  if n > q.capacity then
    invalid_arg "BatchQueue: dequeue count exceeds capacity"

let free_space q = q.capacity - Queue.length q.buffer

(** [notify q] checks the head of each waiter queue and signals it if
    its request can now be satisfied. Call after every enqueue or dequeue. *)
let notify _q = 
  (let next_enq = Queue.peek_opt _q.enq_waiters in
    match next_enq with
    | Some enqer ->  if Array.length enqer.items <= free_space _q then  Condition.signal enqer.cond else ();
    | None -> ());
  (let next_deq = Queue.peek_opt _q.deq_waiters in
  match next_deq with
  | Some deqer -> if Queue.length _q.buffer >= deqer.amount then Condition.signal deqer.cond else ()
  | None -> ())

(** [enq q items] atomically enqueues all items. Algorithm:
    1. Validate and lock the mutex (use [Fun.protect] for safe unlock).
    2. If [enq_waiters] is non-empty OR not enough free space:
       - Create a waiter, push it to [enq_waiters], and loop on
         [Condition.wait] until this waiter is at the head of
         [enq_waiters] AND there is enough space.
       - Pop self from [enq_waiters].
    3. Push all items into [buffer].
    4. Call [notify]. *)
let enq _q _items = 
  validate_enq_count _q (Array.length _items );
  Mutex.lock _q.mutex;
  Fun.protect ~finally:(fun () -> Mutex.unlock _q.mutex)(fun () -> 
    if Queue.length _q.enq_waiters > 0 || Array.length _items > free_space _q then 
      (let new_enquer = {items = _items; cond = Condition.create () } in
        Queue.push new_enquer _q.enq_waiters;
        while((Queue.peek _q.enq_waiters != new_enquer)  ||( Array.length _items > free_space _q )) do
          Condition.wait new_enquer.cond _q.mutex
        done;
        let _ = Queue.pop _q.enq_waiters in
        for i =  0 to ((Array.length _items) - 1) do
          Queue.push _items.(i) _q.buffer
        done;
        notify _q)
      else
        (for i =  0 to ((Array.length _items) - 1) do
          Queue.push _items.(i) _q.buffer
        done;
        notify _q)   
    )


(** [deq q n] atomically dequeues [n] items. Symmetric to [enq]:
    wait on [deq_waiters] until at head AND enough items available. *)
let deq _q _n = 
  validate_deq_count _q  _n;
  Mutex.lock _q.mutex;
  Fun.protect ~finally:(fun () -> Mutex.unlock _q.mutex)(fun () -> 
    if Queue.length _q.deq_waiters > 0 || _n > Queue.length _q.buffer then 
      (let new_dequer = {amount = _n; cond = Condition.create () } in
        Queue.push new_dequer _q.deq_waiters;
        while((Queue.peek _q.deq_waiters != new_dequer)  ||( _n > Queue.length _q.buffer )) do
          Condition.wait new_dequer.cond _q.mutex
        done;
        let _ = Queue.pop _q.deq_waiters in
        let a = Array.init _n (fun _ ->  Queue.pop _q.buffer) in
        notify _q;
        a)
      else
        (let a = Array.init _n (fun _ ->  Queue.pop _q.buffer) in
        notify _q;
        a)   
    )


(** [try_enq q items] non-blocking enqueue. If no enqueuers are waiting
    ahead AND enough free space, enqueue and return [true]. Otherwise
    return [false] immediately (do not create a waiter). *)
let try_enq _q _items = 
  validate_enq_count _q (Array.length _items );
  Mutex.lock _q.mutex;
  Fun.protect ~finally:(fun () -> Mutex.unlock _q.mutex)(fun () -> 
    if Queue.length _q.enq_waiters > 0 || Array.length _items > free_space _q then false
    else
      (for i =  0 to ((Array.length _items) - 1) do
          Queue.push _items.(i) _q.buffer
        done;
        notify _q;
        true)   
    )


(** [try_deq q n] non-blocking dequeue. If no dequeuers are waiting
    ahead AND enough items, dequeue and return [Some items]. Otherwise
    return [None] immediately (do not create a waiter). *)
let try_deq _q _n = 
  validate_deq_count _q  _n;
  Mutex.lock _q.mutex;
  Fun.protect ~finally:(fun () -> Mutex.unlock _q.mutex)(fun () -> 
    if Queue.length _q.deq_waiters > 0 || _n > Queue.length _q.buffer then None
    else
      (let a = Array.init _n (fun _ ->  Queue.pop _q.buffer) in
        notify _q;
        Some a)   
    )

let size _q =  Queue.length _q.buffer

let capacity _q = _q.capacity