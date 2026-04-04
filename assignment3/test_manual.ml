(** Manual concurrent tests for Batch Bounded Blocking Queue *)

let printf = Printf.printf

let assert_array_eq a b msg =
  if a <> b then begin
    printf "FAIL: %s\n  expected: [|%s|]\n  got:      [|%s|]\n" msg
      (Array.to_list a |> List.map string_of_int |> String.concat "; ")
      (Array.to_list b |> List.map string_of_int |> String.concat "; ");
    exit 1
  end 
  else begin
    printf "PASS: %s\n  expected: [|%s|]\n  got:      [|%s|]\n" msg
      (Array.to_list a |> List.map string_of_int |> String.concat "; ")
      (Array.to_list b |> List.map string_of_int |> String.concat "; ")
  end


(** Test create, enq, deq, size, capacity in a single thread. *)
let test_sequential_basic () = 
  let bq = BatchQueue.create 6 in 
  if(BatchQueue.capacity bq = 6) then printf "Sequential Capacity check passed \n" else  printf "Sequential Capacity check failed \n";
  BatchQueue.enq bq [|1;2;3;4;5|];
  if(BatchQueue.size bq = 5) then printf "Sequential size check after enq passed \n" else  printf "Sequential size check after enq failed \n";
  let expected = [|1;2|] in
  let actual = BatchQueue.deq bq 2 in
  assert_array_eq expected actual "Sequential deq check";
  if(BatchQueue.size bq = 3) then printf "Sequential size check after deq passed \n" else  printf "Sequential size check after deq failed \n"




(** Test that invalid arguments raise [Invalid_argument]. *)
let test_error_handling () = 
  (try begin
    let _ = BatchQueue.create (-3) in 
    failwith "error handling failed when created a negative capacity queue"
  end
  with 
  | Invalid_argument e -> 
    printf "Success: Caught the expected error: %s\n" e;
  );
  (try begin
    let bq = BatchQueue.create 6 in 
    BatchQueue.enq bq [|1;2;3;4;5;6;7;8|];
    failwith "error handling failed when enqued more elements than capacity"
  end
  with 
  | Invalid_argument e -> 
    printf "Success: Caught the expected error: %s\n" e;
  );
  (try begin
    let bq = BatchQueue.create 6 in 
    BatchQueue.enq bq [|1;2;3;4;5;6|];
    let _ = BatchQueue.deq bq 8 in failwith "error handling failed when dequed more elements than capacity"
  end
  with
  | Invalid_argument e -> 
    printf "Success: Caught the expected error: %s\n" e
  )
  

(** Test that deq blocks until items arrive (and/or enq blocks until space frees). *)
let test_blocking_enq_deq () = 
  let bq = BatchQueue.create 6 in
  let thread1 = Domain.spawn(fun () -> BatchQueue.deq bq 2 )in
  Unix.sleepf 0.1;
  let thread2 = Domain.spawn ( fun () -> BatchQueue.enq bq [|1;2;3;4|]) in let _ = Domain.join thread2 in (); 
  let pitems = Domain.join thread1 in 
  assert_array_eq  [|1;2|] pitems "deq waits until items arrive";
  let thread1 = Domain.spawn(fun () -> BatchQueue.enq bq [|5;6;7;8;9;10|]) in 
  Unix.sleepf 0.1;
  let thread2 = Domain.spawn( fun () -> BatchQueue.deq bq 2 ) in let pitems = Domain.join thread2 in assert_array_eq [|3;4|] pitems "enq waits until there is free space";
  let _ = Domain.join thread1 in ()




(** Test that a single producer/consumer pair sees items in FIFO order. *)
let test_fifo_single_producer_consumer () = 
  let bq = BatchQueue.create 6 in 
  let producer = Domain.spawn (fun () -> 
    BatchQueue.enq bq [|1;2|];
    Unix.sleepf 0.1;
    BatchQueue.enq bq [|3;4;5;6|]
  ) in let consumer = Domain.spawn (fun () -> BatchQueue.deq bq 6) in let _ = Domain.join producer in let pitems = Domain.join consumer in
  assert_array_eq [|1;2;3;4;5;6|] pitems  "single producer/consumer pair sees items in same order"

(** Test dequeuer head-of-line blocking: deq(5) arrives before deq(2);
    even when 6 items are enqueued, deq(5) must be served first. *)
let test_dequeuer_head_of_line_blocking () = 
  let bq = BatchQueue.create 7 in 
  let deq1 = Domain.spawn (fun() -> BatchQueue.deq bq 5) in
  Unix.sleepf 0.1;
  let deq2 = Domain.spawn (fun() -> BatchQueue.deq bq 2) in
  let enq1 = Domain.spawn (fun () -> BatchQueue.enq bq [|1;2;3;4|]) in
  Unix.sleepf 0.1;
  let enq2 = Domain.spawn (fun() -> BatchQueue.enq bq [|5;6;7|]) in let _ = Domain.join enq2 in
  let _ = Domain.join enq1 in let pitems1 = Domain.join deq1 in let _pitems2 = Domain.join deq2 in
  assert_array_eq [|1;2;3;4;5|] pitems1  "dequeuer head of the line test"


(** Test enqueuer head-of-line blocking: enq(3) arrives before enq(1);
    freeing 1 slot must NOT let enq(1) jump ahead. *)
let test_enqueuer_head_of_line_blocking () = 
  let bq = BatchQueue.create 7 in 
  (*queue initailisation*)
  BatchQueue.enq bq [|1;2;3;4;5;6;7|];
  Unix.sleepf 0.1;
  let enq1 = Domain.spawn (fun() -> BatchQueue.enq bq [|8;9;10|]) in
  Unix.sleepf 0.1;
  let enq2 = Domain.spawn (fun() -> BatchQueue.enq bq [|11|]) in
  let deq1 = Domain.spawn (fun () -> BatchQueue.deq bq 2) in
  Unix.sleepf 0.1;
  let deq3 = Domain.spawn (fun () -> BatchQueue.deq bq 5) in let _ = Domain.join deq3 in 
  let deq2 = Domain.spawn(fun () -> BatchQueue.deq bq 3) in
  let _ = Domain.join enq1 in let _pitems1 = Domain.join deq1 in let pitems2 = Domain.join deq2 in let _ = Domain.join enq2 in
  assert_array_eq [|8;9;10|] pitems2  "enqueuer head of the line test"

(** Test that no items are lost or duplicated under concurrent access. *)
let test_no_lost_items () = 
  let arr1 = [|1;2;3;4;5|] in 
  let arr2 = [|6;7;8;9;10|] in
  let bq = BatchQueue.create 10 in
  let deq1 = Domain.spawn (fun() -> BatchQueue.deq bq 5) in
  let deq2 = Domain.spawn (fun() -> BatchQueue.deq bq 5) in
  let enq1 = Domain.spawn (fun () -> BatchQueue.enq bq arr1) in
  let enq2 = Domain.spawn (fun() -> BatchQueue.enq bq arr2) in let _ = Domain.join enq2 in
  let _ = Domain.join enq1 in let pitems1 = Domain.join deq1 in let pitems2 = Domain.join deq2 in
  let pitems = Array.append pitems1 pitems2 in
  Array.sort compare pitems;
  assert_array_eq [|1;2;3;4;5;6;7;8;9;10|] pitems  "no items lost test"

(** Test that a batch enqueue is not interleaved with another batch. *)
let test_batch_atomicity () = 
  let arr1 = Array.init 100 (fun _ -> 1) in 
  let arr2 = Array.init 100 (fun _ -> 2) in
  let bq = BatchQueue.create 200 in
  let enq1 = Domain.spawn (fun () -> BatchQueue.enq bq arr1) in
  let enq2 = Domain.spawn (fun() -> BatchQueue.enq bq arr2) in 
  Unix.sleepf 0.1;
  let deq1 = Domain.spawn (fun() -> BatchQueue.deq bq 200) in
  let _ = Domain.join enq1 in let pitems = Domain.join deq1 in let _ = Domain.join enq2 in
  if(pitems = (Array.append arr1 arr2) || pitems = (Array.append arr2 arr1)) then printf "atomicity test passed \n" else printf "atomicity test faile \n"

let enq_worker i bq = 
  let start = ref (300 * i) in
  for _ = 1 to 100 do
    let arr = [|!start; !start+1;!start +2|] in
    BatchQueue.enq bq arr;
    start := !start + 3
  done


let deq_worker i bq = 
  let arr = ref [||] in
  for _ = 1 to 100 do
    let pitems = BatchQueue.deq bq 3 in
    arr := Array.append !arr pitems
  done;
  !arr

(** Stress test: multiple producers and consumers with many operations. *)
let test_stress () = 
  let bq = BatchQueue.create 10 in
  let enq1 = Domain.spawn (fun () -> enq_worker 0 bq) in
  let enq2 = Domain.spawn (fun () -> enq_worker 1 bq) in
  let enq3 = Domain.spawn (fun () -> enq_worker 2 bq) in
  let deq1 = Domain.spawn (fun () -> deq_worker 0 bq) in
  let deq2 = Domain.spawn (fun () -> deq_worker 1 bq) in
  let deq3 = Domain.spawn (fun () -> deq_worker 2 bq) in
  let _ = Domain.join enq1 in let _ = Domain.join enq2 in let _ = Domain.join enq3 in
  let pitems1 = Domain.join deq1 in let pitems2 = Domain.join deq2 in let pitems3 = Domain.join deq3 in
  let pitems =  Array.append pitems1 (Array.append pitems2 pitems3) in Array.sort compare pitems;
  let expected = Array.init 900 (fun i -> i) in if(pitems = expected) then printf "stress test passed \n" else printf "stress test failed \n"

  


let () =
  test_sequential_basic ();
  test_error_handling ();
  test_blocking_enq_deq ();
  test_fifo_single_producer_consumer ();
  test_dequeuer_head_of_line_blocking ();
  test_enqueuer_head_of_line_blocking ();
  test_no_lost_items ();
  test_batch_atomicity ();
  test_stress ();
  printf "\nAll manual tests passed!\n"