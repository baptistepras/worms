# Worms

A turn-based multiplayer artillery game inspired by Worms, written in OCaml. It runs natively with SDL or in the browser with js_of_ocaml.

## Gameplay

Teams of worms play in turn. The number of teams and of worms per team is set in `src/core/cst.ml`. Each worm has hit points and four weapons: a bow, a pistol, grenades and a bazooka. A turn has three phases:

1. **Move**: walk left or right and jump. Touching the water kills the worm. Press `N` to start aiming.
2. **Aim**: `Z` and `A` select the next and previous weapon, the left and right arrows set the direction, the up and down arrows set the power. Press `N` to shoot.
3. **Shoot**: the projectile follows a curved trajectory and damages what it hits. Press `Space` during the flight to create a platform at the projectile's position. Press `N` to pass to the next player.

The game ends when a single team is left, or in a draw when every worm is dead.

## Usage

Requires opam with `js_of_ocaml`, `js_of_ocaml-ppx`, `tsdl`, `tsdl-image` and `tsdl-ttf`.

```bash
dune build
./prog/game_sdl.exe     # native version
```

For the browser version, open `index.html` after the build.

## Structure

| Path | Content |
| --- | --- |
| `src/game.ml` | Game loop and setup |
| `src/components/` | Game classes: map, worms, weapons, projectiles |
| `src/core/` | Constants, global state, input handling, geometry |
| `src/systems/` | Collision, movement and drawing systems |
| `lib/` | Entity component system and graphics libraries |
| `resources/` | Images, fonts and maps (made with Tiled) |

## Authors

Raphael Leonardi and Baptiste Pras. The `lib/` libraries were provided as a starting framework.
