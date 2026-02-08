let calculate_internal_nodes depth = 
  let rec loop acc i = 
    if i < depth then loop (acc*2) (i+1)
    else acc
  in (loop 1 0) - 1

let () = 
    Printf.printf "%d \n" (calculate_internal_nodes 1);
    Printf.printf "%d \n" (calculate_internal_nodes 2);
    Printf.printf "%d \n" (calculate_internal_nodes 3);
    Printf.printf "%d \n" (calculate_internal_nodes 4);