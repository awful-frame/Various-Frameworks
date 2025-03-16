local Unlocker, awful, gifted = ...
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3, party1, party2, party3 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3, awful.party1, awful.party2, awful.party3

gifted.ccKickList = {
    -- CC Kicks --
    [20066] = "repentance",
    [118] = "polymorph",
    [51514] = "hex",
    [33786] = "cyclone",
    [113724] = "ring of frost",
    [5782] = "fear",
    [605] = "mind control",
    [360806] = "sleep walk",
    [30283] = "shadowfury",
    [204437] = "lightning lasso",
    [378464] = "nullifying shroud",
    [32375] = "mass dispel",
    [410126] = "searing glare",
    [28271] = "polymorphTurtle",
    [28272] = "polymorphPig",
    [61025] = "polymorphSnake",
    [61305] = "polymorphBlackCat",
    [61780] = "polymorphTurkey",
    [61721] = "polymorphRabbit",
    [126819] = "polymorphPorcupine",
    [161353] = "polymorphPolarBearCub",
    [161354] = "polymorphMonkey",
    [161355] = "polymorphPenguin",
    [161372] = "polymorphPeacock",
    [277787] = "polymorphBabyDirehorn",
    [277792] = "polymorphBumblebee",
    [321395] = "polymorphMawrat",
    [391622] = "polymorphDuck",
    [196942] = "hexVoodooTotem",
    [210873] = "hexRaptor",
    [211004] = "hexSpider",
    [211010] = "hexSnake",
    [211015] = "hexCockroach",
    [269352] = "hexSkeletalHatchling",
    [309328] = "hexLivingHoney",
    [277778] = "hexZandalariTendonripper",
    [277784] = "hexWickerMongrel",
    [198898] = "song of chiji",
    [2637] = "hibernate",
    [691] = "summon felhunter",
    [688] = "summon imp",
}

gifted.damageKickList = {
    [203286] = "greater pyroblast",
    [116858] = "chaos bolt",
    [51505] = "lava burst",
    [199786] = "glacial spike",
    [265187] = "demonic tyrant",
    [356995] = "disintegrate",
    [386997] = "soul rot",
    [191634] = "stormkeeper",
    [202771] = "full moon",
    [391528] = "convoke the spirits",
    [205021] = "ray of frost",
    [263165] = "void torrent",
    [395160] = "eruption",
    [375901] = "mindgames",
    [395152] = "ebon might",
    [120644] = "halo",
    [228260] = "void eruption",
    [391109] = "dark ascension",
    [391403] = "mind flay: insanity",
    [34914] = "vampiric touch",
    [324536] = "malefic rapture",
    [316099] = "unstable affliction",
    [342938] = "unstable affliction",
    [48181] = "haunt",
    [105174] = "hand of gul'dan",
    [104316] = "call dreadstalkers",
    [264178] = "demonbolt",
    [365350] = "arcane surge",
    [382440] = "shifting power",
    [390612] = "frost bomb",
    [382266] = "fire breath",
    [382411] = "eternity surge",
    [686] = "shadow bolt",
    [421453] = "ultimate penitence",
    [431044] = "frostfire bolt",
    [373130] = "dark reprimand",
    [450405] = "void blast",
    [450215] = "void blast",
    [414273] = "hand of divinity",
    [200652] = "tyr's deliverance",
    [454009] = "tempest",
    [47540] = "penance",
    [47757] = "penance",
    [47758] = "penance",
}

gifted.healKickList = {
    [8004] = "healing surge",
    [77472] = "healing wave",
    [1064] = "chain heal",
    [8936] = "regrowth",
    [115175] = "soothing mist",
    [2061] = "flash heal",
    [19750] = "holy light",
    [82326] = "holy light",
    [64843] = "divine hymn",
    [355936] = "dream breath",
    [289022] = "nourish",
    [48438] = "wild growth",
    [2060] = "heal",
    [191837] = "essence font",
    [367226] = "spiritbloom",
    [431443] = "chrono flames",
}

gifted.KickCheckCasting = function(enemy, spell)
    if not enemy.exists then return false end
    if not enemy.los then return false end
    if not player.facing(enemy) then return false end
    
    if enemy.buff(gifted.ULTIMATE_PENITENCE_BUFF_ID) then return end
    if enemy.buff(gifted.SPIRIT_OF_REDEMPTION_BUFF_ID) then return end

    if not enemy.casting then return false end
    if enemy.castInt then return false end

    if player.casting and enemy.castRemains > player.castRemains then return false end
    if enemy.castPct < (gifted.interruptDelay.now * 100) then return false end

    if enemy.castTarget.friend and enemy.castTarget.buff(gifted.GROUND_TOTEM_BUFF_ID) then return false end
    if enemy.castTarget.friend and enemy.castTarget.buff(gifted.SPELL_REFLECTION_BUFF_ID) then return false end
    if enemy.castTarget.friend and enemy.castTarget.buff(gifted.NETHERWARD_BUFF_ID) then return false end

    if not spell:Castable(enemy) then return false end

    return true
end

gifted.KickCheckChanneling = function(enemy, spell)
    if enemy.buff(gifted.ULTIMATE_PENITENCE_BUFF_ID) then return end
    if enemy.buff(gifted.SPIRIT_OF_REDEMPTION_BUFF_ID) then return end

    if not enemy.channeling then return false end
    if enemy.channelInt then return false end

    if player.casting and enemy.channelRemains > player.castRemains then return false end

    local channelTime = enemy.channeling4 / 1000
    if (channelTime + gifted.quickdelay.now) > awful.time then return end

    if enemy.castTarget.friend and enemy.castTarget.buff(gifted.GROUND_TOTEM_BUFF_ID) then return false end
    if enemy.castTarget.friend and enemy.castTarget.buff(gifted.SPELL_REFLECTION_BUFF_ID) then return false end
    if enemy.castTarget.friend and enemy.castTarget.buff(gifted.NETHERWARD_BUFF_ID) then return false end

    if not spell:Castable(enemy) then return false end

    return true
end