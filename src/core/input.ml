
open System_defs
let nextIdplayer id = 
  match id with 
  | 1 -> 2
  | 2 -> 1
  | _ -> 0

let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s= Hashtbl.replace key_table s ()
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action



let handle_input () =
  let Global.{window;ctx; images; map; vers; phaseJeu;javascript;font1;font2;equipes;lastDt;bullet} = Global.get () in
  let () =
    match Gfx.poll_event () with
      KeyDown "n" ->
      
        let phaseJeu = Global.prochainePhase phaseJeu (Cst.nombreJoueurs) vers in
        Global.set{window; ctx; images; map ; vers; phaseJeu;javascript;font1;font2; equipes;lastDt;bullet}

    | KeyDown "a" -> 
         (match phaseJeu with 
         | Aiming i -> (Classes.getPlayerById i vers )#lastWeapon
         | _ -> ())
    | KeyDown "z" -> 
      (match phaseJeu with 
      | Aiming i -> (Classes.getPlayerById i vers )#nextWeapon
      | _ -> ())
    | KeyDown "space" |KeyDown " "-> 
      (match !bullet with 
      | None -> ()
      | Some b -> 
        let i = (((Float.to_int (b#position#get).y) - Cst.offsetY) / Cst.tileWidth )in
        let j = (((Float.to_int (b#position#get).x) - Cst.offsetX) / Cst.tileHeight ) in
        
        if (0 <= j && j < 55 && i>=0 && i < 30) then 
          
          begin
            let c = map#getCase i j in
            if (c#getTyp = Classes.Air) then 
              begin
                (map#getCase i j)#changes;
               
                
              end;
          end;
      
        ())
    |  KeyDown s -> set_key s
     
   
     
    | KeyUp s -> unset_key s
    | Quit -> exit 0
    | MouseButton(_, b, x, y) -> (
        let i = (x - Cst.offsetX) / Cst.tileWidth in 
        let j = (y - Cst.offsetY) / Cst.tileHeight in 
        match map#deletePlatform j i with
          Some e -> e#disappear
         |  None -> ())
    | _ -> ()
  in
  Hashtbl.iter (fun key action ->
      if has_key key then action ()) action_table;
 
  if javascript then  begin 
    if not(has_key "ArrowLeft") && not(has_key "ArrowRight") then 
      List.iter (fun v -> v#setVx 0.0) vers 
  end
else
  begin 
    if not(has_key "left") && not(has_key "right") then 
      List.iter (fun v -> v#setVx 0.0) vers 

  end
 


 

let getPlayerWhoMoves ()=
  let glob = Global.get() in


  match glob.phaseJeu with 
  | Moving i ->let p = Classes.getPlayerById i glob.vers in 
        if not(p#isDead) then Some (p) else None
  | _ -> None
  


let initInput () =
  
  let Global.{window;ctx; images; map; vers; phaseJeu; javascript;font1;font2;equipes;lastDt} = Global.get () in
  if javascript then begin 
  register "ArrowLeft" (
    
  fun () -> 
    let phaseJeu = (Global.get()).phaseJeu in
    match phaseJeu with 
    | Global.Aiming i ->
        let v = Classes.getPlayerById i vers in 
        v#augmenteAngle
    
    | _ -> 
    
    
    (let v = getPlayerWhoMoves () in 
  match v with 
  | None -> ()
  | Some pl -> pl#moveLeft)
);


register "ArrowRight" (fun () ->
  let phaseJeu = (Global.get()).phaseJeu in
  match phaseJeu with 
    | Global.Aiming i -> let v = Classes.getPlayerById i vers in 
        v#diminAngle
    
    | _ ->
  
  let v = getPlayerWhoMoves() in
  match v with 
  | None -> ()
  | Some pl -> pl#moveRight
);
register "ArrowUp" (fun () -> 
  let phaseJeu = (Global.get()).phaseJeu in
    match phaseJeu with 
    | Global.Aiming i ->
        let v = Classes.getPlayerById i vers in 
        v#augmentePuissance
    
    | _ -> 
  
  let v = getPlayerWhoMoves() in
  match v with 
  | None -> ()
  | Some pl -> (Classes.jump pl  map));
  
  register "ArrowDown" (fun () -> 
    let phaseJeu = (Global.get()).phaseJeu in
    match phaseJeu with 
    | Global.Aiming i ->
        let v = Classes.getPlayerById i vers in 
        v#dimPuissance
    
    | _ -> ()
    
    );
end
else
  begin


  register "left" (
    
    fun () -> 
      let phaseJeu = (Global.get()).phaseJeu in
      match phaseJeu with 
      | Global.Aiming i ->
          let v = Classes.getPlayerById i vers in 
          v#augmenteAngle
      
      | _ -> 
      
      
      (let v = getPlayerWhoMoves () in 
    match v with 
    | None -> ()
    | Some pl -> pl#moveLeft)
  );


  register "right" (fun () -> 
  let phaseJeu = (Global.get()).phaseJeu in
  match phaseJeu with 
    | Global.Aiming i -> let v = Classes.getPlayerById i vers in 
        v#diminAngle
    
    | _ ->
  
  (let v = getPlayerWhoMoves() in
  match v with 
  | None -> ()
  | Some pl -> pl#moveRight)
  );
  register "up" (fun () -> 
    let phaseJeu = (Global.get()).phaseJeu in
    match phaseJeu with 
    | Global.Aiming i ->
        let v = Classes.getPlayerById i vers in 
        v#augmentePuissance
    
    | _ -> 
    let v = getPlayerWhoMoves() in
    match v with 
    | None -> ()
    | Some pl -> (Classes.jump pl  map));

    register "down" (fun () -> 
      let phaseJeu = (Global.get()).phaseJeu in
      match phaseJeu with 
      | Global.Aiming i ->
          let v = Classes.getPlayerById i vers in 
          v#dimPuissance
      
      | _ -> ()
      
      )

  end





 
  
  