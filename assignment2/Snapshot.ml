(** Atomic Snapshot Implementation using Double-Collect Algorithm *)

(** Type of atomic snapshot object *)
type 'a t = {
  registers : 'a Atomic.t array;  (* Array of atomic registers *)
  n : int;                         (* Number of registers *)
}

let create _n _init_value = 
  if _n <= 0 then invalid_arg "the size must be a positive integer" else
  let registers = Array.init _n  (fun _ -> Atomic.make  _init_value) in
  {registers = registers; n =  _n}



let update _snapshot _idx _value = 
  if ( _idx < 0  || _idx >= _snapshot.n ) then invalid_arg "Index is out of range" else
    Atomic.set _snapshot.registers.(_idx) _value


(** Helper: collect all register values *)
let collect _snapshot = 
  let a = Array.init _snapshot.n (fun i -> Atomic.get _snapshot.registers.(i) ) in a

(** Scan using double-collect algorithm *)
let rec scan _snapshot = 
  let a1 = collect _snapshot in
  let a2 = collect _snapshot in
  if(a1 = a2) then a1 else scan _snapshot

let size _snapshot = _snapshot.n