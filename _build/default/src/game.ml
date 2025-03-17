open System_defs
open Component_defs
open Ecs
open Classes

let init dt =
  Ecs.System.init_all dt;
  Some ()


let update dt =
  let () = Input.handle_input () in
  Collision_system.update dt;
  Move_system.update dt;  
  Draw_system.update dt;
  None

let (let@) f k = f k


let run () =
  let c = new case Air in
  let c2 = new case Terre in
  let c3 = new case Roche in
  let () = Gfx.debug "%s, %d\n%!" (printCase c) c#getResistance in
  let () = Gfx.debug "%s, %d\n%!" (printCase c2) c2#getResistance in
  let () = Gfx.debug "%s, %d\n%!" (printCase c3) c3#getResistance in

  let carte = new map 10 10 "file" in
  let c4 = carte#getCase 5 5 in
  let () = Gfx.debug "Case 4 , 4 : %s, %d\n%!" (printCase c4) c4#getResistance in

  let flingue = new arme Pistolet in
  let () = Gfx.debug"%s\n%!" (printArme flingue) in
  let fusil = new arme Fusil in
  let () = Gfx.debug"%s\n%!" (printArme fusil) in

  let v1 = new vers (4, 4) 10 (flingue :: fusil :: []) in
  let () = Gfx.debug"%s\n%!" (printVers v1) in
  let window_spec = 
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in
  let () = Gfx.set_context_logical_size ctx 800 600 in
  let _walls = Block.walls () in
  let global = Global.{ window; ctx } in
  Global.set global;
  let@ () = Gfx.main_loop ~limit:false init in
  let@ () = Gfx.main_loop update in ()








