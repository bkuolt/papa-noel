

# Level Files
**TODO**

## Types
This section contains a brief overview of the types used to define a level file.


### Position
```json
position : { 2, 4 }
```

### Tile Definition
```json
tile : { 
    "position" : { 2, 3 }, 
    "sprite" : "ice_png"
}
```

# The whole Picture
```json
level : {
    "tiles" : { ... },
    "startPosition" : { 0, 1 }
}
```

* `startPosition` : The current `position` of *Papa Noel*
* `tiles`: A collection of `level`s.

# Savegames

# json.lua
TODO