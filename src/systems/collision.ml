open Ecs
open Component_defs


exception Return of bool

type t = block

let init _ = ()

let rec iter_pairs f s =
  match s () with
    Seq.Nil -> ()
  | Seq.Cons(e, s') ->
    Seq.iter (fun e' -> f e e') s';
    iter_pairs f s'


let iscolliding (e1: block) (e2 : block) = 
  let p1 = e1#position#get in
  let b1 = e1#box#get in
  let p2 = e2#position#get in
  let b2 = e2#box#get in
  let pdiff, rdiff = Rect.mdiff p2 b2 p1 b1 in
  Rect.has_origin pdiff rdiff

let updateCollision (e1 : block) (e2 : block) = 
  if (e1#isImmobile && not(e2#isImmobile) )then 

  let m1 = e1#mass#get in
  let m2 = e2#mass#get in
  if Float.is_finite m1  then begin
    let p1 = e1#position#get in
    let b1 = e1#box#get in
    let p2 = e2#position#get in
    let b2 = e2#box#get in
    let pdiff, rdiff = Rect.mdiff p2 b2 p1 b1 in
    if Rect.has_origin pdiff rdiff then begin
      e1#setTouched;
      let v1 = e1#velocity#get in
      let v2 = e2#velocity#get in
      let pn = Rect.penetration_vector pdiff rdiff in
      let nv1 = Vector.norm v1 in
      let nv2 = Vector.norm v2 in
      let sv = nv1 +. nv2 in
      let n1, n2 =
        if Float.is_infinite m1 then 0.0, 1.0
        else if Float.is_infinite m2 then 1.0, 0.0
        else nv1 /. sv, nv2 /. sv
      in
      let p1 = Vector.add p1 (Vector.mult n1 pn) in
      let p2 = Vector.sub p2 (Vector.mult n2 pn) in
      e1#position#set p1;
      e2#position#set p2;
      let n = Vector.normalize pn in
      let vdiff = Vector.sub v1 v2 in
      let e = 1.0 in
      let inv_mass = (1.0 /. m1) +. (1.0 /. m2) in
      let j = 0.5 *. (Vector.dot (Vector.mult (-.(1.0 +. e)/.inv_mass) vdiff) n) in
      let nv1 = Vector.add v1 (Vector.mult (j/.m1) n) in
      let nv2 = Vector.sub v2 (Vector.mult (j/.m2) n) in
      
       
      e1#velocity#set nv1;
      e2#velocity#set nv2;
    end
  end
else ()






let updateList el liste 
    = 
    Seq.iter  (fun x -> if el <> x then (updateCollision el x) else ())  liste


let update _ el = 
 Seq.iter (fun x -> 
      

     if (x#isImmobile) then updateList x el else ()
       
    )   el