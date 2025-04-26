(*
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
V                               V
V  1                         2  V
V  1 B                       2  V
V  1                         2  V
V  1                         2  V
V                               V
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*)


let window_width = 1200
let window_height = 700

let wall_thickness = 32

let white = Gfx.color 255 255 255 255

let black = Gfx.color 0 0 0 255

let red = Gfx.color 255 0 0 255

let green = Gfx.color 0 255 0 255


let lerp a b p = 
  Float.to_int((float a) +. float(b - a) *. p)

let lerpColor r1 g1 b1 r2 g2 b2 p =
  Gfx.color (lerp r1 r2 p) (lerp g1 g2 p) (lerp b1 b2 p) 255




let nbEquipes = 4

let nbJoueurEquipe = 2

let nombreJoueurs = nbEquipes *  nbJoueurEquipe

let hwall_width = window_width
let hwall_height = wall_thickness
let hwall1_x = 0
let hwall1_y = 0
let hwall2_x = 0
let hwall2_y = window_height -  wall_thickness

let vwall_width = wall_thickness
let vwall_height = window_height - 2 * wall_thickness
let vwall1_x = 0
let vwall1_y = wall_thickness
let vwall2_x = window_width - wall_thickness
let vwall2_y = vwall1_y
let g = Vector.{x = 0.0; y = 0.00000001 }




let tileWidth = 20
let tileHeight = 20

let offsetX = 200
let offsetY = 50


let minX =float offsetX
let maxX = float window_width -. 22.

let calibriJs = "Calibri"
let calibriSdl = ""

let rightJs = "ArrowRight"
let rightSdl = "right"

let leftJs = "ArrowLeft"
let leftSdl = "left"

let upSdl = "up"
let upJs = "ArrowUp"
