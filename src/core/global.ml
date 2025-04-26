open Component_defs


type phase = 
    Moving of int 
  | Aiming of int 
  | Shooting of int

type resultJeu =
| Victoire of int 
| Egalite 
| Continue

exception Found of int


let getTeam i = 
  let n = i mod (Cst.nbEquipes) in 
  if n = 0 then Cst.nbEquipes
  else n 

let getResultat vers =

  let hash = Hashtbl.create 0 in

  for i = 1 to Cst.nbEquipes do 
    Hashtbl.add hash i false;
  done;
 



  
  List.iter (fun v -> 
   if v#getVie > 0 then 
    begin
      let id = v#getId in 
      let team = getTeam id in
      Hashtbl.replace hash team true;
    end
  ) vers;



  let i = ref 0 in
  let nbTeamAlive = Hashtbl.fold (fun k v acc -> if v then begin i := k; acc + 1 end else acc) hash 0 in
    



  match nbTeamAlive with
  | 0 -> Egalite   
  | 1 -> Victoire !i
  | _ -> Continue
  

let nextPhase p i = 
  match p with 
  | Moving n -> Aiming n 
  | Aiming n -> Shooting n 
  | Shooting n when n = i -> Moving 1 
  | Shooting n -> Moving (n+1)

let phaseStr phase = 
  match phase with 
   | Moving  n -> Printf.sprintf"Le joueur %d bouge" n
   | Aiming  n -> Printf.sprintf"Le joueur %d vise" n
   | Shooting  n -> Printf.sprintf"Les tirs du joueur %d parcourent la carte" n

let joueurActuel phase =
  match phase with 
  | Moving i -> i
  | Aiming i -> i 
  | Shooting i -> i


let rec prochainePhase phase nbJoueurs joueurs = 

  let output = nextPhase phase nbJoueurs in
  let numJoueur = match output with 
  | Moving i -> i 
  | Aiming i -> i 
  | Shooting i -> i 

  in

    
  let v = Classes.getPlayerById numJoueur joueurs in 
  if not(v#isDead) then 
    output else prochainePhase output nbJoueurs joueurs
    
  

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





type fileReturn = 
  | Image of Gfx.surface
  | Text of string


exception Return of fileReturn



let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s




