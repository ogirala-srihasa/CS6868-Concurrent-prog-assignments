(** Manual tests for fiber-level Mutex / Condition / Semaphore / Barrier.

    Each test function returns [(ok, msg)] — [ok] is pass/fail, [msg]
    is a short description printed in the report.  Most tests run
    their fibers inside [Sched.run (fun () -> ...)]; remember that the
    scheduler is cooperative unicore, so you'll want [Sched.yield] to
    force interleavings. *)

open Golike_unicore_select

let passed = ref 0
let failed = ref 0

let report name ok msg =
  if ok then begin
    incr passed;
    Printf.printf "[ PASS ] %s — %s\n%!" name msg
  end else begin
    incr failed;
    Printf.printf "[ FAIL ] %s — %s\n%!" name msg
  end

let run_test name f =
  try
    let ok, msg = f () in
    report name ok msg
  with e ->
    incr failed;
    Printf.printf "[ EXN  ] %s — %s\n%!" name (Printexc.to_string e)

(** Test [try_lock] / [unlock] on a single mutex, sequentially. *)
let test_mutex_basic () = 
  let mutex = Mutex.create () in
  let lock1 = Mutex.try_lock mutex in
  Mutex.unlock mutex;
  let lock2 = Mutex.try_lock mutex in
  let lock3 = Mutex.try_lock mutex in
  Mutex.unlock mutex;
  ((lock1 && lock2) && (not lock3), "sequential testing of mutex try_lock, unlock")

(** Test that blocked waiters are served in FIFO order. *)
let func i mutex order =
  Sched.fork(fun () -> 
    Mutex.lock mutex;
    Queue.push i order;
    Mutex.unlock mutex
  )
let test_mutex_fifo () = 
  let mutex =  (Mutex.create ()) in
  let order =  (Queue.create ()) in
  Sched.run(fun() -> 
    Mutex.lock mutex;
    func 1 mutex order;
    func 2 mutex order;
    Sched.yield ();
    Mutex.unlock mutex;
  );
  let pass = ref true in
  for i = 1 to 2 do
    if i <> (Queue.pop order) then  pass := false
  done;
  (!pass, "mutex is following FIFO") 


(** The [Bounded_buffer] module below is PROVIDED — a classic
    Mutex + two-condvar implementation of a bounded FIFO queue.
    Do not modify it; use it in [test_bounded_buffer]. *)

module Bounded_buffer = struct
  type 'a t = {
    m : Mutex.t;
    not_empty : Condition.t;
    not_full : Condition.t;
    buf : 'a Queue.t;
    capacity : int;
  }
  let create capacity = {
    m = Mutex.create ();
    not_empty = Condition.create ();
    not_full = Condition.create ();
    buf = Queue.create ();
    capacity;
  }
  let put b x =
    Mutex.lock b.m;
    while Queue.length b.buf = b.capacity do
      Condition.wait b.not_full b.m
    done;
    Queue.push x b.buf;
    Condition.signal b.not_empty;
    Mutex.unlock b.m
  let get b =
    Mutex.lock b.m;
    while Queue.is_empty b.buf do
      Condition.wait b.not_empty b.m
    done;
    let x = Queue.pop b.buf in
    Condition.signal b.not_full;
    Mutex.unlock b.m;
    x
end

(** Test bounded-buffer throughput — no items lost, no duplicates,
    under multiple concurrent producers and consumers. *)
let test_bounded_buffer () = 
  let buffer = Bounded_buffer.create 6 in
  let allsum = ref 0 in 
  let nitems = ref 0 in
  Sched.run(fun () ->
    (*first producer*)
    Sched.fork(fun () ->
      for i = 1 to 100 do
        Bounded_buffer.put buffer i
      done;
    );
    (*Second producer*)
    Sched.fork(fun () ->
      for i = 1 to 100 do
        Bounded_buffer.put buffer i
      done;
    );
    (*first consumer*)
    Sched.fork(fun () ->
      for i = 1 to 100 do
        allsum := !allsum + Bounded_buffer.get buffer ;
        nitems := !nitems + 1
      done;
    );
    (*Second consumer*)
    Sched.fork(fun () ->
      for i = 1 to 100 do
        allsum := !allsum + Bounded_buffer.get buffer ;
        nitems := !nitems + 1
      done;
    )
  );
  if !nitems <> 200 then (false, "items lost")
  else if !allsum <> 10100 then (false , "some elements got duplicated")
  else (true,"no items lost, no duplicates under multiple producers and consumers")

(** The [Rw_lock] module below is PROVIDED — writer-priority R/W lock.
    Do not modify it; use it in [test_readers_writers]. *)

module Rw_lock = struct
  type t = {
    m : Mutex.t;
    can_read : Condition.t;
    can_write : Condition.t;
    mutable readers : int;
    mutable writer : bool;
    mutable waiting_writers : int;
  }
  let create () = {
    m = Mutex.create ();
    can_read = Condition.create ();
    can_write = Condition.create ();
    readers = 0; writer = false; waiting_writers = 0;
  }
  let read_lock r =
    Mutex.lock r.m;
    while r.writer || r.waiting_writers > 0 do
      Condition.wait r.can_read r.m
    done;
    r.readers <- r.readers + 1;
    Mutex.unlock r.m
  let read_unlock r =
    Mutex.lock r.m;
    r.readers <- r.readers - 1;
    if r.readers = 0 then Condition.signal r.can_write;
    Mutex.unlock r.m
  let write_lock r =
    Mutex.lock r.m;
    r.waiting_writers <- r.waiting_writers + 1;
    while r.writer || r.readers > 0 do
      Condition.wait r.can_write r.m
    done;
    r.waiting_writers <- r.waiting_writers - 1;
    r.writer <- true;
    Mutex.unlock r.m
  let write_unlock r =
    Mutex.lock r.m;
    r.writer <- false;
    if r.waiting_writers > 0 then Condition.signal r.can_write
    else Condition.broadcast r.can_read;
    Mutex.unlock r.m
end

(** Test the R/W exclusion invariants: at most one writer,
    readers and writers never coexist. *)
let test_readers_writers () = 
  let rwlock = Rw_lock.create () in
  let activereaders = ref 0 in
  let activewriters = ref 0 in
  let invariant_violated = ref false in

  let check_invariant () =
    if !activewriters > 1 || (!activewriters = 1 && !activereaders > 0) then
      invariant_violated := true
  in

  Sched.run (fun () ->
    let spawn_reader () =
      Sched.fork (fun () ->
        for _ = 1 to 5 do
          Rw_lock.read_lock rwlock;
          activereaders := !activereaders + 1;
          check_invariant ();
          Sched.yield (); 
          check_invariant ();
          activereaders := !activereaders - 1;
          Rw_lock.read_unlock rwlock;
          Sched.yield () 
        done
      )
    in

    let spawn_writer () =
      Sched.fork (fun () ->
        for _ = 1 to 5 do
          Rw_lock.write_lock rwlock;
          activewriters := !activewriters + 1;
          check_invariant ();
          Sched.yield (); 
          check_invariant ();
          activewriters := !activewriters - 1;
          Rw_lock.write_unlock rwlock;
          Sched.yield () 
        done
      )
    in
    for i = 1 to 6 do
      spawn_reader ();
      spawn_writer ();
      spawn_reader ();
      spawn_reader ();
      spawn_writer ()
    done;
  );
  
  (not !invariant_violated, "R/W lock maintains exclusion invariants")

(** Test reusable N-party barrier: no fiber is more than one round
    ahead of any other across multiple barrier crossings. *)
let test_barrier () = 
  let n = 3 in
  let rounds = 3 in
  let barrier = Barrier.create n in
  
  let counters = Array.make n 0 in
  let violation = ref false in

  Sched.run (fun () ->
    
    for id = 0 to n - 1 do
      Sched.fork (fun () ->
        for r = 1 to rounds do
          counters.(id) <- r;
          for j = 0 to n - 1 do
            if counters.(id) - counters.(j) > 1 then
              violation := true
          done;
          Barrier.wait barrier;
          Sched.yield ()
        done
        
      )
    done
  );
  if !violation then
    (false, "Barrier Failed")
  else if counters.(0) <> rounds || counters.(1) <> rounds || counters.(2) <> rounds then
    (false, "Not all fibers completed all their rounds")
  else
    (true, "Barrier worked perfectly")

(** Test that a semaphore with [k] permits never allows more than
    [k] fibers in the critical section simultaneously. *)
let test_semaphore () = 
  let semaphore = Semaphore.create 6 in
  let cscount = ref 0 in
  let violation = ref false in
  Sched.run(fun () -> 
    let cs s =
      Semaphore.acquire s;
      cscount := !cscount + 1;
      if !cscount > 6 then violation := true;
      Sched.yield ();
      if !cscount > 6 then violation := true;
      cscount := !cscount - 1;
      Semaphore.release s
    in
    for i = 1 to 10 do
      Sched.fork(fun () -> cs semaphore)
    done;
    Sched.yield ()
    );
    if !violation then (false, "semaphore allowed more than capacity")
    else if !cscount <> 0 then (false,"semaphore didnt relase all threads cleanly")
    else (true,"semaphore never allowed more than capacity")

(** Test that [Select.select] picks an already-free mutex in phase 1
    (the fast path). *)
let test_lock_evt_fastpath () = 
  let mutex = Mutex.create () in
  let lock_evt = Mutex.lock_evt mutex in
  let test = ref false in
  Sched.run(fun () -> 
    Select.select [lock_evt];
    test := true
  );
  if !test = false then (false, "select suspended the fiber") 
  else if (Mutex.try_lock mutex) then  (false, "Select didnt acquire the lock")
  else begin
    Mutex.unlock mutex;
    (true, "Select took the fast path")
  end


(** Test [Select.select] over two held mutexes — it should block until
    one is unlocked, then take that case; stale waiter on the other
    mutex must be tolerated. *)
let test_lock_evt_blocking () = 
  let mutex1 = Mutex.create () in
  let mutex2 = Mutex.create () in
  let winner = ref 0 in
  Sched.run(fun () ->
    Mutex.lock mutex1;
    Mutex.lock mutex2;
    Sched.fork(fun () ->
      let lock_evt1 = Select.wrap (fun () -> winner := 1) (Mutex.lock_evt mutex1) in
      let lock_evt2 = Select.wrap (fun () -> winner := 2) (Mutex.lock_evt mutex2) in
      Select.select [lock_evt1;lock_evt2];
      if !winner = 1 then Mutex.unlock mutex1 else  Mutex.unlock mutex2
    );
    Sched.yield ();
    Mutex.unlock mutex1;
    Sched.yield ();
    Mutex.unlock mutex2;
  );
  if !winner <> 1 then (false, "Select failed to pick the unlocked mutex")
  else if not (Mutex.try_lock mutex2) then  (false,"Stale waiter caused mutex2  to remain locked or broke its state")
  else if not (Mutex.try_lock mutex1) then (false, "mutex 1 is not cleanly released")
  else begin  Mutex.unlock mutex1 ;Mutex.unlock mutex2; (true,"Select is blocked until one mutex is unlocked, stale waiter is tolorated") end

(** Test the load-balancer pattern from Lecture 10's [_scratch/test1.ml]:
    many clients race to claim any of several slot mutexes via
    [Select.select] over [lock_evt]. *)
let test_load_balancer () = 
  let slots = Array.init 3 (fun _ -> 0) in
  let occupancy = Array.init 3 (fun _ -> 0) in
  let voilation = ref false in
  let mutexs = Array.init 3 (fun _ -> Mutex.create ()) in
  
  Sched.run(fun () ->
    let lock_evts = [ Select.wrap (fun () -> 0) (Mutex.lock_evt mutexs.(0));
                    Select.wrap (fun () -> 1) (Mutex.lock_evt mutexs.(1)); 
                    Select.wrap (fun () -> 2) (Mutex.lock_evt mutexs.(2))] in
    for client = 1 to 10 do
      Sched.fork(fun () -> 
        let l = Select.select lock_evts in
        if(occupancy.(l) > 0) then voilation := true;
        occupancy.(l) <- occupancy.(l) + 1;
        slots.(l) <- slots.(l) + 1;
        Sched.yield();
        occupancy.(l) <- occupancy.(l) -1;
        if(occupancy.(l) > 0) then voilation := true;
        Mutex.unlock  mutexs.(l);
      )
    done;
    Sched.yield ();
  );
  if !voilation then (false, "Mutual exclusinon violated")
  else if (occupancy.(0) = 1 || (occupancy.(1) = 1 || occupancy.(2) = 1)) then (false,"All locks are not released cleanly")
  else if (slots.(0) + slots.(1) + slots.(2) <> 10) then (false,"All clients are not serviced")
  else (true,"All clients are serviced")


(** Test that [Condition.wait] re-acquires the mutex before returning
    (POSIX semantics). *)
let test_wait_reacquires () = 
  let mutex = Mutex.create () in 
  let condition = Condition.create () in
  let violation = ref false in

  Sched.run(fun () -> 
    Sched.fork(fun () ->
      Mutex.lock mutex;
      Condition.wait condition mutex;
      Sched.yield();
      Mutex.unlock mutex
    );

    Mutex.lock mutex;
    Condition.signal condition;
    Mutex.unlock mutex;

    Sched.yield ();
    violation := Mutex.try_lock mutex;
    if !violation then  Mutex.unlock mutex
  );
  if !violation then (false,"Condition.wait doesnt reacquire mutex before returning")
  else (true,"Condition.wait does reacquire mutex before returning")

let () =
  Printf.printf "=== Manual tests (fiber-level Mutex/Cond/Sem/Bar) ===\n%!";
  run_test "mutex_basic"           test_mutex_basic;
  run_test "mutex_fifo"            test_mutex_fifo;
  run_test "bounded_buffer"        test_bounded_buffer;
  run_test "readers_writers"       test_readers_writers;
  run_test "barrier"               test_barrier;
  run_test "semaphore"             test_semaphore;
  run_test "lock_evt_fastpath"     test_lock_evt_fastpath;
  run_test "lock_evt_blocking"     test_lock_evt_blocking;
  run_test "load_balancer"         test_load_balancer;
  run_test "wait_reacquires"       test_wait_reacquires;
  Printf.printf "\n%d passed, %d failed\n%!" !passed !failed;
  if !failed > 0 then exit 1