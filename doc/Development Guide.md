
# TODO
This sections contains a brief list of planned enhancements of this project. As you will see there is a lot to be done:

* Save and load savegames as *json* files
    * use *json.lua* as parsing library
* Implement character motions
    * Motions
        * Jumping
        * Walking
        * Dying
    * Collision Detection
* Add enemies and NPCs
* Refactor *Lua* code
    * General performance impreovements
    * Coding in a *Lua style*
* Move as much code as possible to to C++. **The general goal is to replace *LÖVE* with a custom C++ 2D game engine with *Lua* bindings.**

# Directory Structure
* root 
    * src
    * assets
    * doc

# Level Files
This section provides a brief overview of the *json* data types that are planned to be used for future savegames.
## Types
This section contains a brief overview of the types used to define a level file.


### Describing a **Position**
```json
position : { 1, 7 }
```
This defines a position as a 2D vector `(1,7)` with x-coordinate `1` and y-coordinate `7`.

### Describing a **Tile**
```json
tile : { 
    "position" : { 2, 3 }, 
    "sprite" : "assets/ice.png"
}
```
This describes as a tile positioned at `(2, 3)` and
being visualized as a sprite at `assets/ice.png`.

# Describing a **Level*
```json
level : {
    "tiles" : { ... },
    "startPosition" : { 0, 1 }
}
```
This describes a level consisting of the tiles `tiles` and a
character starting at `startPosition`.

# Savegames
Generally savegames are stored as *json* files.
The savegame path is planed to be `($PAPA_NOEL_PATH\savegame.json)`

#

# json.lua
TODO