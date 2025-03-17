type typeCase = Air|Terre|Herbe|Mur|Roche|Eau

type typeArme = Fusil|Pistolet|Grenade|Bombe

let printCase c = 
  match c#getTyp with 
  | Air   -> "Air"
  | Terre -> "Terre"
  | Herbe -> "Herbe"
  | Mur   -> "Mur"
  | Roche -> "Roche"
  | Eau   -> "Eau"

let printArme a =
  match a#getTyp with
  | Fusil    -> Printf.sprintf"Fusil : %d munitions" a#getMunitions
  | Pistolet ->  Printf.sprintf"Pistolet : %d munitions" a#getMunitions
  | Grenade  ->  Printf.sprintf"Grenade : %d munitions" a#getMunitions
  | Bombe    ->  Printf.sprintf"Bombe : %d munitions" a#getMunitions

let printVers v =
  let pos_str = Printf.sprintf "Position : (%d, %d)" (fst v#getPos) (snd v#getPos) in
  let vie_str = Printf.sprintf "Vie: %d" v#getVie in
  let rec printArmes armes =
    match armes with
    | []        -> ""
    | a :: rest -> Printf.sprintf ", %s%s" (printArme a) (printArmes rest)
  in
  Printf.sprintf "%s, %s%s" pos_str vie_str (printArmes v#getArmes)

let getResistance typ = 
  match typ with 
  | Air   -> 0
  | Terre -> 10
  | Herbe -> 10
  | Roche -> 30
  | Mur   -> 60
  | Eau   -> -1

class case (t : typeCase) =
object 
  val mutable typ = t
  val mutable resistance = getResistance t
  method getTyp = typ
  method getResistance = resistance
  method set t = typ <- t; resistance <- getResistance t
  method setResistance n = resistance <- n
end

let setMunitions t =
  match t with
  | Fusil    -> 16
  | Pistolet -> 8
  | Grenade  -> 3
  | Bombe    -> 1

let setDegats t =
  match t with
  | Fusil    -> 4
  | Pistolet -> 2
  | Grenade  -> 30
  | Bombe    -> 60

let setZone t =
  match t with
  | Fusil    -> 1
  | Pistolet -> 1
  | Grenade  -> 3
  | Bombe    -> 5

class arme (t: typeArme) =
object
  val typ = t
  val mutable munitions = setMunitions t
  val degats = setDegats t
  val zone = setZone t
  method getTyp = typ
  method getMunitions = munitions
  method getDegats = degats
  method getZone = zone
  method setMunitions n = munitions <- n
end

let createAir ()= new case Air 

class map (l : int) (h : int) (file_path : string) =
  object (self)
    val largeur = l
    val hauteur = h
    val file_path = file_path
    val mutable layout = Array.make h (Array.make l (createAir ()) )
    method getLargeur = largeur
    method getHauteur = hauteur
    method getFilePath = file_path
    method getLayout = layout
    method getCase x y = self#getLayout.(x).(y)
    method setLayout x y c = layout.(x).(y) <- c  
  end

class vers (p : int*int) (v : int) (a : arme list) =
object
  val mutable pos = p 
  val mutable vie = v 
  val mutable armes = a
  method getPos = pos
  method getVie = vie
  method getArmes = armes
  method setPos p = pos <- p
  method setVie v = vie <- v
  method setArmes l = armes <- l
end