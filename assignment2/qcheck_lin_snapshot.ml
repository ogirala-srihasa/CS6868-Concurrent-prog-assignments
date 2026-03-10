(** QCheck-Lin Linearizability Test for Atomic Snapshot

    This test verifies that the atomic snapshot implementation is linearizable
    under concurrent access.

    == Your Task ==

    Implement the QCheck-Lin specification for the atomic snapshot.
    Follow the examples from Lecture 3:
    - qcheck_lin_bounded.ml
    - qcheck_lin_lockfree.ml

    You need to:
    1. Define the Lin API specification module (SnapshotSig)
    2. Specify init() and cleanup() functions
    3. Define the api list using Lin's DSL (val_ combinator)
    4. Generate and run the linearizability test

    == Lin DSL Type Descriptors ==

    The Snapshot.scan function returns 'int array'. Use:
      returning (array int)

    The others are standard and follow the API from the lectures.

    == Expected Result ==

    This test should PASS. The double-collect algorithm ensures linearizability:
    every scan returns a consistent snapshot that corresponds to some actual
    state that existed during the scan operation.
*)

open Lin
(** Lin API specification for Atomic Snapshot*)
module SnapshotSig = struct
  type t =  int Snapshot.t

  (** Create a snapshot with capacity 5 for testing *)
  let init () = 
    let _snapshot = Snapshot.create 5 0 in
    for i = 0 to 4 do
      (* values shouldnt be reapeated in Snapshot*)
      Snapshot.update _snapshot i (i*1)
    done;
    _snapshot

  (** No cleanup needed *)
  let cleanup _ = ()

  (** API description using Lin's combinator DSL:
      - val_ registers a function to test
      - (t @-> ...) describes argument types
      - returning_or_exc means function returns a value OR raises an exception
  *)
  let api =
    [ val_ "update" Snapshot.update (t @-> int_bound 4 @-> int @-> returning_or_exc unit);
      val_ "scan" Snapshot.scan (t @-> returning_or_exc (array int)); ]
end

(** Generate the linearizability test from the specification *)
module Snapshot_domain = Lin_domain.Make(SnapshotSig)

(** Run 1000 test iterations, each with random command sequences *)
let () =
  QCheck_base_runner.run_tests_main [
    Snapshot_domain.lin_test ~count:1000 ~name:"Atomic snapshot linearizability"
  ]