(** A reusable N-party barrier.

    Standard "sense-reversing" approach using a [round] counter: each
    fiber notes the current round on entry and waits until either the
    barrier trips (round advances) or, if it is the last arrival, trips
    the barrier itself.
*)

type t = {
  m : Mutex.t;
  c : Condition.t;
  n : int;
  mutable arrived : int;
  mutable round : int;
}

let create n = {m = Mutex.create (); c = Condition.create (); n = n; arrived = 0; round = 0} 

let wait b = 
  Mutex.lock b.m;
  if b.arrived = (b.n - 1) then begin
    b.arrived <- 0;
    b.round <- b.round + 1;
    Condition.broadcast b.c;
  end else begin
    b.arrived <- b.arrived +1;
    let round = b.round in
    while round == b.round do
      Condition.wait b.c b.m
    done;
  end;
  Mutex.unlock b.m;
