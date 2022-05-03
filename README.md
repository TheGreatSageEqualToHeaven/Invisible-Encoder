**OUTDATED**

**This is the original version of the invisible encoder, new repo is at** 
**https://github.com/picocode1/InvisibleEncoder**

# Invisible-Encoder

Replaces ascii characters with a zero-width character and vice-versa, makes strings completely invisible

## Example
```lua
local module = require("path/to/module")

local enc = module.encode("Hello World")
print(enc) --> (no there is no string here its an example stfu)
local dec = module.decode(enc)
print(dec) --> Hello world
```

## Info
EncoderBuiltIn should be used if you have the functions used in it, if you don't you should use the one with the libraries added in
This replaces ascii characters with zero-width unicode characters so the characters will be completely invisible (and extremely hard to copy)

## Challenges
When writing this we were working with Lua 5.1 which didn't have support for unicode characters and it would just skip over them so we had to add functions to support unicode characters, EncoderBuiltIn was made for Roblox's Luau but should also support Lua 5.3 and other versions of Lua with some edits
