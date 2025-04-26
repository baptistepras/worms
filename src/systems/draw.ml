open Ecs
open Component_defs


type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255

let getTeam i = 
  let n = i mod (Cst.nbEquipes) in 
  if n = 0 then Cst.nbEquipes
  else n 
 
let displayEquipe ctx screen num color smallFont bigFont=

  let w = 200 in 
  let h = (Cst.window_height -50) / Cst.nbEquipes in 
  let surface = Gfx.create_surface ctx w h in 

  (* On fait les bordures*)
  Gfx.set_color ctx color;

  Gfx.fill_rect ctx surface 0 0 2 h;
  Gfx.fill_rect ctx surface (w-2) 0 2 h;

  Gfx.fill_rect ctx surface 0 (h-2) w 2;
  Gfx.fill_rect ctx surface 0 0 w 2;

  let text1 = Gfx.render_text ctx (Printf.sprintf"Equipe numero %d" (num+1))  bigFont in 

  let global = Global.get () in 
  Gfx.blit ctx surface text1 4 4 ;

  let dy = (h -15) / (Cst.nbJoueurEquipe + 1) in
  let y = ref 30 in 


  let indices = List.init (Cst.nbJoueurEquipe) (fun i -> 1+ num + i*Cst.nbEquipes) in



 List.iter (fun i ->
 
   
    let pl = Classes.getPlayerById i global.vers in 

    let text = match pl#isDead with 
    | true-> Gfx.render_text ctx (Printf.sprintf"Vers %d : Mort" i)  smallFont  
    | _ -> Gfx.render_text ctx (Printf.sprintf"Vers %d : %d/%d P.v"  i pl#getVie pl#getVieMax)  smallFont in 
    Gfx.blit ctx surface text 8 !y;
    y := !y + dy) indices;
    
    
  




  Gfx.blit ctx screen surface 0 (50+num * h)





  let blitEtiquette e (v : Classes.vers) ctx screen = 
    (Gfx.blit ctx screen e (Float.to_int((v#position#get).x +. 7.0)) (Float.to_int(-15.0+.((v#position#get).y) )))
  
  let displayEtiquette etiquette vers ctx screen =
    List.iter2 (fun v e -> blitEtiquette e v ctx screen) vers etiquette
  
   

let resetScreen ctx screen = 
 Gfx.set_color ctx (Cst.black);
  Gfx.fill_rect ctx screen 0 0 Cst.window_width Cst.window_height;
  Gfx.commit ctx
  

let displayEtiquetteEquipe num etiquette  (vers : Classes.vers list) ctx screen = 
  let indices = List.init (Cst.nbJoueurEquipe) (fun i -> 1+ num + i*Cst.nbEquipes) in
  List.iter2 (fun i e ->
    let v = Classes.getPlayerById i vers in
    Gfx.blit ctx screen e (Float.to_int((v#position#get).x +. 7.0)) (Float.to_int(-15.0+.((v#position#get).y) ))
    ) indices etiquette


(*

let displayMap context screen map tileset  = 

    let width = map#getLargeur in
    let height = map#getHauteur in (* Assuming you have a 'height' variable *)
    let blit_tile i j = (* Define a function for blitting *)
        let c = map#getCase i j in

        let ind = getCaseInd c#getTyp in

        if ind <> -1 then 

          let x = Cst.offsetX+ Cst.tileWidth*j in
          let y = Cst.offsetY +  Cst.tileHeight*i in 
          
          Gfx.blit_full context screen tileset (Cst.tileWidth * ind) 0 (Cst.tileHeight-1) (Cst.tileWidth-1) x y 20 20;



      else 
        ()
        in

  
  for i = 0 to height - 1 do
    for j = 0 to width - 1 do
      blit_tile i j (* Call the function for each iteration *)
    done
  done;
  ()
*)

let update _dt el =
  let Global.{window;ctx; images; map;  vers; phaseJeu;font1;font2;equipes;lastDt;bullet} = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in


 

  (*Gfx.blit ctx surface tile 50 50;*)
  Gfx.set_color ctx Cst.white;
 
  Gfx.fill_rect ctx surface 0 0 ww wh;

   Seq.iter (fun (e:t) ->
      
      let pos = e#position#get in
      let box = e#box#get in
      let txt = e#texture#get in
      (*Format.eprintf "%a\n%!" Vector.pp pos;*)
     
      Texture.draw ctx surface pos box txt
      
    ) el;

 
  
  let aiming, num = match phaseJeu with 
  | Aiming i -> true, i
  | _ -> false, -1  in 

  let str = ref(Printf.sprintf"%s" (Global.phaseStr phaseJeu)) in
  
  if aiming then
    begin 
    let pl = Classes.getPlayerById num vers in

    let vect = Vector.fromAngle (pl#getAngle) 100.0 in
    let vect2 = Vector.mult (pl#getPuissance) vect in

    let debutVect = Vector.add (pl#position#get) (Vector.{x = 10.0; y = 12.0}) in 


    let finVect = Vector.sub (Vector.add debutVect vect) (Vector.{x = 20.0; y= 20.0}) in
    let finVect2 = Vector.sub (Vector.add debutVect vect2) (Vector.{x = 20.0; y= 20.0}) in
    
    Gfx.blit ctx surface (Hashtbl.find images "viseur") (Float.to_int finVect.x) (Float.to_int finVect.y);
    Gfx.blit ctx surface (Hashtbl.find images "viseur") (Float.to_int finVect2.x) (Float.to_int finVect2.y);
    
    let armeStr = Classes.printArme (pl#currentWeapon) in 
    str := Printf.sprintf"%s avec %s " (Global.phaseStr phaseJeu) armeStr  ;  
    
   end;
  
  



   
          
    
    Gfx.set_color ctx Cst.black;
    let textImage = Gfx.render_text ctx !str font2 in

    
    Gfx.blit ctx surface textImage 10 10;  
 
 
    let numEquipe = match phaseJeu with 
          | Moving i -> getTeam i
          | Aiming i -> getTeam i
          | Shooting i -> getTeam i

          in

  for i = 0 to Cst.nbEquipes - 1 do 
      begin 
        if i+1 == numEquipe then 
        
      displayEquipe ctx surface i Cst.red font1 font2
      else
      displayEquipe ctx surface i Cst.black font1 font2
    end;
    displayEtiquetteEquipe i (equipes.(i)) vers ctx surface;

    done;
  
 

  match !bullet with 
  | None -> ()
  | Some e -> 
    let angle = Vector.getAngle(e#velocity#get) in 
   let angle =  (angle *. (180.0 /. Float.pi)) in
    Gfx.set_transform ctx (angle) false false;
    let pos = e#position#get in
    let box = e#box#get in
    let txt = e#texture#get in
      (*Format.eprintf "%a\n%!" Vector.pp pos;*)
     
    Texture.draw ctx surface pos box txt;
    Gfx.reset_transform ctx

  

