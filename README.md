# Invisible-Encoder

Reupload of an accidently deleted github

## Example
```lua
local module = require("path/to/module")

local enc = module.encode("Hello World")
print(enc) --> 
local dec = module.decode(enc)
print(dec) --> Hello world
```

## Info
EncoderBuiltIn should be used if you have the functions used in it, if you don't you should use the one with the libraries added in
This replaces ascii characters with zero-width unicode characters so the characters will be completely invisible (and extremely hard to copy)


###### pog64 was used for testing leave me alone >_<
##### Originally made by me and 2 others but didn't bother to invite them back to the repository
