
open Component_defs
open Rect
open Vector

type typeCase = Air|Terre|Herbe|Mur|Roche|Eau
type typeArme = Arc|Pistolet|Grenade|Bazooka

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
  | Arc    -> Printf.sprintf"Arc : %d munitions" a#getMunitions
  | Pistolet ->  Printf.sprintf"Pistolet : %d munitions" a#getMunitions
  | Grenade  ->  Printf.sprintf"Grenade : %d munitions" a#getMunitions
  | Bazooka    ->  Printf.sprintf"Bazooka : %d munitions" a#getMunitions

let printVers v =
  let pos_str = Printf.sprintf "Position : (%d, %d)" (fst v#getPos) (snd v#getPos) in
  let vie_str = Printf.sprintf "Vie: %d" v#getVie in
  let rec printArmes armes =
    match armes with
    | []        -> ""
    | a :: rest -> Printf.sprintf ", %s%s" (printArme a) (printArmes rest)
  in
  Printf.sprintf "%s, %s%s" pos_str vie_str (printArmes v#getArmes)



  let getVecteurProj t v0 angle ecart = 
    let g = 9.81 in 
    Vector.mult (5.0 *. ecart) (Vector.{x = (Float.cos(angle) *. v0) ; y =  ((-.g) *. t +. Float.sin(angle) *. v0 )})
  
  
let maxi a b =  
    if a > b then a else b


let getResistance typ = 
  match typ with 
  | Air   -> 0
  | Terre -> 10
  | Herbe -> 10
  | Roche -> 30
  | Mur   -> 60
  | Eau   -> Int.max_int

class case (t : typeCase)  =
object 
  val mutable typ = t
  val mutable resistance = getResistance t
  val mutable changing = false

  method changes = changing <- true
  method isChanging = changing
  
  inherit Component_defs.block (false)
  method getTyp = typ
  method getResistance = resistance
  method set t = typ <- t; resistance <- getResistance t
  method setResistance n = resistance <- n
  method takeDamage d =resistance <- resistance - d
end




let distance x1 y1 x2 y2 = 
  let y = Float.abs(y2 -. y1) in
  let x = Float.abs(x2 -. x1)  in

  Float.sqrt(x *. x +. y *. y )


let setMunitions t =
  match t with
  | Arc    -> 16
  | Pistolet -> 8
  | Grenade  -> 3
  | Bazooka    -> 1

let setDegats t =
  match t with
  | Arc    -> 4
  | Pistolet -> 6
  | Grenade  -> 10
  | Bazooka    -> 20

let setZone t =
  match t with
  | Arc    -> 0
  | Pistolet -> 0
  | Grenade  -> 2
  | Bazooka    -> 3


let mapVide height width = 
  let m = Array.init height (fun j -> Array.init width (fun i -> new case Air))  in
  m

let createCase i x y   = 

  let t = 
    match i with 
    | "-1" -> Air
    | "0"  -> Terre
    | "1"  -> Herbe
    | "3"  -> Eau
    | "2"  -> Roche
    | _  -> Mur
  in

  

  new case t
    

let createCase2 i x y images  = 
  let width = Cst.tileWidth in 
  let height = Cst.tileHeight in
  let x_pos = Cst.offsetX  + x*Cst.tileWidth in 
  let y_pos = Cst.offsetY  + y*Cst.tileHeight in
 
  let t = 
    match i with 
    | "-1" -> Air, Texture.white
    | "0"  -> Terre, Image(Hashtbl.find (images) "dirt")
    | "1"  -> Herbe, Image(Hashtbl.find (images) "grass")
    | "3"  -> Eau, Image(Hashtbl.find (images) "water")
    | "2"  -> Roche, Image(Hashtbl.find (images) "rock")
    | _  -> Mur, Image(Hashtbl.find (images) "wall")
  in

  let tex = snd(t) in
  
  let ca = new case (fst(t)) in 
  ca#texture#set tex;
  ca#position#set Vector.{x =float x_pos;y = float y_pos};
  ca#velocity#set Vector.{x = 0.; y = 0.};
  ca#box#set Rect.{width;height};
  ca#mass#set infinity;

 (* Collision_system.(register (ca:>t));
  Move_system.(register (ca:>t));
  Draw_system.(register (ca:>t));  *)

  ca
    



let createMap file height width  = 
  let map = mapVide height width in
  
  let lines = String.split_on_char '\n' file in
  let lines = List.map (fun e -> String.split_on_char ',' e) lines in
  
  

  
  let aux i ligne = if i < height then (List.iteri (fun j c -> map.(i).(j) <- (createCase c j i )) ligne) else () in 



  List.iteri (fun i ligne -> (aux i ligne) ) lines;
  
  
    
  map

class arme (t: typeArme) =
object(self)
  val typ = t
  val mutable munitions = setMunitions t
  val degats = setDegats t
  val zone = setZone t
  method getTyp = typ
  method getMunitions = munitions
  method getDegats = degats
  method getZone = zone
  method setMunitions n = munitions <- n
  method shoot = munitions <- munitions - 1

end

let createAir ()= new case Air 



class projectile ( ar : typeArme) (x1 : float) (y1 : float) (v : Vector.t) (orig : Texture.t) (debut : float) =
object(self)

  inherit block (true) 
  val v0 = Float.sqrt (v.x *. v.x +. v.y *. v.y)
  val arme = ar 
  val vecteur = v 
  val originalTexture = Texture.Color(Cst.red)
  val angle = Vector.getAngle v

  val debutTemps = debut
  

  val posInitiale = Vector.{x = x1; y = y1}

  method getPosInit = posInitiale
  method getDebut = debut

  method getAngl = -.angle
  method getV0 = v0

  method getTexture = originalTexture

  method update t = 
    let t = ((t -.self#getDebut) /. 1000.0) in
   
    let g = 9.81 in 
    let debutPos = self#getPosInit in 
    let h = (float Cst.window_height) -. debutPos.y in 
    let xDebut = debutPos.x in 
    let lastX = (self#position#get).x in 
    let lastY = (float Cst.window_height) -. (self#position#get).y in 

    let alpha = (self#getAngl) in 
    let y = ((-.g *. t*. t)) +.(Float.sin(alpha) *.(self#getV0)*. t) +. h in
    let x = Float.cos(alpha) *. (self#getV0) *. t +. xDebut in

    let dx = x -. lastX in
   
    let dy = -.(y -. lastY) in 
    let v = Vector.{x = dx; y = dy} in
    self#velocity#set (v)

  method hasGravity = 
    match ar with 
    | Pistolet | Bazooka-> false
    | _ -> true
    
end





class map (l : int) (h : int) (f : case array array)  =
object (self)
  val largeur = l
  val hauteur = h
  val file = f
  val mutable layout = f
  method getLargeur = largeur
  method getHauteur = hauteur
  method getFilePath = f
  method getLayout = layout
  method getCase x y = self#getLayout.(x).(y)


  method setLayout x y c = layout.(x).(y) <- c  

  method deletePlatform i j = 
    if (i >=0 && i < self#getHauteur && j >=0 && j < self#getLargeur) then  
      let output = self#getCase i j in 
      
     ( if output#getTyp = Air then None else
      Some output)
  else  None



end

class vers (i : int) (p : float * float) (v : int) (a : arme array) (imag : (string, Gfx.surface) Hashtbl.t) =
object (self)

  inherit block (true)

  val nbArmes = Array.length a
  val mutable vie = v 
  val vieMax = v
  val mutable armes = a
  val mutable facingRight = true
  val mutable dx = 0.0
  val mutable dy = 0.0
  val mutable images = imag
  val id = i 
  val mutable angle = 0
  method isRight = facingRight

  val mutable puissance = 1.0


  method getBox = self#box#get
  method augmentePuissance = 
    
      puissance <- puissance +. 0.1  ;
      if puissance > 1.0 then puissance <- 1.0

  method dimPuissance = 
    puissance <- puissance -. 0.1;
    if puissance < 0.05 then puissance <- 0.05 



  method getPuissance = puissance
  val mutable indiceArme = 0
  method getId = id
  method getVie = vie
  method getArmes = armes
  method getTexture s = Texture.Image(Hashtbl.find images s)
  method setTexture s = 
    self#texture#set (self#getTexture s)
  method getDx = dx 
  method getDy = dy 
  method getVieMax = vieMax
  method drainHealth amount = 
    vie <- maxi 0 (vie - amount);
    if vie <= 0 then (self#setTexture "dead")

  method isDead = vie <= 0
  method getAngle = angle
  method setAngle a = angle <- a

  method setFacingRight b = facingRight <- b


  method nextWeapon = indiceArme <- ((indiceArme + 1) mod nbArmes)

  method lastWeapon = indiceArme <- indiceArme -1;
    if indiceArme < 0 then indiceArme <- (nbArmes - 1)
 
  method changeTex s = 
    self#texture#set (self#getTexture s)

  method currentWeapon = armes.(indiceArme)

  method augmenteAngle  = 
    

    angle <- angle + 1;
    if angle > 179 then angle <- 179

  method diminAngle = 
   
    angle <- angle - 1;
    if angle < 0 then angle <- 0

  method moveRight = 
    if not(self#isDead) then begin 
    self#setVx (2.0); 
    self#setFacingRight true;
    self#setAngle 30;
    self#changeTex "idleRight" end

  method moveLeft = 
    if not(self#isDead) then begin 
    self#setVx (-2.0); 
    self#setFacingRight false;
    self#setAngle 150;
    self#changeTex "idleLeft" end

  method getSuffixe = 
    match (self#getAngle / 45) with 
    | 0 -> "right0"
    | 1 -> "right1"
    | 2 -> "left1"
    | 3 -> "left0"
    | _ -> failwith"angle can obly be from 0 to 180"



  method setVie v = vie <- v
  method setArmes l = armes <- l



end

let initListeArmes ( )= 
  [| (new arme Arc) ; new arme Pistolet; (new arme Grenade) ;(new arme Bazooka) |]



let rec getRandomPosition map = 
  let () = Random.self_init() in 
  let i = 1 + Random.int (-1+(map#getHauteur))  in 
  let j = 1 + Random.int (-1+(map#getLargeur)) in 

  if (((map#getLayout).(i).(j))#getTyp = Herbe) &&  (map#getLayout.(i-1).(j))#getTyp = Air
    then 
      (i, j)
  else
    getRandomPosition map
     
  


let initVers id p images =
  let player = new vers id p  100 (initListeArmes ()) images in

  let tex = player#getTexture "idleRight" in

  let width = 19 in 
  let height = 23 in 

  player#texture#set  (tex);
  player#position#set Vector.{x = fst(p); y = snd(p)};
  player#velocity#set Vector.{x = 0.0; y = 0.0};
  player#box#set Rect.{ width;  height};
  player#mass#set 200.;
  player


let initProjectile typeArme p images puissance dt= 
  let tex = match typeArme with 
  | Pistolet -> Texture.Image(Hashtbl.find images "ammo")
  | Arc -> Texture.Image(Hashtbl.find  images "arrow")
  | Grenade -> Texture.Image(Hashtbl.find images "grenade")
  | Bazooka -> Texture.Image(Hashtbl.find images "rocket")
  in

  let width = 10 in 
  let height = 10 in 
  let proje = new projectile typeArme (fst p) (snd p) puissance tex dt in 
  proje#texture#set tex;
  proje#position#set Vector.{x = fst(p); y = snd(p)};
  proje#velocity#set Vector.{x = 0.0; y = 0.0};
  proje#mass#set 150.;
  proje#setRotating true;
  proje#box#set Rect.{width;height};


  proje



let initVers2 id images map = 
  let i, j = getRandomPosition map in 

  let x = float(Cst.offsetX + j*Cst.tileWidth) in 
  let y = float(Cst.offsetY + i*Cst.tileHeight - 30) in

 initVers id (x, y) images

  let isAbovePlatform vers p = 
   
    if p#getTyp = Air then false
    else
    let r1 = vers#box#get in 
    let v1 = vers#position#get in

    let r2 = p#box#get in 
    let v2 = p#position#get in

    let y = float r1.height +. v1.y in 

    y >= v2.y && ((v1.x > v2.x && v1.x < v2.x +. float r1.width)
      || (v1.x < v2.x && v2.x < v1.x +. float r1.width)) && y < (float r2.height +. v2.y)
  
  
let getPlayerById id vers = 
  List.find (fun v -> v#getId = id) vers

exception Return 

let isOnGround vers map =
  try
    for i = 0 to map#getHauteur - 1 do
      for j = 0 to map#getLargeur - 1 do
        let p =  (map#getLayout).(i).(j) in
        if isAbovePlatform vers (map#getLayout).(i).(j) then
          begin 
            
          if p#getTyp = Eau then vers#drainHealth 120;
          raise Exit 
          end
       
      done
    done;
    false  (* Si on arrive ici, c'est qu'on n'a pas trouvé de plateforme *)
  with Exit -> true  (* Si on a levé l'exception Exit, c'est qu'on a trouvé une plateforme *)

let jump vers  plateformes= 
  if (isOnGround vers plateformes) then 

  vers#setVy (-5.0)
else ()

let versGravite vers map = 
  let onGround = isOnGround vers map in 
 
  if  onGround then 
    vers#setVy 0.0
  else
    vers#augmenteVy 0.2;

    ()





let initMap file width height  images = 
  let layout = mapVide height width in 
  (* Creating the layout*)
  let lines = String.split_on_char '\n' file in
  let lines = List.map (fun e -> String.split_on_char ',' e) lines in
  
  let aux i ligne = if i < height then (List.iteri (fun j c -> layout.(i).(j) <- (createCase2 c j i images )) ligne) else () in 

  List.iteri (fun i ligne -> (aux i ligne) ) lines;
 
  new map width height layout






let printLigne ligne = 
  Array.iter (fun c -> Gfx.debug"%s%!" (printCase c)) ligne


let printMap map = 
  Array.iter (fun c -> printLigne c ; Gfx.debug"\n%!") map 




  let getCaseInd c = 
    match c with 
    | Air -> -1
    | Terre -> 0
    | Herbe -> 1
    | Roche -> 2
    | Eau   -> 3
    | Mur   -> 4
  
  (*
  let resetScreen ctx screen = 
    Gfx.set_color ctx (Cst.red);
    Gfx.fill_rect ctx screen 0 0 Cst.window_width Cst.window_height
  *)
  
  
  