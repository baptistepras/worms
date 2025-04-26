open Ecs

class position () =
  let r = Component.init Vector.zero in
  object
    method position = r
  end

class velocity () =
  let r = Component.init Vector.zero in
  object
    method velocity = r
  end

class mass () =
  let r = Component.init 0.0 in
  object
    method mass = r
  end

class forces () =
  let r = Component.init Vector.zero in
  object
    method forces = r
  end

class box () =
  let r = Component.init Rect.{width = 0; height = 0} in
  object
    method box = r
  end

class texture () =
  let r = Component.init (Texture.Color (Gfx.color 255 0 0 255)) in
  object
    method texture = r
  end

type tag = ..
type tag += No_tag

class tagged () =
  let r = Component.init No_tag in
  object
    method tag = r
  end

class resolver () =
  let r = Component.init (fun (_ : Vector.t) (_ : tag) -> ()) in
  object
    method resolve = r
  end

class score1 () =
  let r = Component.init 0 in
  object
    method score1 = r
  end
class score2 () =
  let r = Component.init 0 in
  object
    method score2 = r
  end


(** Archetype *)
class type movable =
  object
    inherit Entity.t
    inherit position
    inherit velocity
  end

class type collidable =
  object
    inherit Entity.t
    inherit position
    inherit box
    inherit mass
    inherit velocity
    inherit resolver
    inherit tagged
    inherit forces
  end

class type physics =
  object 
    inherit Entity.t
    inherit mass
    inherit forces
    inherit velocity
  end

class type drawable =
  object
    inherit Entity.t
    inherit position
    inherit box
    inherit texture
  end

(** Real objects *)

class block ( imo : bool) =
  object (self)
    inherit Entity.t ()
    inherit position ()
    inherit box ()
    inherit resolver ()
    inherit tagged ()
    inherit texture ()
    inherit mass ()
    inherit forces ()
    inherit velocity ()

    val immobile = imo 

    val mutable touched = false

    val mutable present = true

    method disappear = present <- false


    method isPresent = present

    val mutable isRotating = false

    method setRotating b = isRotating <- b

    method rotates = isRotating
    method isImmobile = immobile

    method setTouched = touched <- true
    method isTouched = touched

    method getVx = (self#velocity#get).x 
    method getVy = (self#velocity#get).y 

    method getPx = (self#position#get).x 
    method getPy = (self#position#get).y 

    method setPx d = let y1 = self#getPy in 
      self#position#set Vector.{x = d; y = y1}

    method setVx d = self#velocity#set (Vector.changeX (self#velocity#get) d) 
    method setVy d = self#velocity#set (Vector.changeY (self#velocity#get) d) 


    method augmenteVx d = self#setVx (self#getVx +. d)
    method augmenteVy d = self#setVy (self#getVy +. d)

  end
