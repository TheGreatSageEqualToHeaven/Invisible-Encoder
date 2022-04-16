local Bit = {}
local floor = math.floor
local MOD = 2 ^ 32
local MODM = MOD - 1
local error = error
local ipairs = ipairs
local string = string
local table = table
local unpack = unpack
local print = print

Bit.bxor = function(a, b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra ~= rb then
            c = c + p
        end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    if a < b then
        a = b
    end
    while a > 0 do
        local ra = a % 2
        if ra > 0 then
            c = c + p
        end
        a, p = (a - ra) / 2, p * 2
    end
    return c
end

function Bit.band(a, b)
    return ((a + b) - Bit.bxor(a, b)) / 2
end

function Bit.bor(a, b)
    return MODM - Bit.band(MODM - a, MODM - b)
end

function Bit.lshift(a, disp)
    if disp < 0 then
        return Bit.rshift(a, -disp)
    end
    return (a * 2 ^ disp) % 2 ^ 32
end

function Bit.rshift(a, disp)
    if disp < 0 then
        return Bit.lshift(a, -disp)
    end
    return floor(a % 2 ^ 32 / 2 ^ disp)
end
local bit = Bit

local function strRelToAbs(str, ...)
    local args = {...}
    for k, v in ipairs(args) do
        v = v > 0 and v or #str + v + 1
        if v < 1 or v > #str then
            error("bad index to string (out of range)", 3)
        end
        args[k] = v
    end
    return unpack(args)
end

local function decode(str, startPos)
    startPos = strRelToAbs(str, startPos or 1)
    local b1 = str:byte(startPos, startPos)

    if b1 < 0x80 then
        return startPos, startPos
    end

    if b1 > 0xF4 or b1 < 0xC2 then
        return nil
    end

    local contByteCount = b1 >= 0xF0 and 3 or b1 >= 0xE0 and 2 or b1 >= 0xC0 and 1
    local endPos = startPos + contByteCount

    for _, bX in ipairs {str:byte(startPos + 1, endPos)} do
        if bit.band(bX, 0xC0) ~= 0x80 then
            return nil
        end
    end

    return startPos, endPos
end

function utf8_char(...)
    local buf = {}
    for k, v in ipairs {...} do
        if v < 0 or v > 0x10FFFF then
            error("bad argument #" .. k .. " to char (out of range)", 2)
        end
        local b1, b2, b3, b4 = nil, nil, nil, nil
        if v < 0x80 then
            table.insert(buf, string.char(v))
        elseif v < 0x800 then
            b1 = bit.bor(0xC0, bit.band(bit.rshift(v, 6), 0x1F))
            b2 = bit.bor(0x80, bit.band(v, 0x3F))
            table.insert(buf, string.char(b1, b2))
        elseif v < 0x10000 then
            b1 = bit.bor(0xE0, bit.band(bit.rshift(v, 12), 0x0F))
            b2 = bit.bor(0x80, bit.band(bit.rshift(v, 6), 0x3F))
            b3 = bit.bor(0x80, bit.band(v, 0x3F))
            table.insert(buf, string.char(b1, b2, b3))
        else
            b1 = bit.bor(0xF0, bit.band(bit.rshift(v, 18), 0x07))
            b2 = bit.bor(0x80, bit.band(bit.rshift(v, 12), 0x3F))
            b3 = bit.bor(0x80, bit.band(bit.rshift(v, 6), 0x3F))
            b4 = bit.bor(0x80, bit.band(v, 0x3F))
            table.insert(buf, string.char(b1, b2, b3, b4))
        end
    end
    return table.concat(buf, "")
end
--End of library

--Main

local encoder = {}
local invisiblestring = {}

local function strToBytes(str)
    local bytes = {str:byte(1, -1)}
    for i = 1, #bytes do
        bytes[i] = bytes[i] + 12
    end
    return table.concat(bytes, "'")
end

local function bytesToStr(str)
    local function gsub(c)
        return string.char(c - 12)
    end
    return str:gsub("(%d+)'?", gsub)
end

local function StringSplit(String)
    local tbl = {}
    String:gsub(
        ".",
        function(b)
            table.insert(tbl, b)
        end
    )
    return tbl
end

local dictionary, indexedTable = {}, {}

--1   255'172'141'148
--2   172'141'145'255
--3   141'152'255'172
--4   152'255'172'141
--5

--1   255'172'141'148  H
--2   255'172'141'145  E
--3   255'172'141'152  L
--4   255'172'141'152  L
--5 	255'172'141'155  O

--[[
  1: 255'
  2: 172'
  3: 141'
  4: ANY
]]
local function SplitBytes(inputstr)
    local index = 0
    local assemblied = 0
    local t = {}

    inputstr = inputstr:gsub("255'172", "")
    local Assembled = ""
    for str in string.gmatch(inputstr, "([^']+)") do
        if index == 1 then
            index = 0
            Assembled = Assembled .. "'" .. str
            table.insert(t, Assembled)
        else
            Assembled = str
            index = index + 1
        end
    end
    return t
end

--[[
        if index == 4 then
            assemblied = assemblied + 1

            if assemblied then

            end

					--	print(str)
            table.insert(t, Assembled:sub(1, -2))
            Assembled = ""
            index = 0
        else
            Assembled = Assembled .. str.."'"
            index = index + 1
        end
]]
local ASCII_Characters = {
    " ",
    "!",
    '"',
    "#",
    "$",
    "%",
    "&",
    "'",
    "(",
    ")",
    "*",
    "+",
    ",",
    "-",
    ".",
    "/",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    ":",
    ";",
    "<",
    "=",
    ">",
    "?",
    "@",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "[",
    "\\",
    "]",
    "^",
    "_",
    "`",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "{",
    "|",
    "}",
    "~"
}

local REPLACE_Characters = {
    536,
    537,
    538,
    539,
    540,
    541,
    542,
    543,
    544,
    545,
    546,
    547,
    548,
    549,
    550,
    551,
    552,
    553,
    554,
    555,
    556,
    557,
    558,
    559,
    560,
    561,
    562,
    563,
    564,
    565,
    566,
    567,
    568,
    569,
    570,
    571,
    572,
    573,
    574,
    575,
    576,
    577,
    578,
    579,
    580,
    581,
    582,
    583,
    584,
    585,
    586,
    587,
    588,
    589,
    590,
    591,
    592,
    593,
    594,
    595,
    596,
    597,
    598,
    599,
    600,
    601,
    602,
    603,
    604,
    605,
    606,
    607,
    608,
    609,
    610,
    611,
    612,
    613,
    614,
    615,
    616,
    617,
    618,
    619,
    620,
    621,
    622,
    623,
    624,
    625,
    626,
    627,
    628,
    629,
    630
}

local CHARACTERS_Table = {}
local REVERSE_Table = {}

for i, v in ipairs(ASCII_Characters) do
    local num = tonumber("917" .. REPLACE_Characters[i])
    CHARACTERS_Table[v] = num
    local CorrectByte = strToBytes(utf8_char(num)):gsub("255'172'", "")
    --print(CorrectByte)
    REVERSE_Table[CorrectByte] = v
end

function invisiblestring.encode(String)
    String = String
    local enc_tbl = {}
    print("TEST@: ", REVERSE_Table["255'172'141'140"])
    for i, v in ipairs(StringSplit(String)) do
        enc_tbl[i] = utf8_char(CHARACTERS_Table[v])
    end
    return table.concat(enc_tbl, "")
end

function invisiblestring.decode(String)
    local dec_tbl = {}
    local r = strToBytes(String)
    local Bytes = SplitBytes(r)
    for i, v in pairs(Bytes) do
        print(i, v)
        dec_tbl[i] = REVERSE_Table[v]
    end

    for i, v in pairs(dec_tbl) do
        print("RESULT: ", i, v)
    end

    return table.concat(dec_tbl, "")
end

local our_string = "TEST"
local enc = invisiblestring.encode(our_string)
local dec = invisiblestring.decode(enc)

print("\n\nFinal test:")
print(strToBytes(our_string))
print("our_string:", our_string)
print("enc:", string.format("String: '%s'", enc))
print("length:", #enc)
print("dec length:", #dec)
print("dec:", string.format("'%s'", dec))
