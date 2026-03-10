(** Manual Concurrent Tests for Atomic Snapshot

    These tests verify basic correctness of the snapshot implementation
    using manual concurrent scenarios.

    Each test includes clear expectations - read the comments above each
    test function to understand what behavior is required.
*)

(** Test 1: Sequential operations

    WHAT TO IMPLEMENT:
    - Snapshot.create should initialize n registers with the given value
    - Snapshot.update should set a register to a new value
    - Snapshot.scan should return an array containing all register values

    EXPECTED BEHAVIOR:
    - Create a snapshot with 4 registers initialized to 0
    - Update each register to a different value (10, 20, 30, 40)
    - Scan should return exactly [| 10; 20; 30; 40 |]

    This test should PASS if your basic operations work correctly.
*)
let test_sequential () =
  let _snapshot = Snapshot.create 4 0 in
  for i = 1 to 4 do
    Snapshot.update _snapshot (i-1) (i*10)
  done;
  if(Snapshot.scan _snapshot = [|10;20;30;40|]) then
    Printf.printf "✓ Passed: Sequential test passed \n"
  else Printf.printf "✗ FAILED: Sequential test failed \n"

(** Test 2: Concurrent updates, single scanner

    WHAT TO IMPLEMENT:
    - Snapshot.update must be thread-safe (use Atomic.set, not ref)
    - Multiple threads can update different registers simultaneously

    EXPECTED BEHAVIOR:
    - 4 domains each update their own register 100 times
    - Domain 0 writes values 0..100 to register 0
    - Domain 1 writes values 1000..1100 to register 1, etc.
    - Final scan should see a valid state where:
      * Register 0 has a value between 0 and 100
      * Register 1 has a value between 1000 and 1100
      * Register 2 has a value between 2000 and 2100
      * Register 3 has a value between 3000 and 3100

    This test should PASS if you use Atomic.t correctly (no data races).
*)
let worker thread_id _snapshot _init_value = 
  for i = 1 to 100 do
    Snapshot.update _snapshot thread_id (_init_value + i)
  done
let concurrent_scanner _snapshot = 
  let scan = Snapshot.scan  _snapshot in scan
let test_concurrent_updates () =
  let _snapshot = Snapshot.create 4 0 in
  for i = 1 to 4 do
     Snapshot.update _snapshot (i-1) ((i-1)*1000)
  done;
  let scan = Snapshot.scan _snapshot in
  let domains = List.init 4 (fun i -> Domain.spawn(fun () -> worker i _snapshot scan.(i)) ) in
  let scaner_thread = Domain.spawn(fun () -> concurrent_scanner _snapshot) in
  let s = Domain.join scaner_thread 
  in List.iter Domain.join domains;
  if((0 <= s.(0)) && (s.(0) <= 100) && (1000 <= s.(1)) && (s.(1) <= 1100) && (2000 <= s.(2)) && (s.(2) <= 2100) && (3000 <= s.(3)) && (s.(3) <= 3100)) then
    let s2 = Snapshot.scan _snapshot in
      if(s2 = [|100;1100;2100;3100|]) then 
        Printf.printf "✓ Passed: Concurrent updates test passed \n"
      else
        Printf.printf "✗ FAILED: Concurrent updates test failed \n" 
  else Printf.printf "✗ FAILED: Concurrent updates test failed \n"

(** Test 3: Multiple concurrent scanners - THE CRITICAL TEST FOR DOUBLE-COLLECT

    WHAT TO IMPLEMENT:
    - Snapshot.scan must use the DOUBLE-COLLECT algorithm
    - This ensures every scan returns a LINEARIZABLE (consistent) snapshot

    EXPECTED BEHAVIOR:
    - One updater continuously writes i, i*10, i*100 to registers 0, 1, 2
    - 4 scanner threads each perform 50 scans while updates happen
    - EVERY scan must see a consistent state:
      * The iteration number visible in each register must be non-increasing
        left to right: r0 >= r1/10 >= r2/100
      * Example valid states: [0,0,0], [5,50,500], [23,230,2300]
      * Scans can see partially-written states (registers updated left to right)
      * Example valid states: [5,40,400], [5,50,400]
      * Example INVALID state: [5,50,600] (r2/100=6 > r0=5: never existed!)

    WHY THIS MATTERS:
    - Without double-collect, you might see [5, 50, 600] - a state that
      NEVER actually existed atomically
    - Double-collect guarantees you only see states that truly existed

    This test should PASS (all 200 scans consistent) ONLY if you implement
    the double-collect algorithm correctly. A naive scan will fail here.
*)
let updater_worker  _snapshot ref counter = 
  while (Atomic.get ref) do 
      let i = Atomic.fetch_and_add counter 1 in 
        Snapshot.update _snapshot 0 (i*1);
        Snapshot.update _snapshot 1 (i*10);
        Snapshot.update _snapshot 2 (i*100)
  done

let reader_worker _snapshot =
  let ans = ref true in
  for i = 1 to 50 do
    let scan = Snapshot.scan  _snapshot in
    let _bo = ((scan.(0) >= (scan.(1)/10)) && (scan.(1) >= (scan.(2)/10))) in ans := !ans && _bo;
  done;
  !ans
let test_concurrent_scans () =
  let ref = Atomic.make true in
  let counter = Atomic.make 1 in
  let _snapshot = Snapshot.create 3 0 in
  let updater = Domain.spawn(fun() -> updater_worker _snapshot ref counter) in
  let reader1 = Domain.spawn(fun() -> reader_worker _snapshot) in
  let reader2 = Domain.spawn(fun() -> reader_worker _snapshot) in
  let reader3 = Domain.spawn(fun() -> reader_worker _snapshot) in
  let reader4 = Domain.spawn(fun() -> reader_worker _snapshot) in
  let r1 = Domain.join reader1 in let r2 = Domain.join reader2 in let r3 = Domain.join reader3 in let r4 = Domain.join reader4 in
  Atomic.set ref false;
  let _ = Domain.join updater in
  if((r1 && r2) && (r3 && r4)) then Printf.printf "✓ Passed: Concurrent scans test passed \n"
  else Printf.printf "✗ FAILED: Concurrent scans test failed \n"


(** Test 4: High contention stress test

    WHAT TO IMPLEMENT:
    - Your implementation must handle many threads reading/writing simultaneously
    - No deadlocks, no crashes, no data races

    EXPECTED BEHAVIOR:
    - 8 threads run simultaneously for 1000 iterations each
    - Even-numbered threads write to registers
    - Odd-numbered threads scan continuously
    - Test should complete without hanging or crashing

    This test should PASS if your atomic operations are correct and your
    double-collect handles high contention gracefully.
*)
let islegal _scan = 
  let ans = ref true in
  for i = 0 to 4 do
    for j = (i+1) to 4 do
      if(((_scan.(i))/5000) =  ((_scan.(j))/5000)) then
        begin
        if(((_scan.(i)) mod 1000) <  ((_scan.(j)) mod 1000)) then ans := false
        end
    done
  done;
  !ans

        

let worker_2 _snapshot id = 
  if(id mod 2 = 0) then
    let init_val = (5000 * (id/2)) in
    for j = 1 to 1000 do
      for i = 0 to 4 do
        Snapshot.update _snapshot i (init_val + (i * 1000) + j)
      done
    done;
    true
  else begin
    let ans = ref true in
    for j = 1 to 1000 do
      let _scan = Snapshot.scan _snapshot in
      ans := !ans && (islegal _scan)
    done;
    !ans
  end

    
let test_high_contention () =
  let _snapshot = Snapshot.create 5 0 in
  for i = 0 to 4 do
    (*to make sure all starting points are different*)
    Snapshot.update _snapshot i (i* -1)
  done;
  let domains = List.init 8 (fun j -> Domain.spawn(fun () -> worker_2  _snapshot j)) in
  let results = List.map Domain.join domains in
  let all_passed = List.for_all (fun res -> res = true) results in
  if all_passed then
  Printf.printf "✓ Passed: High contention test passed \n"
  else
  Printf.printf "✗ FAILED: High contention test failed \n" 



(** Main test runner *)
let () =
  test_sequential ();
  test_concurrent_updates ();
  test_concurrent_scans ();
  test_high_contention ();
  Printf.printf "All manual tests passed!\n%!"
