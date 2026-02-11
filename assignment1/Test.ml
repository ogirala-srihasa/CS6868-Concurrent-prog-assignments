(* Test.ml
 *
 * Test suite for TreeLock implementation
 * Organized into: Unit Tests, Sequential Tests, and Concurrent Tests
 *)

(** PART 1: UNIT TESTS - Testing Observable Properties **)

(* Test calculate_depth produces correct tree depth *)
let test_calculate_depth () =
  Printf.printf "Unit Test 1: Tree depth calculation...\n%!";
  (* Testing depth calculation for 1 (edge-case) thread *)
  let expected = 0 in 
    let final = TreeLock.get_depth( TreeLock.create 1 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 1 thread = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 1 thread = %d (expected %d)\n%!" final expected;
  (* Testing depth calculation for 2 threads *)
  let expected = 1 in 
    let final = TreeLock.get_depth( TreeLock.create 2 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 2 threads = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 2 threads = %d (expected %d)\n%!" final expected;
  (* Testing depth calculation for 3 threads *)
  let expected = 2 in 
    let final = TreeLock.get_depth( TreeLock.create 3 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 3 threads = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 3 threads = %d (expected %d)\n%!" final expected;
  (* Testing depth calculation for 4 threads *)
  let expected = 2 in 
    let final = TreeLock.get_depth( TreeLock.create 4 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 4 threads = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 4 threads = %d (expected %d)\n%!" final expected;
  (* Testing depth calculation for 5 threads *)
  let expected = 3 in 
    let final = TreeLock.get_depth( TreeLock.create 5 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 5 threads = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 5 threads = %d (expected %d)\n%!" final expected;
  (* Testing depth calculation for 8 threads *)
  let expected = 3 in 
    let final = TreeLock.get_depth( TreeLock.create 8 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 8 threads = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 8 threads = %d (expected %d)\n%!" final expected;
  (* Testing depth calculation for 10 (for a non-power of 2) threads *)
  let expected = 4 in 
    let final = TreeLock.get_depth( TreeLock.create 10 ) in
      if expected = final then Printf.printf "✓ Passed: depth for 10 threads = %d (expected %d)\n%!" final expected
      else Printf.printf " ✗ FAILED: depth for 10 threads = %d (expected %d)\n%!" final expected
  
  

(*Test tree structure properties*)
(* let test_tree_structure () =
  Printf.printf "Unit Test 2: Tree structure properties...\n%!";
   *)

(* Test boundary conditions *)
(* let test_boundary_conditions () =
  Printf.printf "Unit Test 3: Boundary conditions...\n%!";
  failwith "Not implemented" *)


(** PART 2: SEQUENTIAL CORRECTNESS TESTS **)

(* Test single thread can lock/unlock *)
let test_single_thread () =
  Printf.printf "Sequential Test 1: Single thread lock/unlock...\n%!";
  let tree = TreeLock.create 1 in
  let counter = Atomic.make 0 in
  let iterations = 1000 in

  let worker thread_id = 
    for _ = 1 to iterations do
      TreeLock.lock tree thread_id;
      (* critical section *)
      let old_val = Atomic.get counter in
      Domain.cpu_relax ();
      Atomic.set counter (old_val + 1);
      TreeLock.unlock tree thread_id
    done
  in 
  let d1 = Domain.spawn(fun () -> worker 0) in 
  Domain.join d1;
  let final = Atomic.get counter in
  let expected = 1 * iterations in
  if final = expected then
    Printf.printf "  ✓ Passed: counter = %d (expected %d)\n%!" final expected
  else
    Printf.printf "  ✗ FAILED: counter = %d (expected %d)\n%!" final expected

(* Test multiple sequential acquisitions by different threads *)
let test_sequential_acquisitions () =
  Printf.printf "Sequential Test 2: Sequential acquisitions by multiple threads...\n%!";
  let tree = TreeLock.create 8 in
  let counter = Atomic.make 0 in
  let iterations = 1000 in

  let worker thread_id = 
    for _ = 1 to iterations do
      TreeLock.lock tree thread_id;
      (* critical section *)
      let old_val = Atomic.get counter in
      Domain.cpu_relax ();
      Atomic.set counter (old_val + 1);
      TreeLock.unlock tree thread_id
    done
  in 
  for i = 0 to 7 do
    let d1 = Domain.spawn(fun () -> worker i) in 
    Domain.join d1;
  done;
  let final = Atomic.get counter in
  let expected = 8 * iterations in
  if final = expected then
    Printf.printf "  ✓ Passed: counter = %d (expected %d)\n%!" final expected
  else
    Printf.printf "  ✗ FAILED: counter = %d (expected %d)\n%!" final expected

(** PART 3: CONCURRENT CORRECTNESS TESTS **)

let test_n_threads n iterations increments_per_iter = 
  let tree = TreeLock.create n in
  let counter = Atomic.make 0 in

  let worker thread_id =
    for _ = 1 to iterations do
      TreeLock.lock tree thread_id;
      (* Critical section *)
      for k = 1 to increments_per_iter do
        let old_val = Atomic.get counter in
        (* Printf.printf "%d %d \n %!" thread_id old_val; *)
        Domain.cpu_relax ();(* Introduce some delay to test race conditions *)
        Atomic.set counter (old_val + 1);
      done;
      TreeLock.unlock tree thread_id
    done
  in
  (*creating n threads*)
  let domains = List.init n (fun i -> 
    Domain.spawn(fun () -> worker i)
    ) in
    List.iter Domain.join domains;(*waiting for all the threads to finish*)

  let final = Atomic.get counter in
  let expected = n * iterations * increments_per_iter in
  if final = expected then
    Printf.printf "  ✓ Passed: counter = %d (expected %d)\n%!" final expected
  else
    Printf.printf "  ✗ FAILED: counter = %d (expected %d)\n%!" final expected
(* Test 1: Basic functionality with 2 threads *)

let test_n_threads_no_print n iterations increments_per_iter = 
  let tree = TreeLock.create n in
  let counter = Atomic.make 0 in

  let worker thread_id =
    for _ = 1 to iterations do
      TreeLock.lock tree thread_id;
      (* Critical section *)
      for k = 1 to increments_per_iter do
        let old_val = Atomic.get counter in
        (* Printf.printf "%d %d \n %!" thread_id old_val; *)
        Domain.cpu_relax ();(* Introduce some delay to test race conditions *)
        Atomic.set counter (old_val + 1);
      done;
      TreeLock.unlock tree thread_id
    done
  in
  (*creating n threads*)
  let domains = Array.init n (fun i -> 
    Domain.spawn(fun () -> worker i)
    ) in
    Array.iter Domain.join domains;(*waiting for all the threads to finish*)

  let final = Atomic.get counter in
  let expected = n * iterations * increments_per_iter in
  if final = expected then
    ()
  else
    Printf.printf "  ✗ FAILED: counter = %d (expected %d)\n%!" final expected
let test_two_threads () =
  Printf.printf "Concurrent Test 1: Two threads...\n%!";
  test_n_threads 2 1000 1

(* Test 2: Four threads *)
let test_four_threads () =
  Printf.printf "Concurrent Test 2: Four threads...\n%!";
  test_n_threads 4 1000 1

(* Test 3: Eight threads *)
let test_eight_threads () =
  Printf.printf "Concurrent Test 3: Eight threads...\n%!";
  test_n_threads 8 1000 1

(* Test 4: Non-power-of-two threads (5 threads) *)
let test_five_threads () =
  Printf.printf "Concurrent Test 4: Five threads...\n%!";
  test_n_threads 5 1000 1

(* Test 5: Stress test - multiple increments per critical section *)
let test_stress () =
  Printf.printf "Stress Test: Eight threads with 1000 itereations and 5 increments in Critical section per iteration \n %!";
  test_n_threads 8 1000 5


(* Test 6: Tree structure verification *)
(* let test_structure_verification () =
  failwith "Not implemented" *)

(* Test 7: Performance benchmark *)
let test_performance () =
  (* Lets test the performance by icrementing the counter from 0 to 100000 using different number of threads*)
  for threads = 1 to 5 do
    if(threads <> 3) then begin
      Printf.printf "Measuring time taken by %d threads to increment the counter from 0 to 100000 \n %!" threads;
      let start_time = Unix.gettimeofday() in
        test_n_threads_no_print threads (100000000/threads) 1;
        let end_time = Unix.gettimeofday () in
          Printf.printf "time taken by %d threads = %.3f \n %!"  threads (end_time -. start_time)
    end
  done;
  Printf.printf "Measuring time taken by 8 threads to increment the counter from 0 to 100000 \n %!";
  let start_time = Unix.gettimeofday() in
    test_n_threads_no_print 8 (100000000/8) 1;
    let end_time = Unix.gettimeofday () in
      Printf.printf "time taken by 8 threads = %.3f \n %!" (end_time -. start_time)



(* Main test runner *)
let () =
  Printf.printf "=== TreeLock Test Suite ===\n\n%!";

  TreeLock.print_tree_info (TreeLock.create 8);
  Printf.printf "\n%!";

  (* Unit Tests *)
  Printf.printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n%!";
  Printf.printf "PART 1: UNIT TESTS\n%!";
  Printf.printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n%!";
  test_calculate_depth ();
  Printf.printf "\n%!";
  (* test_tree_structure (); *)
  Printf.printf "\n%!";
  (* test_boundary_conditions (); *)
  Printf.printf "\n%!";

  (* Sequential Tests *)
  Printf.printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n%!";
  Printf.printf "PART 2: SEQUENTIAL CORRECTNESS\n%!";
  Printf.printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n%!";
  test_single_thread ();
  Printf.printf "\n%!";
  test_sequential_acquisitions ();
  Printf.printf "\n%!";

  (* Concurrent Tests *)
  Printf.printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n%!";
  Printf.printf "PART 3: CONCURRENT CORRECTNESS\n%!";
  Printf.printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n%!";
  test_two_threads ();
  test_four_threads ();
  test_eight_threads ();
  test_five_threads ();
  test_stress ();
  (* test_structure_verification (); *)
  test_performance ();

  Printf.printf "\n=== Test Suite Complete ===\n%!"