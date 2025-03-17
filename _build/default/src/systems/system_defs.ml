
open Ecs

module Collision_system = System.Make(Collision)
(* Use a functor to define the new system *)


module Move_system = System.Make(Move)
(* Use a functor to define the new system *)


module Draw_system = System.Make(Draw)
(* Use a functor to define the new system *)
