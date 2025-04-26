open System_defs
open Component_defs
open Ecs
open Classes
open Unix

let init dt =
  Ecs.System.init_all dt;
  Some ()


let update dt =
  let () = Input.handle_input () in
  
  Move_system.update dt;  
  Collision_system.update dt;
  Draw_system.update dt;
  
  None

let (let@) f k = f k

let getPrefixe phase vers=
match phase with
| Global.Moving i -> "idle"
| Global.Shooting i when (i = vers#getId)-> ""
| Global.Shooting i -> "idle"
| Global.Aiming i when (i = vers#getId)  -> ""
| Global.Aiming i -> "idle"

let getPre2 arme = 
  match arme#getTyp with 
  | Arc -> "bow"
  | Pistolet -> "gun"
  | Grenade -> "gre"
  | Bazooka -> "baz"

let getSuffixe v = 
  if v#isRight then 
    "right"
else
  "left"

(*Renvoie l'etat du jeu*)

let isOutOfScreen (v : Vector.t) = 
  (v.x < -100.0) ||
  (v.x > 1500.0) ||
  (v.y < -100.0) ||
  (v.y > 900.0)

let getImagePath (v : vers) phase=
  

  if v#isDead then "dead" else



  let pre = getPrefixe phase v in 

  if pre = "idle" then begin  
    match v#isRight with 
   | true -> "idleRight"
   | false -> "idleLeft"
    end
  else
  
    let debut = getPre2 (v#currentWeapon) in 
    let post = v#getSuffixe in 
    Printf.sprintf"%s%s" debut post 
   
    
  




let compteur = ref (0)



let load_png imageName  ctx =
  Gfx.load_image ctx ( Printf.sprintf"resources/images/%s.png" imageName)




let extractImage x = 
  match x with 
  | Some s -> s
  | None -> failwith"rien trouve"


let handleKeys camera s = 
  match s with 
  | "ArrowLeft" -> camera#setDx (-1.5);
  | "ArrowRight" -> camera#setDx (1.5);
  | "ArrowDown" -> camera#setDy (1.5);
  | "ArrowUp" -> camera#setDy (-1.5);
  | _ -> camera#setDx 0.0; camera#setDx 0.0

let handleEvents camera = 
  match Gfx.poll_event () with 
  | Gfx.KeyDown s ->let () = handleKeys camera s in ()
  | Gfx.KeyUp s -> let () = camera#setDx (0.0); camera#setDy (0.0) in ()
  | _ -> (  )




let registerComponent ca = 
  Collision_system.(register  (ca :>t));
        Move_system.(register (ca :> t));
        Draw_system.(register (ca :> t))

let unregisterComponent ca = 
  Collision_system.(unregister  (ca :>t));
        Move_system.(unregister (ca :> t));
        Draw_system.(unregister (ca :> t))

        

  let register_all_components (array_2d : 'a array array) =
    Array.iter (fun row ->
      Array.iter (fun ca ->
        if (ca#getTyp <> Air) then 
        registerComponent ca
      ) row
    ) array_2d



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
  for i = 1+(num)*Cst.nbJoueurEquipe to num*Cst.nbJoueurEquipe + Cst.nbJoueurEquipe  do 


    let pl = getPlayerById i global.vers in 

    let text = match pl#isDead with 
    | true-> Gfx.render_text ctx (Printf.sprintf"Vers %d : Mort" i)  smallFont  
    | _ -> Gfx.render_text ctx (Printf.sprintf"Vers %d : %d/%d P.v"  i pl#getVie pl#getVieMax)  smallFont in 
    Gfx.blit ctx surface text 8 !y;
    y := !y + dy
  

  done;



  Gfx.blit ctx screen surface 0 (50+num * h)

let initJoueurs n images map = 
  List.init n (fun i -> initVers2 (i+1) images map)

let initEtiquette num color ctx font= 
  Gfx.set_color ctx color;

  let indices = List.init (Cst.nbJoueurEquipe) (fun i -> 1+ num + i*Cst.nbEquipes) in

  (List.map (fun i -> Gfx.render_text ctx (Printf.sprintf"Vers %d" i; ) font ) indices)

let creerEtiquetteEquipe i ctx font =
  let r1, g1, b1 = 255, 0, 0 in 
  let r2, g2, b2 = 0 , 255, 0 in
  let c = Cst.lerpColor r1 g1 b1 r2 g2 b2 (float(i) /. float(Cst.nbEquipes - 1) ) in 
 
  initEtiquette i c ctx font

let creerAllEtiquette ctx font = 
  let indices = List.init Cst.nbEquipes (fun i -> i) in 

  Array.of_list(List.map (fun i -> creerEtiquetteEquipe i ctx font) indices)


let blitEtiquette e (v : Classes.vers) ctx screen = 
  (Gfx.blit ctx screen e (Float.to_int((v#position#get).x +. 7.0)) (Float.to_int(-15.0+.((v#position#get).y) )))

let displayEtiquette etiquette vers ctx screen =


  List.iter2 (fun v e -> blitEtiquette e v ctx screen) vers etiquette


let ammoDegatsZone (bullet : projectile) (t) (playerIgnore : int) =
  
  let global = Global.get () in 
 
  let zone = setZone (t#getTyp) in 
 
  let d = (float zone) *. (float Cst.tileHeight) in 
  List.iter (fun v -> 
    let x1 = ((v:> block)#position#get).x in 
    let y1 = ((v :> block)#position#get).y in 
    
    let x2 = ((bullet:> block)#position#get).x in 
    let y2 = ((bullet :> block)#position#get).y in 
      
    if distance x1 y1 x2 y2 <= d  then 
      begin
        if (v#getId <> playerIgnore) then
        v#drainHealth (t#getDegats);

       

      end

    ) global.vers;
      let map = global.map in
     for i = 0 to map#getHauteur -1 do 
        for j = 0 to map#getLargeur - 1 do
          begin
          let x1 = ((float j) *. (float Cst.tileHeight)) +.(float Cst.offsetX) in 
          let y1 = ((float i) *. (float Cst.tileHeight)) +.(float Cst.offsetY) in 
    
          let x2 = ((bullet:> block)#position#get).x in 
          let y2 = ((bullet :> block)#position#get).y in
          if distance x1 y1 x2 y2 <= d  then 
            begin
            (map#getCase i j)#takeDamage (t#getDegats)
            end
      
          end;

        done
    done






let run js =


  
  let window_spec = 
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in

  let screen = Gfx.get_surface window in

  let ctx = Gfx.get_context window in
  let () = Gfx.set_context_logical_size ctx Cst.window_width Cst.window_height in
 (* let _walls = Block.walls () in *)


  let images = Hashtbl.create 10 in

  let font1 = match js with 
  | true -> Gfx.load_font "Calibri"  "" 15
  | false ->  Gfx.load_font "resources/fonts/font.ttf" "" 15
  in

  let font2 = match js with 
  | true -> Gfx.load_font "Calibri"  "" 20
  | false ->  Gfx.load_font "resources/fonts/font.ttf" "" 20
  in


  let bullet = ref (None) in

  let text_file = Gfx.load_file "resources/maps/mapV1.csv" in

  

  Gfx.main_loop (fun _dt -> Gfx.get_resource_opt text_file )


    (fun content -> 



      let fileTile = load_png "tileset" ctx in

      let wormFileL  = load_png "worm" ctx in
      let wormFileR  = load_png "wormRight" ctx  in

      let dirtTile = load_png "dirt"  ctx in 
      let rockTile = load_png "rock" ctx in 
      let wallTile = load_png "wall" ctx in 
      let waterTile = load_png "water" ctx in 
      let grassTile = load_png "grass" ctx in 
      let tombFile = load_png "tomb" ctx in

      let gunleft0 = load_png "gunleft0" ctx in
      let gunleft1 = load_png "gunleft1" ctx in 

      let gunright0 = load_png "gunright0" ctx in
      let gunright1 = load_png "gunright1" ctx in 


      let bowleft0 = load_png "bowleft0" ctx in
      let bowleft1 = load_png "bowleft1" ctx in 

      let bowright0 = load_png "bowright0" ctx in
      let bowright1 = load_png "bowright1" ctx in 


      let bazleft0 = load_png "bazleft0" ctx in
      let bazleft1 = load_png "bazleft1" ctx in 

      let bazright0 = load_png "bazright0" ctx in
      let bazright1 = load_png "bazright1" ctx in 


      let greleft0 = load_png "grenadeleft0" ctx in
      let greleft1 = load_png "grenadeleft1" ctx in 

      let greright0 = load_png "grenaderight0" ctx in
      let greright1 = load_png "grenaderight1" ctx in   
      
      let viseur = load_png "viseur" ctx  in

      let arrow = load_png "arrow" ctx in 
      let ammo = load_png "bullet" ctx in 

      let grenade = load_png "grenade" ctx in 
      let rocket = load_png "rocket" ctx in


      Gfx.main_loop (fun _dt -> Some [|Gfx.get_resource_opt fileTile;
                                       Gfx.get_resource_opt wormFileL;
                                       Gfx.get_resource_opt wormFileR;
                                       Gfx.get_resource_opt dirtTile;
                                       Gfx.get_resource_opt rockTile; 
                                       Gfx.get_resource_opt wallTile; 
                                       Gfx.get_resource_opt waterTile; 
                                       Gfx.get_resource_opt grassTile;
                                       Gfx.get_resource_opt tombFile;

                                       Gfx.get_resource_opt gunleft0;
                                       Gfx.get_resource_opt gunleft1;
                                       Gfx.get_resource_opt gunright0;
                                       Gfx.get_resource_opt gunright1;

                                       Gfx.get_resource_opt bowleft0;
                                       Gfx.get_resource_opt bowleft1;
                                       Gfx.get_resource_opt bowright0;
                                       Gfx.get_resource_opt bowright1;

                                       Gfx.get_resource_opt greleft0;
                                       Gfx.get_resource_opt greleft1;
                                       Gfx.get_resource_opt greright0;
                                       Gfx.get_resource_opt greright1;

                                       Gfx.get_resource_opt bazleft0;
                                       Gfx.get_resource_opt bazleft1;
                                       Gfx.get_resource_opt bazright0;
                                       Gfx.get_resource_opt bazright1;

                                       Gfx.get_resource_opt viseur;

                                       Gfx.get_resource_opt arrow;
                                       Gfx.get_resource_opt ammo;
                                       Gfx.get_resource_opt grenade;
                                       Gfx.get_resource_opt rocket
      
      
      |] )

      ( fun x -> 
        
        let tileImage = extractImage x.(0)  in
        let wormImageL = extractImage x.(1) in
        let wormImageR = extractImage x.(2) in
        let dirtImage = extractImage x.(3)  in
        let rockImage = extractImage x.(4)  in
        let wallImage = extractImage x.(5)  in
        let waterImage = extractImage x.(6) in
        let grassImage = extractImage x.(7) in
        let tombImage = extractImage x.(8)  in

        let gunleft0 = extractImage x.(9) in 
        let gunleft1 = extractImage x.(10) in   

        let gunright0 = extractImage x.(11) in 
        let gunright1 = extractImage x.(12) in   

        let bowleft0 = extractImage x.(13) in 
        let bowleft1 = extractImage x.(14) in   

        let bowright0 = extractImage x.(15) in 
        let bowright1 = extractImage x.(16) in 

        let greleft0 = extractImage x.(17) in 
        let greleft1 = extractImage x.(18) in   

        let greright0 = extractImage x.(19) in 
        let greright1 = extractImage x.(20) in   

        let bazleft0 = extractImage x.(21) in 
        let bazleft1 = extractImage x.(22) in   

        let bazright0 = extractImage x.(23) in 
        let bazright1 = extractImage x.(24) in 

        let viseurPng = extractImage x.(25) in
        

        Hashtbl.add images "tileset" tileImage;
        (*Les images du joueur*)
       
        Hashtbl.add images "dirt" dirtImage;
        Hashtbl.add images "rock" rockImage;
        Hashtbl.add images "wall" wallImage;
        Hashtbl.add images "water" waterImage;
        Hashtbl.add images "grass" grassImage;
      


        let playerImages = Hashtbl.create 10 in

        Hashtbl.add playerImages "idleRight" wormImageR;
        Hashtbl.add playerImages "idleLeft" wormImageL;
        Hashtbl.add playerImages "dead" tombImage;

        Hashtbl.add playerImages "gunleft0" gunleft0;
        Hashtbl.add playerImages "gunleft1" gunleft1;

        Hashtbl.add playerImages "gunright0" gunright0;
        Hashtbl.add playerImages "gunright1" gunright1;

        Hashtbl.add playerImages "bowleft0" bowleft0;
        Hashtbl.add playerImages "bowleft1" bowleft1;

        Hashtbl.add playerImages "bowright0" bowright0;
        Hashtbl.add playerImages "bowright1" bowright1;

        Hashtbl.add playerImages "greright0" greright0;
        Hashtbl.add playerImages "greright1" greright1;

        Hashtbl.add playerImages "greleft0" greleft0;
        Hashtbl.add playerImages "greleft1" greleft1;

        Hashtbl.add playerImages "bazright0" bazright0;
        Hashtbl.add playerImages "bazright1" bazright1;

        Hashtbl.add playerImages "bazleft0" bazleft0;
        Hashtbl.add playerImages "bazleft1" bazleft1;

        Hashtbl.add images "viseur" viseurPng;


        Hashtbl.add images "arrow" (extractImage x.(26));
        Hashtbl.add images "ammo" (extractImage x.(27));
        Hashtbl.add images "grenade" (extractImage x.(28));
        Hashtbl.add images "rocket" (extractImage x.(29));

        let map = initMap content 55 30 images in
       
    
      
        let vers = initJoueurs Cst.nombreJoueurs playerImages map in
        (*let etiquette = initEtiquette Cst.nombreJoueurs  Cst.black ctx font2 in*)

        let equipes = creerAllEtiquette ctx font2 in

        List.iter registerComponent vers;


        
        register_all_components map#getLayout ;
        let phaseJeu = Global.Moving(1) in
        let javascript = js in

        let lastDt = 0.0 in 

        let global = Global.{ window; ctx ; images; map; vers; phaseJeu; javascript;font1;font2;equipes;lastDt;bullet} in
        Global.set global;

        Input.initInput();
    
        
        Gfx.main_loop (fun _dt -> 


         
          (*resetScreen ctx screen;*)
          (*displayMap ctx screen map tileImage cam;*)
          let glob = Global.get () in 
          let resultat = Global.getResultat(glob.vers) in
          
          if resultat = Continue then 
            begin
          
          let phaseJeu = glob.phaseJeu in
          let numJoueur = match phaseJeu with 
          | Moving i -> i 
          | Aiming i -> i 
          | Shooting i -> i 
          in

          let vActuel = getPlayerById numJoueur vers in

          if phaseJeu = (Shooting numJoueur) then 
            begin
              match !bullet with 
              | Some b -> (
                              
                b#update _dt ;
                List.iter (fun v -> if Collision.iscolliding (v :> block) (b :> block) then 
                  begin
                 

                  if numJoueur <> v#getId then 
                    begin
                    v#drainHealth(vActuel#currentWeapon#getDegats);
                    ammoDegatsZone b (vActuel#currentWeapon) (v#getId);
                    Collision_system.(unregister  (b :>t));
                  Move_system.(unregister (b :> t));
                    bullet := None;
                    let phaseJeu = Global.prochainePhase phaseJeu Cst.nombreJoueurs vers in 
                  Global.set{window; ctx; images; map ; vers; phaseJeu;javascript;font1;font2;equipes;lastDt;bullet}
                    end
              
                  

                  end;
                  
                  
                  
                  
                  
                  ) vers;
               if b#isTouched || (isOutOfScreen b#position#get) then 
                begin
                  Collision_system.(unregister  (b :>t));
                  Move_system.(unregister (b :> t));
                  ammoDegatsZone b (vActuel#currentWeapon) (-1);
                  bullet := None;
                  let phaseJeu = Global.prochainePhase phaseJeu Cst.nombreJoueurs vers in 
                  Global.set{window; ctx; images; map ; vers; phaseJeu;javascript;font1;font2;equipes;lastDt;bullet}
                end
                  )
            | None ->
                  
        
                
              let pl = getPlayerById numJoueur vers in
              let vect = Vector.fromAngle (pl#getAngle) (150.0 *.(pl#getPuissance)) in


              let debutVect =  Vector.add (pl#position#get) (Vector.{x = 0.; y  = -0. })  in 
              let arme = pl#currentWeapon in
              if arme#getMunitions > 0 then 
                begin
                arme#shoot;
                bullet := Some (initProjectile (arme#getTyp) (debutVect.x, debutVect.y) images vect _dt);
                
                Collision_system.(register  ((extractImage !bullet) :>t));
                Move_system.(register  ((extractImage !bullet) :>t))
               
                end

            end;
          
        


          List.iter (fun v -> 
            
            versGravite v map;
            v#setTexture (getImagePath v phaseJeu);

            if (v#position#get).x <=  Cst.minX then 
              v#setPx Cst.minX;

            if (v#position#get).x >= Cst.maxX then 
              v#setPx Cst.maxX;

            if v#isDead then begin 
              
              v#setVx 0.0; v#setVy 0.0 end
                    ) vers;

          let v = getPlayerById numJoueur vers in
         
          if v#isDead  then begin 
            let phaseJeu = Global.prochainePhase phaseJeu (Cst.nombreJoueurs) vers in
          
            Global.set{window; ctx; images; map ; vers; phaseJeu;javascript;font1;font2;equipes;lastDt; bullet} 
          end;

          let compte = ref 0 in 

          let () = 
          for i = 0 to map#getHauteur - 1 do 
            for j = 0 to map#getLargeur - 1 do 
              begin
              
              
              if ((map#getLayout).(i).(j))#isChanging then 
                begin 
                let ca = createCase2 "0" j i images in
                map#setLayout i j ca;
               
                registerComponent (ca );

                end;
                if not(map#getLayout).(i).(j)#isPresent ||((map#getLayout).(i).(j))#getResistance <= 0 
                  then 
                    begin
                  compte := !compte + 1;
                  unregisterComponent (map#getLayout.(i).(j));
                  map#setLayout i j (new case Air)
                    end;
  
              end;  
            done
          done
        in
        
        let global = Global.get () in

          let aiming, num = match phaseJeu with 
          | Aiming i -> true, i
          | _ -> false, -1  in 

        
          let str = ref(Printf.sprintf"%s" (Global.phaseStr global.phaseJeu)) in
          
          if aiming then
            begin 
            let pl = getPlayerById num vers in

            let vect = Vector.fromAngle (pl#getAngle) 60.0 in


            let debutVect = Vector.add (pl#position#get) (Vector.{x = 10.0; y = 12.0}) in 


            let finVect = Vector.sub (Vector.add debutVect vect) (Vector.{x = 20.0; y= 20.0}) in
            
            Gfx.blit ctx screen (viseurPng) (Float.to_int finVect.x) (Float.to_int finVect.y);
                

            let armeStr = printArme (pl#currentWeapon) in 
             str := Printf.sprintf"%s avec %s" (Global.phaseStr global.phaseJeu) armeStr   
            end;
          
          
         
          Gfx.set_color ctx Cst.black;
          let textImage = Gfx.render_text ctx !str font2 in

         
          Gfx.blit ctx screen textImage 10 10;
   
          let _ = ignore(update _dt)in
          Gfx.commit ctx;
          let lastDt = _dt in 
          let phaseJeu = (Global.get()).phaseJeu in
          Global.set{window; ctx; images; map ; vers; phaseJeu;javascript;font1;font2;equipes;lastDt;bullet} ;
          None
        end
      else
        Some (resultat)
          

          )

          (fun result -> 
            (match result with
            |  (Egalite) -> Gfx.debug"Match nul\n"
            |  (Victoire i) -> Gfx.debug"Victoire de l'equipe %d\n" i
            |  (Continue) -> Gfx.debug"Le jeu continue( errreur)\n")
            
            
            )

       
       
        
      )
      
    


      

    
    )










