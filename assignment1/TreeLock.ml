
(* TreeLock.ml
 *
 * Tree-based lock implementation for n-thread mutual exclusion
 * Uses Peterson locks at each internal node of a binary tree
 *)

type t = PetersonNode.t array(* Define this yourself *)

(* Calculate the depth of the tree needed for n threads *)
let calculate_depth n =
  (* Depth = ceiling(log2(n)) *)
  if n <= 0 then invalid_arg "Number of threads must be positive";
  if n = 1 then 1 else begin
    let rec loop i c = 
      if i < n then 
        loop (i*2) (c+1)
      else c in
      loop 1 0
    end

(* Convert thread_id to binary path representation *)
let thread_id_to_path thread_id depth =
  (* Returns array of 0s and 1s representing path from root to leaf *)
  let arr = Array.make depth 0 in 
    (
      let rec loop t i = 
        if i >= depth then ()
        else begin
          arr.(i) <- (t mod 2) ;
          loop (t/2) (i+1)
        end
      in loop thread_id 0
    ); arr


(* Get index of node in array given path from root *)
let path_to_index path level =
  (* Level 0 is root (index 0)
     Left child of i is 2*i + 1
     Right child of i is 2*i + 2 *)
  let rec loop i = 
    if i = 0 then 0
    else (2 * loop (i-1) ) + ( path.(i-1) + 1 )
  in loop level 

(* Helper function to calculate number of internal nodes in a tree of depth d*)
let calculate_internal_nodes depth = 
  let rec loop acc i = 
    if i < depth then loop (acc*2) (i+1)
    else acc
  in (loop 1 0) - 1

let create num_threads =
  let d = calculate_depth num_threads in
    let n = calculate_internal_nodes d in
     let tree = Array.init n (fun _ -> PetersonNode.create()) in
     tree

let lock tree thread_id =
  let path = thread_id_to_path thread_id (calculate_depth (Array.length tree)) in
    let rec loop l = 
      if l = 0 then ()
      else begin
        PetersonNode.lock (tree.(path_to_index path (l-1))) path.(l-1);
        loop (l-1)
      end
    in
    loop ((calculate_depth (Array.length tree))) 

let unlock tree thread_id =
  let d = calculate_depth (Array.length tree) in
    let path = thread_id_to_path thread_id d in
      let rec loop l = 
        if l = d then ()
        else begin
          PetersonNode.unlock (tree.(path_to_index path (l))) path.(l);
          loop (l+1)
        end
      in
      loop 0

(* Additional utility functions for debugging and analysis *)

let get_depth tree =
  calculate_depth (Array.length tree)

let get_num_nodes tree =
  Array.length tree

let print_tree_info tree =
  Printf.printf "the depth of the tree-lock is %d \n" (get_depth tree);
  Printf.printf "number of Peterson Nodes in the tree-lock id %d \n" (get_num_nodes tree)
