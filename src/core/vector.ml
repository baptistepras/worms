type t = { x : float; y : float }

let add a b = { x = a.x +. b.x; y = a.y +. b.y }
let sub a b = { x = a.x -. b.x; y = a.y -. b.y }

let mult k a = { x = k*. a.x; y = k*. a.y }


let changeX v d = {x = d; y = v.y}

let changeY v d = {x = v.x; y = d}

let toRadians a = (float a) *. (Float.pi /. 180.0)

let fromAngle theta r  = 
  {x = r *. Float.cos (toRadians theta); 
    y = (-1.0 *. r) *. Float.sin (toRadians theta)}


let dot a b = a.x *. b.x +. a.y *. b.y
let norm a = sqrt (dot a a)
let normalize a = mult (1.0 /. norm a) a
let pp fmt a = Format.fprintf fmt "(%f, %f)" a.x a.y

let zero = { x = 0.0; y = 0.0 }
let is_zero v = v.x = 0.0 && v.y = 0.0


let getAngle t = 
  Float.atan2 t.y t.x