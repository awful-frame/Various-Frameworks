local Unlocker, awful, ravn = ...
local ____exports = {}
____exports.Color = Color or ({})
____exports.Color.ALICE_BLUE = "|cfff0f8ff"
____exports.Color.ANTIQUE_WHITE = "|cfffaebd7"
____exports.Color.AQUA = "|cff00ffff"
____exports.Color.AQUAMARINE = "|cff7fffd4"
____exports.Color.AZURE = "|cfff0ffff"
____exports.Color.BEIGE = "|cfff5f5dc"
____exports.Color.BISQUE = "|cffffe4c4"
____exports.Color.BLACK = "|cff000000"
____exports.Color.BLANCHED_ALMOND = "|cffffebcd"
____exports.Color.BLUE = "|cff0000ff"
____exports.Color.BLUE_VIOLET = "|cff8a2be2"
____exports.Color.BROWN = "|cffa52a2a"
____exports.Color.BURLY_WOOD = "|cffdeb887"
____exports.Color.CADET_BLUE = "|cff5f9ea0"
____exports.Color.CHARTREUSE = "|cff7fff00"
____exports.Color.CHOCOLATE = "|cffd2691e"
____exports.Color.COPPER = "|cffb87333"
____exports.Color.CORAL = "|cffff7f50"
____exports.Color.CORNFLOWER_BLUE = "|cff6495ed"
____exports.Color.CORNSILK = "|cfffff8dc"
____exports.Color.CRISMON = "|cffdc143c"
____exports.Color.CYAN = "|cff00ffff"
____exports.Color.DARK_BLUE = "|cff00008b"
____exports.Color.DARK_CYAN = "|cff008b8b"
____exports.Color.DARK_GOLDEN_ROD = "|cffb8860b"
____exports.Color.DARK_GRAY = "|cffa9a9a9"
____exports.Color.DARK_GREY = "|cffa9a9a9"
____exports.Color.DARK_GREEN = "|cff006400"
____exports.Color.DARK_KHAKI = "|cffbdb76b"
____exports.Color.DARK_MAGENTA = "|cff8b008b"
____exports.Color.DARK_OLIVE_GREEN = "|cff556b2f"
____exports.Color.DARK_ORANGE = "|cffff8c00"
____exports.Color.DARK_ORCHID = "|cff9932cc"
____exports.Color.DARK_RED = "|cff8b0000"
____exports.Color.DARK_SALMON = "|cffe9967a"
____exports.Color.DARK_SEA_GREEN = "|cff8fbc8f"
____exports.Color.DARK_SLATE_BLUE = "|cff483d8b"
____exports.Color.DARK_SLATE_GRAY = "|cff2f4f4f"
____exports.Color.DARK_SLATE_GREY = "|cff2f4f4f"
____exports.Color.DARK_TURQUOISE = "|cff00ced1"
____exports.Color.DARK_VIOLET = "|cff9400d3"
____exports.Color.DEEP_PINK = "|cffff1493"
____exports.Color.DEEP_SKY_BLUE = "|cff00bfff"
____exports.Color.DIM_GRAY = "|cff696969"
____exports.Color.DIM_GREY = "|cff696969"
____exports.Color.DODGER_BLUE = "|cff1e90ff"
____exports.Color.FIRE_BRICK = "|cffb22222"
____exports.Color.FLORAL_WHITE = "|cfffffaf0"
____exports.Color.FOREST_GREEN = "|cff228b22"
____exports.Color.FUCHSIA = "|cffff00ff"
____exports.Color.GAINSBORO = "|cffdcdcdc"
____exports.Color.GHOST_WHITE = "|cfff8f8ff"
____exports.Color.GOLD = "|cffffd700"
____exports.Color.GOLDEN_ROD = "|cffdaa520"
____exports.Color.GRAY = "|cff808080"
____exports.Color.GREY = "|cff808080"
____exports.Color.GREEN = "|cff008000"
____exports.Color.GREEN_YELLOW = "|cffadff2f"
____exports.Color.HONEY_DEW = "|cfff0fff0"
____exports.Color.HOT_PINK = "|cffff69b4"
____exports.Color.INDIAN_RED = "|cffcd5c5c"
____exports.Color.INDIGO = "|cff4b0082"
____exports.Color.IVORY = "|cfffffff0"
____exports.Color.KHAKI = "|cfff0e68c"
____exports.Color.LAVENDER = "|cffe6e6fa"
____exports.Color.LAVENDER_BLUSH = "|cfffff0f5"
____exports.Color.LAWN_GREEN = "|cff7cfc00"
____exports.Color.LEMON_CHIFFON = "|cfffffacd"
____exports.Color.LIGHT_BLUE = "|cffadd8e6"
____exports.Color.LIGHT_CORAL = "|cfff08080"
____exports.Color.LIGHT_CYAN = "|cffe0ffff"
____exports.Color.LIGHT_GOLDEN_ROD_YELLOW = "|cfffafad2"
____exports.Color.LIGHT_GRAY = "|cffd3d3d3"
____exports.Color.LIGHT_GREY = "|cffd3d3d3"
____exports.Color.LIGHT_GREEN = "|cff90ee90"
____exports.Color.LIGHT_PINK = "|cffffb6c1"
____exports.Color.LIGHT_SALMON = "|cffffa07a"
____exports.Color.LIGHT_SEA_GREEN = "|cff20b2aa"
____exports.Color.LIGHT_SKY_BLUE = "|cff87cefa"
____exports.Color.LIGHT_SLATE_GRAY = "|cff778899"
____exports.Color.LIGHT_SLATE_GREY = "|cff778899"
____exports.Color.LIGHT_STEEL_BLUE = "|cffb0c4de"
____exports.Color.LIGHT_YELLOW = "|cffffffe0"
____exports.Color.LIME = "|cff00ff00"
____exports.Color.LIME_GREEN = "|cff32cd32"
____exports.Color.LINEN = "|cfffaf0e6"
____exports.Color.MAGENTA = "|cffff00ff"
____exports.Color.MAROON = "|cff800000"
____exports.Color.MEDIUM_AQUA_MARINE = "|cff66cdaa"
____exports.Color.MEDIUM_BLUE = "|cff0000cd"
____exports.Color.MEDIUM_ORCHID = "|cffba55de"
____exports.Color.MEDIUM_PURPLE = "|cff9370db"
____exports.Color.MEDIUM_SEA_GREEN = "|cff3cb371"
____exports.Color.MEDIUM_SLATE_BLUE = "|cff7b68ee"
____exports.Color.MEDIUM_SPRING_GREEN = "|cff00fa9a"
____exports.Color.MEDIUM_TURQUOISE = "|cff48d1cc"
____exports.Color.MEDIUM_VIOLET_RED = "|cffc71585"
____exports.Color.MIDNIGHT_BLUE = "|cff191970"
____exports.Color.MINT_CREAM = "|cfff5fffa"
____exports.Color.MISTY_ROSE = "|cffffe4e1"
____exports.Color.MOCCASIN = "|cffffe4b5"
____exports.Color.NAVAJO_WHITE = "|cffffdead"
____exports.Color.NAVY = "|cff000080"
____exports.Color.OLD_LACE = "|cfffdf2e3"
____exports.Color.OLIVE = "|cff808000"
____exports.Color.OLIVE_DRAB = "|cff6b8e23"
____exports.Color.ORANGE = "|cffffa500"
____exports.Color.ORANGE_RED = "|cffff4500"
____exports.Color.ORCHID = "|cffda70d6"
____exports.Color.PALE_GOLDEN_ROD = "|cffeee8aa"
____exports.Color.PALE_GREEN = "|cff98fb98"
____exports.Color.PALE_TURQUOISE = "|cffafeeee"
____exports.Color.PALE_VIOLET_RED = "|cffdb7093"
____exports.Color.PAPAYA_WHIP = "|cffffefd5"
____exports.Color.PEACH_PUFF = "|cffffdab9"
____exports.Color.PERU = "|cffcd853f"
____exports.Color.PINK = "|cffffc0cb"
____exports.Color.PLUM = "|cffdda0dd"
____exports.Color.POWDER_BLUE = "|cffb0e0e6"
____exports.Color.PURPLE = "|cff800008"
____exports.Color.REBECCA_PURPLE = "|cff663399"
____exports.Color.RED = "|cffff0000"
____exports.Color.ROSY_BROWN = "|cffbc8f8f"
____exports.Color.ROYAL_BLUE = "|cff4169e1"
____exports.Color.SADDLE_BROWN = "|cff8b4513"
____exports.Color.SALMON = "|cfffa8072"
____exports.Color.SANDY_BROWN = "|cff4a460"
____exports.Color.SEA_GREEN = "|cff2e8b57"
____exports.Color.SEA_SHELL = "|cfffff5ee"
____exports.Color.SIENNA = "|cffa0522d"
____exports.Color.SILVER = "|cffc0c0c0"
____exports.Color.SKY_BLUE = "|cff87ceeb"
____exports.Color.SLATE_BLUE = "|cff6a5acd"
____exports.Color.SLATE_GRAY = "|cff708090"
____exports.Color.SLATE_GREY = "|cff708090"
____exports.Color.SNOW = "|cfffffafa"
____exports.Color.SPRING_GREEN = "|cff00ff7f"
____exports.Color.STEEL_BLUE = "|cff4682b4"
____exports.Color.TAN = "|cffd2b48c"
____exports.Color.TEAL = "|cff008080"
____exports.Color.THISTLE = "|cffd8bfd8"
____exports.Color.TOMATO = "|cffff6347"
____exports.Color.TURQUOISE = "|cff40e0d0"
____exports.Color.VIOLET = "|cffee82ee"
____exports.Color.VITALIC_PURPLE = "|cffd600dc"
____exports.Color.WHEAT = "|cfff2deb3"
____exports.Color.WHITE = "|cffffffff"
____exports.Color.WHITE_SMOKE = "|cfff5f5f5"
____exports.Color.YELLOW = "|cffffff00"
____exports.Color.YELLOW_GREEN = "|cff9acd32"
____exports.Color.DEATH_KNIGHT = "|cffc41f3b"
____exports.Color.DEMON_HUNTER = "|cffa330c9"
____exports.Color.DRUID = "|cffff7d0a"
____exports.Color.HUNTER = "|cffabd473"
____exports.Color.MAGE = "|cff40c7eb"
____exports.Color.MONK = "|cff00ff96"
____exports.Color.PALADIN = "|cfff58cba"
____exports.Color.PRIEST = "|cffffffff"
____exports.Color.ROGUE = "|cfffff569"
____exports.Color.SHAMAN = "|cff0070de"
____exports.Color.WARLOCK = "|cff8787ed"
____exports.Color.WARRIOR = "|cffc79c6e"
____exports.Color.EVOKER = "|cff339480"
____exports.Color.RESET = "|r"
____exports.Color.getClassColor = "getClassColor"
awful.Populate(
    {
        ["Utilities.color"] = ____exports,
    },
    ravn,
    getfenv(1)
)
