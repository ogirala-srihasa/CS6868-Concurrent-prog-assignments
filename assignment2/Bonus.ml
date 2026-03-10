type 'a register_state = {
  value: 'a;
  seq_num : int;
  wr_snapshot: 'a array

}
type 'a t = {
  registers : 'a register_state Atomic.t array;  (* Array of atomic registers *)
  n : int;                         (* Number of registers *)
}

let create _n _init_value = 
  if _n <= 0 then invalid_arg "the size must be a positive integer" else
  let init_snapshot = Array.make _n _init_value in
  let init_state = {value = _init_value; seq_num = 0; wr_snapshot = init_snapshot} in   
  let registers = Array.init _n  (fun _ -> Atomic.make  init_state) in
  {registers = registers; n =  _n}



(** Helper: collect all register values *)
let collect _snapshot = 
  let a = Array.init _snapshot.n (fun i -> Atomic.get _snapshot.registers.(i))in a

let rec scan _snapshot = 
  let a1 = collect _snapshot in
  let a2 = collect _snapshot in
  if(a1 = a2) then 
    Array.map (fun reg -> reg.value) a1
  else
    let changed = Array.make _snapshot.n false in
    let stolen_snapshot = ref None in 
    for i = 0 to (_snapshot.n -1) do
      if(a1.(i).seq_num <> a2.(i).seq_num) then begin
        if(changed.(i) = true) then
          stolen_snapshot := Some a2.(i).wr_snapshot
        else
          changed.(i) <- true
        end
    done;
    match !stolen_snapshot with 
    | Some snap_shot -> snap_shot
    | None -> scan _snapshot
(** Scan using wait-free Gang of Six algorithm *)
let scan _snapshot = 
  let changed = Array.make _snapshot.n false in
  let rec loop a1 = 
    let a2 = collect _snapshot in
    if a1 = a2 then 
      Array.map (fun reg -> reg.value) a1
    else begin
      let stolen_snapshot = ref None in 
      for i = 0 to (_snapshot.n - 1) do
        if a1.(i).seq_num <> a2.(i).seq_num then begin
          if changed.(i) = true then
            stolen_snapshot := Some a2.(i).wr_snapshot
          else
            changed.(i) <- true
        end
      done;
      
      match !stolen_snapshot with 
      | Some snap_shot -> snap_shot
      | None -> loop a2
    end
  in
  loop (collect _snapshot)

let update _snapshot _idx _value = 
  if ( _idx < 0  || _idx >= _snapshot.n ) then invalid_arg "Index is out of range" else
    let _scan = scan _snapshot in 
    let prev_state = Atomic.get _snapshot.registers.(_idx) in
    Atomic.set _snapshot.registers.(_idx) {value = _value; seq_num = ((prev_state.seq_num)+1); wr_snapshot = _scan}

let size _snapshot = _snapshot.n