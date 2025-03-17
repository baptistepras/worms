open Ecs
open Component_defs

type t = movable

let init _ = ()

let update _ el =
  Seq.iter (fun (e:t) ->
      let v = e#velocity#get in
      e#position#set Vector.(add v e#position#get)
    ) el
