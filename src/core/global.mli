open Component_defs
(* A module to initialize and retrieve the global state *)

type phase = 
    Moving of int 
  | Aiming of int 
  | Shooting of int


type resultJeu =
| Victoire of int 
| Egalite 
| Continue


val getResultat : Classes.vers list -> resultJeu

val getTeam : int -> int

val nextPhase : phase -> int -> phase 

val prochainePhase : phase -> int -> Classes.vers list -> phase

val phaseStr : phase -> string

val joueurActuel : phase -> int

type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  images: (string, Gfx.surface) Hashtbl.t;
  map : Classes.map;
  vers : Classes.vers list;
  phaseJeu : phase;
  javascript : bool;
  font1 : Gfx.font;
  font2 : Gfx.font;
  equipes : Gfx.surface list array;
  lastDt : float;
  bullet : Classes.projectile option ref
}



val get : unit -> t
val set : t -> unit
