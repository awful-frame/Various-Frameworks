local blink = select(2, ...)

blink.lists_version = 0.169

local WOTLK = WOW_PROJECT_ID == 11
local RETAIL = WOW_PROJECT_ID == 1
local CLASSIC = WOW_PROJECT_ID == 2

blink.pvpFlags = { 
  156621, -- Alliance flag
  23333, -- Horde flag
  34976, -- Netherstorm Flag
  121164 -- Orb of Power
}

blink.creatureTypes = { "Beast", "Dragonkin", "Demon", "Elemental", "Giant", "Undead", "Humanoid", "Critter",
  "Mechanical", "Not specified", "Totem", "Non-combat Pet", "Gas Cloud", "Wild Pet", "Aberration",
  "None" }

-- viagra online
local function extend(t1, t2)
	-- can infer table is arrayish in this context by length operator returning value > 0
	if #t1 > 0 then 
		for _, v in pairs(t2) do tinsert(t1, v) end
		return
	end
	-- otherwise it's associative
	for k, v in pairs(t2) do t1[k] = v end
end

blink.cooldowns = {
	offensive = {
    -- Warrior
		[107574]		= { cd = 1.5, strength = 2 },									-- avatar
		[1719]			= { cd = 1.5, strength = 2 },									-- recklessness (20% increased crit chance, generating way more rage)
		[248622]		= { cd = 1, strength = 1 },										-- in for the kill (warbreaker buff talent)
		[324143] 		= { cd = 2, strength = 1.65 }, 								-- conq banner (necro banner)
    -- Death Knight
		[207289]		= { cd = 1.25, strength = 1.25 },							-- unholy frenzy
		[315443]		= { cd = 2, strength = 3 },										-- abomination limb
		[51271]			= { cd = 1, strength = 1.5 },									-- pillar of frost
    -- Druid
		[106951]		= { cd = 3, strength = 2 },										-- berserk (feral)
		[50334]			= { cd = 3, strength = 1 },										-- berserk (guardian)
		[102560]		= { cd = 3, strength = 2.5 },									-- incarn boomy
		[102543]		= { cd = 3, strength = 2.25 },								-- incarn feral
		[194223]		= { cd = 3, strength = 2.25 },								-- celestial alignment
		[173562]		= { cd = 1, strength = 2 },										-- celestial alignment (alt id?)
    -- Mage
		[12472]			= { cd = 3, strength = 3 },										-- icy veins
		[190319]		= { cd = 1.5, strength = 2, realCD = 2 },			-- combustion
		[12042]		 	= { cd = 2, strength = 2 },										-- arcane power
		[365362]	 	= { cd = 1.5, strength = 3 },		              -- arcane surge
		[383874]    = { cd = 0, strength = 1 },                   -- hypothermia
		[382106]    = { cd = 1, strength = 1 },                   -- freezing winds
    -- Monk
		[325201] 		= { cd = 0, strength = 2 }, 									-- dance of chi-ji (spinning crane kick proc)
		[152173]		= { cd = 1.5, strength = 2 },									-- serenity
		[137639]		= { cd = 1.5,	strength = 1.5 },								-- storm, earth, and fire
		[310454]		= { cd = 2, strength = 1.5 },									-- weapons of order
		[388663]		= { cd = 2, strength = 2 },										-- invoker's delight
		[393565]		= {	cd = 0.66, strength = 0.5},								-- thunderfist
    -- Hunter
		[19574]			= { cd = 1,	strength = 1.5, realCD = 1.5 },		-- bestial wrath
		[288613]		= { cd = 2,	strength = 2 },										-- trueshot
		[266779]		= { cd = 2, strength = 2 },										-- coordinated assault
		[260402] 		= { cd = 1, strength = 1.15 },								-- double tap
    	[186289]		= { cd = 1.5,	strength = 0.5 },								-- aspect of the eagle
		[193530]		= { cd = 2, strength = 2 },										-- aspect of the wild
    -- Paladin
		[31884]			= { cd = 3, strength = 3 },										-- avenging wrath (ret)
		[231895]		= { cd = 2, strength = 2 },										-- crusade
    -- Priest
		[196098]		= { cd = 2, strength = 2 },										-- soul harvest (+20% dmg)
		[194249]		= { cd = 1.5, strength = 1.5 },								-- voidform (post void eruption buff)
		[10060]			= { cd = 2, strength = 2 },										-- power infusion
    	[197871]		= { cd = 1, strength = 1.5 },									-- dark archangel
    -- Shaman
		[191634]		= { cd = 1, strength = 2 },										-- stormkeeper
		[114050]		= { cd = 3, strength = 2 },										-- ascendance
		[114051]		= { cd = 3, strength = 2 },										-- ascendance
		[16166]			= { cd = 0,	strength = 0.5 },									-- master of the elements (20% increased dmg on next spell)
		[2825]			= { cd = 1, strength = 1 },										-- bloodlust
		[32182]		  = { cd = 1, strength = 1 },										-- heroism
		[384352]    = { cd = 1.5, strength = 2 },									-- doom winds
		[215785]    = { cd = 0,	strength = 0.5 },                 					-- hot hand
		[333957]    = { cd = 1.5, strength = 1 },									-- feral spirit
    	[208963]    = { cd = 0.6, strength = 1 },									-- skyfury totem
    -- Rogue
		[121471]		= { cd = 3, strength = 3.5 },									-- shadow blades
		[185422]		= { cd = 1, strength = 1 },										-- shadow dance
		[13750]			= { cd = 3, strength = 2 },										-- adrenaline rush
		[51690]			= { cd = 2, strength = 2 },										-- killing spree
    -- Demon Hunter
		[247938]		= { cd = 2, strength = 2.5 },									-- chaos blades
    	[191427]		= { cd = 5,	strength = 2 },										-- metamorphosis
		[162264]		= { cd = 5, strength = 2 },										-- metamorphosis
    	[206804]    = { cd = 1, strength = 2 },                   -- rain from above
    -- Warlock
		[344566]		= { cd = 0.5, strength = 1 },									-- rapid contagion
		[113858]		= { cd = 2, strength = 2.5 },									-- dark soul: crit
		[113860]		= { cd = 2, strength = 2 },										-- dark soul: haste
	}
}

blink.spells = {
	castableWhileMoving = {
		[2948] = "scorch",
	},
	facingNotRequired = {
		[118] 		= true,		-- Sheep
		[28272] 	= true,		-- Pig
		[277792] 	= true,		-- Bee
		[161354] 	= true,		-- Monkey
		[277787] 	= true,		-- Direhorn
		[161355] 	= true,		-- Penguin
		[161353] 	= true,		-- Polar Bear
		[120140] 	= true,		-- Porcupine
		[61305] 	= true,		-- Cat
		[61721] 	= true,		-- Rabbit
		[61780] 	= true,		-- Turkey
		[28271] 	= true,		-- Turtle
		[391622]	= true,		-- Duck
		[321395]	= true,		-- Mawrat
		[36554] 	= true,		-- Shadowstep
		[79140] 	= true,		-- Vendetta
		[2094] 		= true,		-- Blind
		[102359]  	= true, 	-- Mass Entanglement
		[93402]		= true,		-- Sunfire
		[774] 		= true,		-- Rejuv
		[33763]		= true,		-- Lifebloom
		[102342] 	= true,		-- Ironbark
		[29166]		= true,		-- Innervate
		[34026]		= true,		-- KillCommand
	},
	sheeps = {
		118,		-- Sheep
		28272,		-- Pig
		277792,		-- Bee
		161354,		-- Monkey
		277787,		-- Direhorn
		161355,		-- Penguin
		161353,		-- Polar Bear
		120140,		-- Porcupine
		61305,		-- Cat
		61721,		-- Rabbit
		61780,		-- Turkey
		28271,		-- Turtle
		391622, 	-- Duck
		321395,		-- Mawrat
	}
}

blink.beastBuffs = {
	5487,		-- Bear
	768,		-- Cat
	783,		-- Travel
	33891, 		-- Tree
	24858,		-- Moonkin
	197625,		-- Balance Affinity Moonkin
}

blink.powerTypes = {
	["mana"] = 0,
	["rage"] = 1,
	["focus"] = 2,
	["energy"] = 3,
	["combopoints"] = 4,
	["cp"] = 4,
	["runes"] = 5,
	["runicpower"] = 6,
	["soulshards"] = 7,
	["shards"] = 7,
	["astralpower"] = 8,
	["ap"] = 8,
	["lunarpower"] = 8,
	["holypower"] = 9,
	["alternatepower"] = 10,
	["maelstrom"] = 11,
	["chi"] = 12,
	["insanity"] = 13,
	["arcanecharges"] = 16,
	["fury"] = 17,
	["pain"] = 18,
	["essence"] = 19
}

blink.covenants = {
	["None"] = 0,
	["Kyrian"] = 1,
	["Venthyr"] = 2,
	["NightFae"] = 3,
	["Necrolord"] = 4
}

blink.ccDebuffs = {

	-- *** Disorients *** --

	-- Covenant
	[331866] = "disorient", -- Door of Shadows
	-- Druid
	[33786] = "disorient",  -- Cyclone
	-- Paladin
	[105421] = "disorient", -- Blinding Light
	[10326] = "disorient", -- Turn Evil
	-- Priest
	[8122] = "disorient", -- Psychic Scream
	-- [205369] = "disorient", -- Mind Bomb Pre-Explosion
	[226943]  = "disorient", -- Mind Bomb
	[605] = "disorient", -- Mind Control
	-- Rogue
	[2094] = "disorient", -- Blind
	-- Warlock
	[5782] = "disorient", --fear
	[118699] = "disorient", -- New Fear ID
	[5484] = "disorient", -- Howl of Terror
	[6358] = "disorient", -- Seduction (Succubus)
	[115268] = "disorient", -- Mesmerize (Shivarra)
	-- Warrior
	[5246] = "disorient", -- Intimidating Shout
	-- Mage
	[31661] = "disorient", -- Dragon's Breath
	-- Monk
	[198909] = "disorient",	-- Song of Chi Ji
	-- Death Knight
	[207167] = "disorient", -- Blinding Sleet
	-- Evoker
	[360806] = "disorient", -- Sleep Walk (FEAR, 360806, Sleep Walk, Asleep)

	-- *** Incapacitates *** --
	[207685]  = "disorient",       -- Sigil of Misery
	[209753]  = "disorient",       -- Cyclone (Honor talent)
	[202274]  = "disorient",       -- Incendiary Brew
	[1513]    = "disorient",       -- Scare Beast
	[324263]  = "disorient",      -- Sulfuric Emission
	[203337]  = "incapacitate",    -- Freezing Trap (Honor talent)
	[126819]  = "incapacitate",    -- Polymorph (Porcupine)
	[9484]    = "incapacitate",    -- Shackle Undead
	[196942]  = "incapacitate",    -- Hex (Voodoo Totem)
	[197214]  = "incapacitate",    -- Sundering
	[107079] = "incapacitate", -- Quaking Palm
	[2637] = "incapacitate", -- Hibernate
	[3355] = "incapacitate", -- Freezing Trap
	[187650] = "incapacitate", -- Freezing Trap (Old?)
	[213691] = "incapacitate", -- Scatter Shot
	[118] = "incapacitate", -- Polymorph Sheep
	[28272] = "incapacitate", -- Polymorph (Pig)
	[277792] = "incapacitate", -- Polymorph (Bee)
	[161354] = "incapacitate", -- Polymorph (Monkey)
	[277787] = "incapacitate", -- Polymorph (Direhorn)
	[161355] = "incapacitate", -- Polymorph (Penguin)
	[161353] = "incapacitate", -- Polymorph (Polar Bear)
	[120140] = "incapacitate", -- Polymorph (Porcupine)
	[61305] = "incapacitate", -- Polymorph (Cat)
	[61025] = "incapacitate", -- Polymorph (Snake) (removed?)
	[61721] = "incapacitate", -- Polymorph (Rabbit)
	[61780] = "incapacitate", -- Polymorph (Turkey)
	[28271] = "incapacitate", -- Polymorph (Turtle)
	[161372] = "incapacitate", -- Polymorph (Peacock)
	[391622] = "incapacitate", -- Polymorph (Duck)
	[321395] = "incapacitate", -- Polymorph (Mawrat)
	[383121]  = "incapacitate", -- Mass Polymorph
	[82691] = "incapacitate", -- Ring of Frost
	[123394] = "incapacitate", -- Glyph of Breath of Fire
	[115078] = "incapacitate", -- Paralysis
	[20066] = "incapacitate", -- Repentance
	[200196] = "incapacitate", --Holy Word: Chastise
	[1776] = "incapacitate", -- Gouge
	[6770] = "incapacitate", -- Sap
	[51514] = "incapacitate", -- Hex
	[211015] = "incapacitate", -- Hex (Cockroach)
	[210873] = "incapacitate", -- Hex (Compy)
	[211010] = "incapacitate",	-- Hex (Snake)
	[211004] = "incapacitate",	-- Hex (Spider)
	[277784] = "incapacitate",	-- Hex (Wicker Mongrel)
	[277778] = "incapacitate",	-- Hex (Zandalari Tendonripper)
	[309328] = "incapacitate",	-- Hex (Living Honey)
	[269352] = "incapacitate",	-- Hex (Skeletal Raptor)
	[710] = "incapacitate",   -- Banish ?
	[6789] = "incapacitate",	-- Mortal Coil
	[217832] = "incapacitate",  -- Imprison
	[221527] = "incapacitate",  -- Imprison (detainment)

	-- *** Silences *** --

	-- Death Knight
	[47476] = "silence", -- Strangulate -- FIXME (Old ID, need to make sure this is correct)
	-- Paladin
	[31935] = "silence", -- Avenger's Shield
	-- Priest
	[15487] = "silence", -- Silence
	-- Rogue
	[1330] = "silence", -- Garrote Silence
	-- Hunter
	[202933]  = "silence", -- Spider Sting -- FIXME (Old ID possibly? New sting might be different.)
	[356727]  = "silence", -- Spider Venom

	-- *** Stuns *** --

	-- Warrior
	[132168] = "stun", -- Shockwave -- FIXME (Does this even exist any more? Guess it's harmless leaving it in)
	[132169] = "stun", -- Storm Bolt 
	[199085]  = "stun",            -- Warpath
	[46968]   = "stun",            -- Shockwave
	-- Death Knight
	[108194] = "stun", -- Asphyxiate
	[221562] = "stun", -- Asphyxiate (Blood) -- FIXME (Not sure this is correct, but doesn't hurt to leave it in)
	[91800] = "stun", -- Gnaw (Ghoul)
	[91797] = "stun", -- Monstrous Blow (Dark Transformation Ghoul)
	[210141]  = "stun", -- Zombie Explosion (This does DR stuns)
	[334693] = "stun", -- Absolute Zero (Frostwyrm Freeze)
	-- Druid
	[203123] = "stun", -- Maim
	[5211] = "stun", -- Mighty Bash
	[163505] = "stun", -- Rake Stun
	-- Hunter
	[24394] = "stun", -- Intimidation
	[357021]  = "stun", -- Consecutive Concussion
	[117526]  = "stun", -- Binding Shot
	-- Monk
	[119392] = "stun", -- Charging Ox Wave (talent)
	[119381] = "stun", -- Leg Sweep
	-- Paladin
	[853] = "stun", -- Hammer of Justice
	[119072] = "stun", -- Holy Wrath (Protection) -- FIXME (Not sure this exists any more)
	[205290] = "stun",	-- wake of ashes
	-- Rogue
	[1833] = "stun", -- Cheap Shot
	[408] = "stun", -- Kidney Shot
	[202346]  = "stun",            -- Double Barrel
	[199804]  = "stun",            -- Between the Eyes
	-- [199804] = "stun", -- Between the eyes ( no longer exists )
	-- Shaman
	[118905] = "stun", -- Static Charge (Capacitor Totem) -- FIXME (Need to confirm debuff ID)
	[118345] = "stun", -- Pulverize (Pet Stun)
	[287254]  = "stun",            -- Dead of Winter
	[205630]  = "stun",            -- Illidan's Grasp (Primary effect)
	[208618]  = "stun",            -- Illidan's Grasp (Secondary effect)
	[202244]  = "stun",            -- Overrun (Also a knockback)
	[305485]  = "stun",            -- Lightning Lasso
	-- Warlock
	[30283] = "stun", -- Shadowfury
	[89766] = "stun", -- Axe Toss (Felguard)
	[171017]  = "stun", -- Meteor Strike (Infernal)
	[171018]  = "stun", -- Meteor Strike (Abyssal)
	-- Demon Hunter
	[179057] = "stun", -- Chaos Nova
	[191427] = "stun", -- Metamorphosis -- FIXME (I don't believe this exists any more, or has ever DR'd stuns?)
	[211881] = "stun", -- Fel Eruption
	--Priest
	[200200] = "stun", -- Censure Chastise
	[64044] = "stun", -- Psychic Horror (Stun effect)
	-- Tauren
	[20549] = "stun", -- War Stomp
	-- Highmountain
	[255723]  = "stun", -- Bull Rush (Highmountain Tauren)
	-- Kultiran
	[287712]  = "stun", -- Haymaker (Kul Tiran)
	-- Covenant
	[332423] = "stun", 	-- Sparkling Driftglobe Core (kyrian low hp aoe stun proc)
	-- Evoker
	[372245] = "stun", -- Terror of the Skies other one maybe 371032
	-- Mage
	[389831]  = "stun", -- Snowdrift

	-- *** Roots *** --

	[339] = "root",    -- Entangling Roots
	[102359] = "root",   -- Mass Entanglement
	[136634] = "root",   -- Narrow Escape
	[122] = "root",    -- Frost Nova
	[33395] = "root",    -- Mage Pet Freeze
	[111340] = "root",   -- Ice Ward
	[114404] = "root",   -- Void Tendril's Grasp
	[64695] = "root",    -- Earthgrab (Earthgrab Totem)
	[63685] = "root",    -- Freeze (Frozen Power)
	[107566] = "root",   -- Staggering Shout
	[200108] = "root",   -- Ranger's Net (talent)
	[116706] = "root",   -- Disable (Monk)
	[235963] = "root",   -- Melee Roots (Earthen Grasp)
	[117405] = "root",   -- Binding Shot (talent)
	[354051] = "root",   -- nimble steps (covenant)
	[355689] = "root",	-- Landslide (Evoker)
	[105771] = "root",	--  Charge, Rooted
	[12024] = "root",	--  Net, Rooted
	[157997] = "root",	--  Ice Nova, Rooted
	[162480] = "root",	--  Steel Trap, Rooted
	[190925] = "root",	--  Harpoon, Rooted
	[199042] = "root",	--  Thunderstruck, Rooted
	[233395] = "root",	--  Deathchill, Rooted
	[356356] = "root",	--  Warbringer, Rooted
	[356738] = "root",	--  Earth Unleashed, Rooted
	[370970] = "root",	--  The Hunt, Rooted
	[374020] = "root",	--  Containment Beam, Rooted
	[374724] = "root",	--  Molten Subduction, Rooted
	[375671] = "root",	--  Ice Shackle, Rooted
	[377488] = "root",	--  Icy Bindings, Rooted
	[378760] = "root",	--  Frostbite, Rooted
	[385700] = "root",	--  Frost Nova, Rooted
	[387657] = "root",	--  Earthen Hold, Rooted
	[387796] = "root",	--  Net, Rooted
	[388920] = "root",	--  Frozen Shroud, Rooted
	[389280] = "root",	--  Web, Rooted
	[393456] = "root",	--  Entrapment, Rooted
	[393813] = "root",	--  Frozen Web, Rooted
	[394391] = "root",	--  Static Cling, Rooted
	[394447] = "root",	--  Web, Rooted
	[395956] = "root",	--  Manaweaving, Rooted
	[396722] = "root",	--  Absolute Zero, Rooted
	[45334] = "root",	--  Immobilized, Rooted
	[91807] = "root",	--  Shambling Rush, Rooted
	[241887] = "root", -- Landslide
	[285515] = "root", -- Surge of Power (Frost Shock Root)

}

-- doing this cuz in other versions of classic this ID isn't a cc
if RETAIL then
  extend(blink.ccDebuffs, {
    [99] = "incapacitate", --Incapacitating Roar
  })
end

if WOTLK then
	extend(blink.ccDebuffs, {
		[49203] = "incapacitate", -- Hungering Cold
		[2637]  = "incapacitate", -- Hibernate (Rank 1)
		[18657] = "incapacitate", -- Hibernate (Rank 2)
		[18658] = "incapacitate", -- Hibernate (Rank 3)
		[60210] = "incapacitate", -- Freezing Arrow Effect (Rank 1)
		[3355]  = "incapacitate", -- Freezing Trap Effect (Rank 1)
		[14308] = "incapacitate", -- Freezing Trap Effect (Rank 2)
		[14309] = "incapacitate", -- Freezing Trap Effect (Rank 3)
		[19386] = "incapacitate", -- Wyvern Sting (Rank 1)
		[24132] = "incapacitate", -- Wyvern Sting (Rank 2)
		[24133] = "incapacitate", -- Wyvern Sting (Rank 3)
		[27068] = "incapacitate", -- Wyvern Sting (Rank 4)
		[49011] = "incapacitate", -- Wyvern Sting (Rank 5)
		[49012] = "incapacitate", -- Wyvern Sting (Rank 6)
		[118]   = "incapacitate", -- Polymorph (Rank 1)
		[12824] = "incapacitate", -- Polymorph (Rank 2)
		[12825] = "incapacitate", -- Polymorph (Rank 3)
		[12826] = "incapacitate", -- Polymorph (Rank 4)
		[28271] = "incapacitate", -- Polymorph: Turtle
		[28272] = "incapacitate", -- Polymorph: Pig
		[61721] = "incapacitate", -- Polymorph: Rabbit
		[61780] = "incapacitate", -- Polymorph: Turkey
		[61305] = "incapacitate", -- Polymorph: Black Cat
		[20066] = "incapacitate", -- Repentance
		[1776]  = "incapacitate", -- Gouge
		[6770]  = "incapacitate", -- Sap (Rank 1)
		[2070]  = "incapacitate", -- Sap (Rank 2)
		[11297] = "incapacitate", -- Sap (Rank 3)
		[51724] = "incapacitate", -- Sap (Rank 4)
		[710]   = "incapacitate", -- Banish (Rank 1)
		[18647] = "incapacitate", -- Banish (Rank 2)
		[9484]  = "incapacitate", -- Shackle Undead (Rank 1)
		[9485]  = "incapacitate", -- Shackle Undead (Rank 2)
		[10955] = "incapacitate", -- Shackle Undead (Rank 3)
		[51514] = "incapacitate", -- Hex
		[13327] = "incapacitate", -- Reckless Charge (Rocket Helmet)
		[4064]  = "incapacitate", -- Rough Copper Bomb
		[4065]  = "incapacitate", -- Large Copper Bomb
		[4066]  = "incapacitate", -- Small Bronze Bomb
		[4067]  = "incapacitate", -- Big Bronze Bomb
		[4068]  = "incapacitate", -- Iron Grenade
		[12421] = "incapacitate", -- Mithril Frag Bomb
		[4069]  = "incapacitate", -- Big Iron Bomb
		[12562] = "incapacitate", -- The Big One
		[12543] = "incapacitate", -- Hi-Explosive Bomb
		[19769] = "incapacitate", -- Thorium Grenade
		[19784] = "incapacitate", -- Dark Iron Bomb
		[30216] = "incapacitate", -- Fel Iron Bomb
		[30461] = "incapacitate", -- The Bigger One
		[30217] = "incapacitate", -- Adamantite Grenade

		[47481] = "stun", -- Gnaw (Ghoul Pet)
		[5211]  = "stun", -- Bash (Rank 1)
		[6798]  = "stun", -- Bash (Rank 2)
		[8983]  = "stun", -- Bash (Rank 3)
		[22570] = "stun", -- Maim (Rank 1)
		[49802] = "stun", -- Maim (Rank 2)
		[24394] = "stun", -- Intimidation
		[50519] = "stun", -- Sonic Blast (Pet Rank 1)
		[53564] = "stun", -- Sonic Blast (Pet Rank 2)
		[53565] = "stun", -- Sonic Blast (Pet Rank 3)
		[53566] = "stun", -- Sonic Blast (Pet Rank 4)
		[53567] = "stun", -- Sonic Blast (Pet Rank 5)
		[53568] = "stun", -- Sonic Blast (Pet Rank 6)
		[50518] = "stun", -- Ravage (Pet Rank 1)
		[53558] = "stun", -- Ravage (Pet Rank 2)
		[53559] = "stun", -- Ravage (Pet Rank 3)
		[53560] = "stun", -- Ravage (Pet Rank 4)
		[53561] = "stun", -- Ravage (Pet Rank 5)
		[53562] = "stun", -- Ravage (Pet Rank 6)
		[44572] = "stun", -- Deep Freeze
		[853]   = "stun", -- Hammer of Justice (Rank 1)
		[5588]  = "stun", -- Hammer of Justice (Rank 2)
		[5589]  = "stun", -- Hammer of Justice (Rank 3)
		[10308] = "stun", -- Hammer of Justice (Rank 4)
		[2812]  = "stun", -- Holy Wrath (Rank 1)
		[10318] = "stun", -- Holy Wrath (Rank 2)
		[27139] = "stun", -- Holy Wrath (Rank 3)
		[48816] = "stun", -- Holy Wrath (Rank 4)
		[48817] = "stun", -- Holy Wrath (Rank 5)
		[408]   = "stun", -- Kidney Shot (Rank 1)
		[8643]  = "stun", -- Kidney Shot (Rank 2)
		[58861] = "stun", -- Bash (Spirit Wolves)
		[30283] = "stun", -- Shadowfury (Rank 1)
		[30413] = "stun", -- Shadowfury (Rank 2)
		[30414] = "stun", -- Shadowfury (Rank 3)
		[47846] = "stun", -- Shadowfury (Rank 4)
		[47847] = "stun", -- Shadowfury (Rank 5)
		[12809] = "stun", -- Concussion Blow
		[60995] = "stun", -- Demon Charge
		[30153] = "stun", -- Intercept (Felguard Rank 1)
		[30195] = "stun", -- Intercept (Felguard Rank 2)
		[30197] = "stun", -- Intercept (Felguard Rank 3)
		[47995] = "stun", -- Intercept (Felguard Rank 4)
		[20253] = "stun", -- Intercept Stun (Rank 1)
		[20614] = "stun", -- Intercept Stun (Rank 2)
		[20615] = "stun", -- Intercept Stun (Rank 3)
		[25273] = "stun", -- Intercept Stun (Rank 4)
		[25274] = "stun", -- Intercept Stun (Rank 5)
		[46968] = "stun", -- Shockwave
		[20549] = "stun", -- War Stomp (Racial)

		[16922]   = "random_stun",  -- Celestial Focus (Starfire Stun)
		[28445]   = "random_stun",  -- Improved Concussive Shot
		[12355]   = "random_stun",  -- Impact
		[20170]   = "random_stun",  -- Seal of Justice Stun
		[39796]   = "random_stun",  -- Stoneclaw Stun
		[12798]   = "random_stun",  -- Revenge Stun
		[5530]    = "random_stun",  -- Mace Stun Effect (Mace Specialization)
		[15283]   = "random_stun",  -- Stunning Blow (Weapon Proc)
		[56]      = "random_stun",  -- Stun (Weapon Proc)
		[34510]   = "random_stun",  -- Stormherald/Deep Thunder (Weapon Proc)

		[1513]  = "fear", -- Scare Beast (Rank 1)
		[14326] = "fear", -- Scare Beast (Rank 2)
		[14327] = "fear", -- Scare Beast (Rank 3)
		[10326] = "fear", -- Turn Evil
		[8122]  = "fear", -- Psychic Scream (Rank 1)
		[8124]  = "fear", -- Psychic Scream (Rank 2)
		[10888] = "fear", -- Psychic Scream (Rank 3)
		[10890] = "fear", -- Psychic Scream (Rank 4)
		[2094]  = "fear", -- Blind
		[5782]  = "fear", -- Fear (Rank 1)
		[6213]  = "fear", -- Fear (Rank 2)
		[6215]  = "fear", -- Fear (Rank 3)
		[6358]  = "fear", -- Seduction (Succubus)
		[5484]  = "fear", -- Howl of Terror (Rank 1)
		[17928] = "fear", -- Howl of Terror (Rank 2)
		[5246]  = "fear", -- Intimidating Shout
		[5134]  = "fear", -- Flash Bomb Fear (Item)

		[339]   = "root", -- Entangling Roots (Rank 1)
		[1062]  = "root", -- Entangling Roots (Rank 2)
		[5195]  = "root", -- Entangling Roots (Rank 3)
		[5196]  = "root", -- Entangling Roots (Rank 4)
		[9852]  = "root", -- Entangling Roots (Rank 5)
		[9853]  = "root", -- Entangling Roots (Rank 6)
		[26989] = "root", -- Entangling Roots (Rank 7)
		[53308] = "root", -- Entangling Roots (Rank 8)
		[19975] = "root", -- Nature's Grasp (Rank 1)
		[19974] = "root", -- Nature's Grasp (Rank 2)
		[19973] = "root", -- Nature's Grasp (Rank 3)
		[19972] = "root", -- Nature's Grasp (Rank 4)
		[19971] = "root", -- Nature's Grasp (Rank 5)
		[19970] = "root", -- Nature's Grasp (Rank 6)
		[27010] = "root", -- Nature's Grasp (Rank 7)
		[53312] = "root", -- Nature's Grasp (Rank 8)
		[50245] = "root", -- Pin (Rank 1)
		[53544] = "root", -- Pin (Rank 2)
		[53545] = "root", -- Pin (Rank 3)
		[53546] = "root", -- Pin (Rank 4)
		[53547] = "root", -- Pin (Rank 5)
		[53548] = "root", -- Pin (Rank 6)
		[33395] = "root", -- Freeze (Water Elemental)
		[122]   = "root", -- Frost Nova (Rank 1)
		[865]   = "root", -- Frost Nova (Rank 2)
		[6131]  = "root", -- Frost Nova (Rank 3)
		[10230] = "root", -- Frost Nova (Rank 4)
		[27088] = "root", -- Frost Nova (Rank 5)
		[42917] = "root", -- Frost Nova (Rank 6)
		[39965] = "root", -- Frost Grenade (Item)
		[63685] = "root", -- Freeze (Frost Shock)

		[12494] = "random_root",         -- Frostbite
		[55080] = "random_root",         -- Shattered Barrier
		[58373] = "random_root",         -- Glyph of Hamstring
		[23694] = "random_root",         -- Improved Hamstring
		[47168] = "random_root",         -- Improved Wing Clip
		[19185] = "random_root",         -- Entrapment

		-- NOT SUPPOSED TO BE HERE [53359] = "disarm", -- Chimera Shot (Scorpid)
		-- NOT SUPPOSED TO BE HERE [50541] = "disarm", -- Snatch (Rank 1)
		-- NOT SUPPOSED TO BE HERE [53537] = "disarm", -- Snatch (Rank 2)
		-- NOT SUPPOSED TO BE HERE [53538] = "disarm", -- Snatch (Rank 3)
		-- NOT SUPPOSED TO BE HERE [53540] = "disarm", -- Snatch (Rank 4)
		-- NOT SUPPOSED TO BE HERE [53542] = "disarm", -- Snatch (Rank 5)
		-- NOT SUPPOSED TO BE HERE [53543] = "disarm", -- Snatch (Rank 6)
		-- NOT SUPPOSED TO BE HERE [64058] = "disarm", -- Psychic Horror Disarm Effect
		-- NOT SUPPOSED TO BE HERE [51722] = "disarm", -- Dismantle
		-- NOT SUPPOSED TO BE HERE [676]   = "disarm", -- Disarm

		[47476] = "silence", -- Strangulate
		[34490] = "silence", -- Silencing Shot
		[35334] = "silence", -- Nether Shock 1 -- TODO: verify
		[44957] = "silence", -- Nether Shock 2 -- TODO: verify
		[18469] = "silence", -- Silenced - Improved Counterspell (Rank 1)
		[55021] = "silence", -- Silenced - Improved Counterspell (Rank 2)
		[63529] = "silence", -- Silenced - Shield of the Templar
		[15487] = "silence", -- Silence
		[1330]  = "silence", -- Garrote - Silence
		[18425] = "silence", -- Silenced - Improved Kick
		[24259] = "silence", -- Spell Lock
		[43523] = "silence", -- Unstable Affliction 1
		[31117] = "silence", -- Unstable Affliction 2
		[18498] = "silence", -- Silenced - Gag Order (Shield Slam)
		[74347] = "silence", -- Silenced - Gag Order (Heroic Throw?)
		[50613] = "silence", -- Arcane Torrent (Racial, Runic Power)
		[28730] = "silence", -- Arcane Torrent (Racial, Mana)
		[25046] = "silence", -- Arcane Torrent (Racial, Energy)

		[64044] = "horror", -- Psychic Horror
		[6789]  = "horror", -- Death Coil (Rank 1)
		[17925] = "horror", -- Death Coil (Rank 2)
		[17926] = "horror", -- Death Coil (Rank 3)
		[27223] = "horror", -- Death Coil (Rank 4)
		[47859] = "horror", -- Death Coil (Rank 5)
		[47860] = "horror", -- Death Coil (Rank 6)

		[1833]  = "opener_stun", -- Cheap Shot
		[9005]  = "opener_stun", -- Pounce (Rank 1)
		[9823]  = "opener_stun", -- Pounce (Rank 2)
		[9827]  = "opener_stun", -- Pounce (Rank 3)
		[27006] = "opener_stun", -- Pounce (Rank 4)
		[49803] = "opener_stun", -- Pounce (Rank 5)

		[31661] = "scatter", -- Dragon's Breath (Rank 1)
		[33041] = "scatter", -- Dragon's Breath (Rank 2)
		[33042] = "scatter", -- Dragon's Breath (Rank 3)
		[33043] = "scatter", -- Dragon's Breath (Rank 4)
		[42949] = "scatter", -- Dragon's Breath (Rank 5)
		[42950] = "scatter", -- Dragon's Breath (Rank 6)
		[19503] = "scatter", -- Scatter Shot

		-- Spells that DR with itself only
		[33786] = "cyclone",        -- Cyclone
		[605]   = "mind_control",   -- Mind Control
		[13181] = "mind_control",   -- Gnomish Mind Control Cap
		[7922]  = "charge",         -- Charge Stun
		[19306] = "counterattack",  -- Counterattack 1
		[20909] = "counterattack",  -- Counterattack 2
		[20910] = "counterattack",  -- Counterattack 3
		[27067] = "counterattack",  -- Counterattack 4
		[48998] = "counterattack",  -- Counterattack 5
		[48999] = "counterattack",  -- Counterattack 6
	})
end

blink.bccDebuffs = {
	
	-- *** Disorients *** --

	-- Covenant
	[331866] = "disorient", -- Door of Shadows
	-- Paladin
	[105421] = "disorient", -- Blinding Light
	[10326] = "disorient", -- Turn Evil
	-- Priest
	[8122] = "disorient", -- Psychic Scream
	[226943]  = "disorient", -- Mind Bomb
	[605] = "disorient", -- Mind Control
	-- Rogue
	[2094] = "disorient", -- Blind
	-- Warlock
	[5782] = "disorient", --fear
	[118699] = "disorient", -- New Fear ID
	[5484] = "disorient", -- Howl of Terror
	[6358] = "disorient", -- Seduction (Succubus)
	[115268] = "disorient", -- Mesmerize (Shivarra)
	-- Warrior
	[5246] = "disorient", -- Intimidating Shout
	-- Mage
	[31661] = "disorient", -- Dragon's Breath
	-- Monk
	[198909] = "disorient",	-- Song of Chi Ji
	-- Death Knight
	[207167] = "disorient", -- Blinding Sleet

	-- *** Incapacitates *** --

	-- Racials
	[107079] = "incapacitate", -- Quaking Palm
	-- Druid
	[2637] = "incapacitate", -- Hibernate
	-- Hunter
	[3355] = "incapacitate", -- Freezing Trap
	[187650] = "incapacitate", -- Freezing Trap (Old?)
	[213691] = "incapacitate", -- Scatter Shot
	-- Mage
	[118] = "incapacitate", -- Polymorph Sheep
	[28272] = "incapacitate", -- Polymorph (Pig)
	[277792] = "incapacitate", -- Polymorph (Bee)
	[161354] = "incapacitate", -- Polymorph (Monkey)
	[277787] = "incapacitate", -- Polymorph (Direhorn)
	[161355] = "incapacitate", -- Polymorph (Penguin)
	[161353] = "incapacitate", -- Polymorph (Polar Bear)
	[120140] = "incapacitate", -- Polymorph (Porcupine)
	[61305] = "incapacitate", -- Polymorph (Cat)
	[61025] = "incapacitate", -- Polymorph (Snake) (removed?)
	[61721] = "incapacitate", -- Polymorph (Rabbit)
	[61780] = "incapacitate", -- Polymorph (Turkey)
	[28271] = "incapacitate", -- Polymorph (Turtle)
	[161372] = "incapacitate", -- Polymorph (Peacock)
	[391622] = "incapacitate", -- Polymorph (Duck)
	[321395] = "incapacitate", -- Polymorph (Mawrat)
	[383121]  = "incapacitate", -- Mass Polymorph
	[82691] = "incapacitate", -- Ring of Frost
	-- Monk
	[115078] = "incapacitate", -- Paralysis
	-- Paladin
	[20066] = "incapacitate", -- Repentance
	-- Priest
	[200196] = "incapacitate", --Holy Word: Chastise
	-- Rogue
	[1776] = "incapacitate", -- Gouge
	[6770] = "incapacitate", -- Sap
	-- Shaman
	[51514] = "incapacitate", -- Hex
	[211015] = "incapacitate", -- Hex (Cockroach)
	[210873] = "incapacitate", -- Hex (Compy)
	[211010] = "incapacitate",	-- Hex (Snake)
	[211004] = "incapacitate",	-- Hex (Spider)
	[277784] = "incapacitate",	-- Hex (Wicker Mongrel)
	[277778] = "incapacitate",	-- Hex (Zandalari Tendonripper)
	[309328] = "incapacitate",	-- Hex (Living Honey)
	[269352] = "incapacitate",	-- Hex (Skeletal Raptor)
	-- Demon Hunter
	[217832] = "incapacitate",  -- Imprison

}

-- doing this cuz in other versions of classic this ID isn't a cc
if RETAIL then
  extend(blink.bccDebuffs, {
    [99] = "incapacitate", --Incapacitating Roar
  })
end

if WOTLK then
	extend(blink.bccDebuffs, {
		[49203] = "incapacitate", -- Hungering Cold
		--[2637]  = "incapacitate", -- Hibernate (Rank 1) -- DUPLICATE
		[18657] = "incapacitate", -- Hibernate (Rank 2)
		[18658] = "incapacitate", -- Hibernate (Rank 3)
		[60210] = "incapacitate", -- Freezing Arrow Effect (Rank 1)
		--[3355]  = "incapacitate", -- Freezing Trap Effect (Rank 1) -- DUPLICATE
		[14308] = "incapacitate", -- Freezing Trap Effect (Rank 2)
		[14309] = "incapacitate", -- Freezing Trap Effect (Rank 3)
		[19386] = "incapacitate", -- Wyvern Sting (Rank 1)
		[24132] = "incapacitate", -- Wyvern Sting (Rank 2)
		[24133] = "incapacitate", -- Wyvern Sting (Rank 3)
		[27068] = "incapacitate", -- Wyvern Sting (Rank 4)
		[49011] = "incapacitate", -- Wyvern Sting (Rank 5)
		[49012] = "incapacitate", -- Wyvern Sting (Rank 6)
		--[118]   = "incapacitate", -- Polymorph (Rank 1) -- DUPLICATE
		[12824] = "incapacitate", -- Polymorph (Rank 2)
		[12825] = "incapacitate", -- Polymorph (Rank 3)
		[12826] = "incapacitate", -- Polymorph (Rank 4)
		--[28271] = "incapacitate", -- Polymorph: Turtle -- DUPLICATE
		--[28272] = "incapacitate", -- Polymorph: Pig -- DUPLICATE
		--[61721] = "incapacitate", -- Polymorph: Rabbit -- DUPLICATE
		--[61780] = "incapacitate", -- Polymorph: Turkey -- DUPLICATE
		--[61305] = "incapacitate", -- Polymorph: Black Cat -- DUPLICATE
		--[20066] = "incapacitate", -- Repentance -- DUPLICATE
		--[1776]  = "incapacitate", -- Gouge -- DUPLICATE
		--[6770]  = "incapacitate", -- Sap (Rank 1) -- DUPLICATE
		[2070]  = "incapacitate", -- Sap (Rank 2)
		[11297] = "incapacitate", -- Sap (Rank 3)
		[51724] = "incapacitate", -- Sap (Rank 4)
		[710]   = "incapacitate", -- Banish (Rank 1)
		[18647] = "incapacitate", -- Banish (Rank 2)
		[9484]  = "incapacitate", -- Shackle Undead (Rank 1)
		[9485]  = "incapacitate", -- Shackle Undead (Rank 2)
		[10955] = "incapacitate", -- Shackle Undead (Rank 3)
		--[51514] = "incapacitate", -- Hex -- DUPLICATE
		[13327] = "incapacitate", -- Reckless Charge (Rocket Helmet)
		[4064]  = "incapacitate", -- Rough Copper Bomb
		[4065]  = "incapacitate", -- Large Copper Bomb
		[4066]  = "incapacitate", -- Small Bronze Bomb
		[4067]  = "incapacitate", -- Big Bronze Bomb
		[4068]  = "incapacitate", -- Iron Grenade
		[12421] = "incapacitate", -- Mithril Frag Bomb
		[4069]  = "incapacitate", -- Big Iron Bomb
		[12562] = "incapacitate", -- The Big One
		[12543] = "incapacitate", -- Hi-Explosive Bomb
		[19769] = "incapacitate", -- Thorium Grenade
		[19784] = "incapacitate", -- Dark Iron Bomb
		[30216] = "incapacitate", -- Fel Iron Bomb
		[30461] = "incapacitate", -- The Bigger One
		[30217] = "incapacitate", -- Adamantite Grenade
		[67769] = "incapacitate", -- Cobalt Frag Bomb
		[67890] = "incapacitate", -- Cobalt Frag Bomb (Frag Belt)
		[54466] = "incapacitate", -- Saronite Grenade
	
		[1513]  = "fear", -- Scare Beast (Rank 1)
		[14326] = "fear", -- Scare Beast (Rank 2)
		[14327] = "fear", -- Scare Beast (Rank 3)
		--[10326] = "fear", -- Turn Evil -- DUPLICATE
		--[8122]  = "fear", -- Psychic Scream (Rank 1) -- DUPLICATE
		[8124]  = "fear", -- Psychic Scream (Rank 2)
		[10888] = "fear", -- Psychic Scream (Rank 3)
		[10890] = "fear", -- Psychic Scream (Rank 4)
		--[2094]  = "fear", -- Blind -- DUPLICATE
		--[5782]  = "fear", -- Fear (Rank 1) -- DUPLICATE
		[6213]  = "fear", -- Fear (Rank 2)
		[6215]  = "fear", -- Fear (Rank 3)
		--[6358]  = "fear", -- Seduction (Succubus) -- DUPLICATE
		--[5484]  = "fear", -- Howl of Terror (Rank 1) -- DUPLICATE
		[17928] = "fear", -- Howl of Terror (Rank 2)
		--[5246]  = "fear", -- Intimidating Shout -- DUPLICATE
		[5134]  = "fear", -- Flash Bomb Fear (Item)
	
		--[31661] = "scatter", -- Dragon's Breath (Rank 1) -- DUPLICATE
		[33041] = "scatter", -- Dragon's Breath (Rank 2)
		[33042] = "scatter", -- Dragon's Breath (Rank 3)
		[33043] = "scatter", -- Dragon's Breath (Rank 4)
		[42949] = "scatter", -- Dragon's Breath (Rank 5)
		[42950] = "scatter", -- Dragon's Breath (Rank 6)
		[19503] = "scatter", -- Scatter Shot
	})
end

local both = {magic = true, physical = true}
local physical = {physical = true}
local magic = {magic = true}

blink.immunityBuffs = {
	-- precog
	[377362] = { cc = true, interrupt = true },
	-- burrow
	[409293] = { damage = both, effects = both, cc = true },
	-- disperse. consider immune to all damage if above 20% hp.
	[47585] = { damage = both, conditions = function(obj) return obj.hp > 20 end },
	-- bubble
	[642] = { damage = both, effects = both },
	-- bop
	[1022] = { damage = physical, effects = physical },
	-- grounding
	[8178] = { damage = {magicTargeted = true}, effects = {magicTargeted = true} },
	-- ice form
	[198144] = { cc = "stun" },
	-- holy ward
	[213610] = { cc = true },
	-- bladestorm
	[227847] = { cc = true },
	-- .. other bladestorm?
	[46924] = { cc = true },
	-- df bladestorm
	[389774] = { cc = true },
	-- tww fury bladestorm
	[446035] = { cc = true },
	-- bladestorm
	[222634] = { cc = true },
	-- bladestorm
	[240204] = { cc = true },
	-- bladestorm
	[433801] = { cc = true },
	-- bladestorm
	[389789] = { cc = true },
	-- spell reflect
	[216890] = { damage = {magicTargeted = true}, effects = {magicTargeted = true} },
	-- gfade
	[213602] = { damage = both, effects = both },
	-- phase shift
	[408558] = { damage = both, effects = both, cc = true },
	-- block
	[45438] = { damage = both, effects = both },
	-- ibf
	[48792] = { cc = "stun" },
	-- turtl
	[186265] = { damage = both, effects = both },
	-- first 1.5s of meta
	[162264] = { damage = both, effects = both, conditions = function(obj) return obj.buffUptime(162264) <= 1.5 and obj.buffRemains(162264) > 28 end },
	--dh Glimpse	
	[354610] = { cc = true },
	-- cloak
	[31224] = { damage = magic, effects = magic },
	-- ams
	[48707] = { effects = magic },
	[410358] = { effects = magic },
	-- nether ward
	[212295] = { effects = {magicTargeted = true}, damage = {magicTargeted = true} },
	-- spell warding 
	[204018] = { damage = magic, effects = magic },
	-- evasion
	[5277] = { damage = physical, effects = physical, conditions = function(obj) return obj.facing(blink.player, 200) and not obj.cc and not C_Spell.IsCurrentSpell(36554) end },
	-- die by the sword
	[118038] = { damage = physical, effects = physical, conditions = function(obj) return obj.facing(blink.player, 200) and not obj.cc and not C_Spell.IsCurrentSpell(36554) end },
	-- riposte
	[199754] = { damage = physical, effects = physical, conditions = function(obj) return obj.facing(blink.player, 200) and not obj.cc and not C_Spell.IsCurrentSpell(36554) end },
	-- blur
	[198589] = { damage = physical, effects = physical, conditions = function(obj) return not obj.cc and not C_Spell.IsCurrentSpell(36554) end },
	-- fleshcraft
	[323524] = { cc = true },
	-- forgotten queens
	[228050] = { damage = both, effects = both },
	-- [keeper of the grove] tranq immune
	[362486] = { damage = both, effects = both, cc = true, interrupt = true },
	-- pissWeaver (peaceweaver) revival magic immune
	[353319] = { damage = magic, effects = magic },
	-- nether walk
	[196555] = { damage = both },
	-- Echoing Resolve (new trinky)
	[363121] = { cc = true, interrupt = true },
	-- lichborne
	[49039] = { cc = "fear, charm, sleep", undead = true },
	-- dream flight (evoker)
	[359816] = { cc = true },
	-- time stop (evoker)
	[378441] = { damage = both, effects = both, cc = true },
	-- nullifying shroud (evoker)
	[378464] = { cc = true },
	-- deep breath (evoker)
	[357210] = { cc = true },
	-- spiritwalkers aegis
	[378078] = { interrupt = true },
	-- aura mastery with conc aura
	[317929] = { interrupt = true },
	-- https://www.wowhead.com/spell=421453/ultimate-penitence
	[421453] = { cc = true, interrupt = true },

	-- World PVP Event buff https://www.wowhead.com/spell=385841/arcane-bravery
	[385841] = { healing = true, damage = both, },

	--#region PVE Shit
	-- Noxious Fog (Surgeon Stitchflesh, Necrotic Wake)
	[326629] = { damage = both },
	-- Guessing Game (Mistcaller, Mists of Tirna Scithe)
	[336499] = { damage = both },
	-- Blood Shroud (Shriekwing, Castle Nathria)
	[328921] = { damage = both },
	-- Unyielding Shield (Dutiful Attendant, Castle Nathria)
	[346694] = { damage = both },
	-- Overwhelming Energy (Seal of Empowerment) (Azureblade, The Azure Vault)
	[379256] = { damage = both },
	-- Crackling Shield (Balakar Khan, Nokhudon Hold)
	[376724] = {damage = both, effects = both},
	--#endregion
}

if WOTLK then
	extend(blink.immunityBuffs, {
		-- https://www.wowhead.com/wotlk/spell=70768/shroud-of-the-occult
		[70768] = { damage = both, effects = both },
		-- deterrence (wotlk)
		[19263] = { damage = both, effects = both },
		-- deflection (wotlk)
		[52419] = { damage = physical, effects = physical, conditions = function(obj) return obj.facing(blink.player, 200) and not obj.cc and not C_Spell.IsCurrentSpell(36554) end },
		-- spell reflect (wotlk)
		[23920] = { damage = {magicTargeted = true}, effects = {magicTargeted = true} },
		-- stoneform (wotlk)
		[65116] = { bleed = true },
		-- evasion (wotlk)
		[26669] = { damage = physical, effects = physical, conditions = function(obj) return obj.facing(blink.player, 200) and not obj.cc and not C_Spell.IsCurrentSpell(36554) end },
		-- fear ward (wotlk)
		[6346] = { cc = "fear" },
		-- bop (wotlk)
		[10278] = { damage = physical, effects = physical },
		-- iceblock (wotlk, balinda)
		[46604] = { damage = both, effects = both },
		-- Guardian Aura (wotlk)
		[56153] = { damage = both, effects = both },
		-- Divine Shield (wotlk)
		[67251] = { damage = both, effects = both },
	})
end

blink.immunityDebuffs = {
	[33786] = { damage = both, effects = both, healing = true }, -- clone
	[221527] = { damage = both, effects = both, healing = true }, -- imprison
	[710] = { damage = both, effects = both, healing = true }, -- banish
	[203340] = { damage = both, effects = both, healing = true }, -- diamond ice
	[203337] = { damage = both, effects = both, healing = true }, -- diamond ice
}

blink.stealthBuffs = {
	5215, 	-- prowl
	1784, 	-- stealth
	58984,	-- shadowmeld
	115191, -- stealth w/ nightstalker
	114018, -- mass invis
	110960, -- greater invis
	115193, -- vanish
	119032, -- spectral guise
	66, 		-- entering invisibility
	198158, -- mass invis 2
	32612,	-- invis
	11327,	-- vanish
}

blink.slowImmuneBuffs = {
	54216, 		-- Master's Call
	45438, 		-- Ice Block
	1044, 		-- Hand Of Freedom
	1022, 		-- Hand Of Prot
	642,  		-- Divine Shield
	47585, 		-- Dispersion
	227847, 	-- Bladestorm
	389774,   	-- DF Bladestorm
	115018,  	-- Desecrated ground
	216113,		-- Way of the Crane
	305395,		-- cancerous undispellable freedom
	323524, 	-- Ultimate Form
	359816, 	-- Dream Flight
	378441, 	-- Time Stop
	378437, 	-- Unburdened Flight
	421453, 	-- Ultimate Penitence
}

blink.ignoreLoS = {
	[56754] = true, -- Azure Serpent (Shado'pan Monestary)
	[56895] = true, -- Weak Spot - Raigon (Gate of the Setting Sun)
	[76585] = true, -- Ragewing
	[77692] = true, -- Kromog
	[77182] = true, -- Oregorger
	-- 86644, 	-- Ore Crate from Oregorger boss
	[96759] = true, -- Helya
	[100360] = true, -- Grasping Tentacle (Helya fight)
	[100354] = true, -- Grasping Tentacle (Helya fight)
	[100362] = true, -- Grasping Tentacle (Helya fight)
	[98363] = true, -- Grasping Tentacle (Helya fight)
	[99803] = true, -- Destructor Tentacle (Helya fight)
	[99801] = true, -- Destructor Tentacle (Helya fight)
	[98696] = true, -- Illysanna Ravencrest (Black Rook Hold)
	[114900] = true, -- Grasping Tentacle (Trials of Valor)
	[114901] = true, -- Gripping Tentacle (Trials of Valor)
	[116195] = true, -- Bilewater Slime (Trials of Valor)
	[120436] = true, -- Fallen Avatar (Tomb of Sargeras)
	[116939] = true, -- Fallen Avatar (Tomb of Sargeras)
	[118462] = true, -- Soul Queen Dejahna (Tomb of Sargeras)
	[119072] = true, -- Desolate Host (Tomb of Sargeras)
	[118460] = true, -- Engine of Souls (Tomb of Sargeras)
	[122450] = true, -- Garothi Worldbreaker (Antorus the Burning Throne - Confirmed in game)
	[123371] = true, -- Garothi Worldbreaker (Antorus the Burning Throne)
	[122778] = true, -- Annihilator - Garothi Worldbreaker (Antorus the Burning Throne)
	[122773] = true, -- Decimator - Garothi Worldbreaker (Antorus the Burning Throne)
	[122578] = true, -- Kin'garoth (Antorus the Burning Throne - Confirmed in game)
	[125050] = true, -- Kin'garoth (Antorus the Burning Throne)
	[131863] = true, -- Raal the Gluttonous (Waycrest Manor)
	[134691] = true, -- Static-charged Dervish (Temple of Sethraliss)
	[137405] = true, -- Gripping Terror (Siege of Boralus)
	[140447] = true, -- Demolishing Terror (Siege of Boralus)
	[137119] = true, -- Taloc (Uldir1)
	[137578] = true, -- Blood shtorm (Uldir - Taloc's fight)
	[138959] = true, -- Coalesced Blood (Uldir - Taloc's fight)
	[138017] = true, -- Cudgel of Gore (Uldir - Taloc's fight)
	[130217] = true, -- Nazmani Weevil (Uldir - Taloc's fight)
	[140286] = true, -- Uldir Defensive Beam *Uldir)
	[138530] = true, -- Volatile Droplet (Uldir - Taloc's fight)
  	[133392] = true, -- Sethraliss
	[146256] = true, -- Laminaria
	[150773] = true, -- Blackwater Behemoth Mob
	[152364] = true, -- Radiance of Azshara
	[152671] = true, -- Wekemara
	[157602] = true, -- Drest'agath - Ny'alotha
	[158343] = true, -- Organ of Corruption - Ny'alotha
	[166608] = true, -- Mueh'zala - De Other Side
  	[166618] = true, -- Other Side Adds
  	[169769] = true, -- Other Side Adds
  	[171665] = true, -- Other Side Adds
  	[168326] = true, -- Other Side Adds
	[164407] = true, -- Sludgefist - Castle Nathria
	[165759] = true, -- Kaelthas
	[181399] = true, -- Kin'tessa - Lords of Dread
	[181398] = true, -- Mal'Ganis - Lords of Dread
	[183138] = true, -- Shadowboi add in Lords of Dread
	[91005] = true,
	[28859] = true,
	[199790] = true,
	[187967] = true, -- https://www.wowhead.com/beta/npc=187967/sennarth
	[190245] = true, -- https://www.wowhead.com/npc=190245/broodkeeper-diurna
	[44566] = true, -- Ozumat (TW)
	[44752] = true, -- Faceless Sapper (TW)
	[208478] = true, -- Volcoross
}

blink.totemIDs = {
	-- retail
  	107100,   	--Observer
	101398,		--Psyfiend
	119052,		--War Banner
	104818,		--Ancestral Protection Totem
	53006,		--Spirit Link Totem
	2630,		--Earthbind Totem
	60561,		--Earthgrab Totem
	61245,		--Capacitor Totem 
	5925,		--Grounding Totem
	105425,		--Skyfury Totem
	105427,		--Skyfury Totem
	5913,		--Tremor Totem
	105451,		--Counterstrike Totem
	6112,		--Windfury Totem
	59764,  	--Healing Tide
	166523,		--Vesper Totem
	179867, 	--Static Field Totem
	179193,		--Fel Obelisk
	5923, 		-- Poison Cleansing Totem
	194117, 	-- Stoneskin Totem,
	194118, 	-- Tranquil Air Totem, 
	3527, 		-- Healing Stream Totem, 
	193620, 	-- Mana Spring Totem,
	10467, 		-- Mana Tide Totem
	100943,		-- Earthen Wall Totem
}

if WOTLK then
	extend(blink.totemIDs, {
		5913, 		-- Tremor
		30653, 		-- Wrath
		15485, 		-- Flametongue
		15447, 		-- Wrath of Air
		6112, 		-- Windfury
		15479, 		-- Strength
		15474, 		-- Stoneskin
		15489, 		-- Mana
		15488, 		-- Healing
		5924, 		-- Cleansing
		10467, 		-- Mana Tide
		15484, 		-- Magma
		15480, 		-- Searing
	})
end

blink.channelSpells = {
    [234153] = "Drain Life",
    [198590] = "Drain Soul",
    [115175] = "Soothing Mist",
    [305483] = "Lightning Lasso",
    [191837] = "Essence Font",
    [740] = "Tranquility",
    [5143] = "Arcane Missiles",
    [47540] = "Penance",
    [12051] = "Evocation",
    [48045] = "Mind Sear",
    [15407] = "Mind Flay",
    [263165] = "Void Torrent",
    [391528] = "Convoke the Spirits",
	[64901] = "Symbol of Hope",
    [64843] = "Divine Hymn",
	[314791] = "Shifting Power",
	[400169] = "Dark Reprimand",
}

blink.interruptingSpells = {
	[369411] = true, -- Sonic Burst https://www.wowhead.com/spell=369411
	[397892] = true, -- Scream of Pain https://www.wowhead.com/spell=397892
	[196543] = true, -- Unnerving Howl https://www.wowhead.com/spell=196543
	[377004] = true, -- Deafening Screech https://www.wowhead.com/spell=377004
	[199726] = true, -- Unruly Yell https://www.wowhead.com/spell=199726
	[381516] = true, -- Interrupting Cloudburst https://www.wowhead.com/spell=381516
}

blink.specIdToString = {
	-- Death Knight
	[250] = "Blood", -- Blood
	[251] = "Frost", -- Frost
	[252] = "Unholy", -- Unholy
	-- Demon Hunter
	[577] = "Havoc", -- Havoc
	[581] = "Vengeance", -- Vengeance
	-- Druid
	[102] = "Balance", -- Balance
	[103] = "Feral", -- Feral
	[104] = "Guardian", -- Guardian
	[105] = "Restoration", -- Restoration
	-- Hunter
	[253] = "Beast Mastery", -- Beast Mastery
	[254] = "Marksmanship", -- Marksmanship
	[255] = "Survival", -- Survival
	-- Mage
	[62] = "Arcane", -- Arcane
	[63] = "Fire", -- Fire
	[64] = "Frost", -- Frost
	-- Monk
	[268] = "Brewmaster", -- Brewmaster
	[269] = "Windwalker", -- Windwalker
	[270] = "Mistweaver", -- Mistweaver
	-- Paladin
	[65] = "Holy", -- Holy
	[66] = "Protection", -- Protection
	[70] = "Retribution", -- Retribution
	-- Priest
	[256] = "Discipline", -- Discipline
	[257] = "Holy", -- Holy
	[258] = "Shadow", -- Shadow
	-- Rogue
	[259] = "Assassination", -- Assassination
	[260] = "Outlaw", -- Combat
	[261] = "Subtlety", -- Subtlety
	-- Shaman
	[262] = "Elemental", -- Elemental
	[263] = "Enhancement", -- Enhancement
	[264] = "Restoration", -- Restoration
	-- Warlock
	[265] = "Affliction", -- Affliction
	[266] = "Demonology", -- Demonology
	[267] = "Destruction", -- Destruction
	-- Warrior
	[71] = "Arms", -- Arms
	[72] = "Fury", -- Fury
	[73] = "Protection", -- Protection
	-- Evoker
	[1473] = "Augmentation", -- Augmentation
	[1467] = "Devastation", -- Devastation
	[1468] = "Preservation" -- Preservation
}

blink.ObjectIDs = {
	LosExceptions = {
		[115406] = true,
		[115844] = true,
		[144249] = true,
		[150222] = true,
		[150397] = true,
		[164267] = true,
		[164407] = true,
		[164517] = true,
		[164558] = true,
		[165759] = true,
		[166473] = true,
		[166608] = true,
		[166618] = true,
		[168326] = true,
		[169769] = true,
		[171665] = true,
		[174565] = true,
		[175546] = true,
		[175725] = true,
		[176531] = true,
		[176581] = true,
		[176920] = true,
		[177286] = true,
		[178270] = true,
		[179733] = true,
		[180018] = true,
		[181398] = true,
		[181399] = true,
		[183138] = true,
		[91005] = true,
		[28859] = true,
		[199790] = true,
		[187967] = true, -- https://www.wowhead.com/beta/npc=187967/sennarth
		[190245] = true, -- https://www.wowhead.com/npc=190245/broodkeeper-diurna
		[44566] = true, -- Ozumat (TW)
		[44752] = true, -- Faceless Sapper (TW)
		[208478] = true, -- Volcoross
		[98696] = true, -- Illysanna Ravencrest
		[131863] = true, -- Raal the Gluttonous (Waycrest Manor)
	},
	CombatExceptions = {
		[115406] = true,
		[144249] = true,
		[164267] = true,
		[164558] = true,
		[165189] = true,
		[166473] = true,
		[166608] = true,
		[168326] = true,
		[168969] = true,
		[171887] = true,
		[175861] = true,
		[176581] = true,
		[176605] = true,
		[176920] = true,
		[177594] = true,
		[178008] = true,
		[179733] = true,
		[179963] = true,
		[183745] = true,
		[331618] = true,
		[77803] = true,
		[381470] = true, -- Hextrick Totem
		[186696] = true, -- Quaking Totem
		[190381] = true, -- Rotburst Totem
		[193352] = true, -- Hextrick Totem
		[195138] = true, -- Detonating Crystal
		[199368] = true, -- Hardened Detonating Crystal
		[192955] = true, -- Draconic Illusion
		[190187] = true, -- Draconic Image
		[194897] = true, -- Stormsurge Totem
		[193799] = true, -- Rotchanting Totem
		[196043] = true, -- Primalist Infuser
		--[195579] = true, -- Primal Gust
		[195821] = true, -- Nokhud Saboteur
		[195580] = true, -- Nokhud Saboteur
		[195820] = true, -- Nokhud Saboteur
		[196642] = true, -- Hungry Lasher
		[104822] = true, -- Flame of Woe
		[102019] = true, -- Stormforged Obliterator
		[101326] = true, -- Honored Ancestor
		[76518] = true, -- Ritual of Bones
		[75966] = true, -- Defiled Spirit
		[75899] = true, -- Possessed Soul
		[190174] = true, -- Hypnosis Bat
		[188026] = true, -- Frost Tomb
		[199790] = true, -- Kyrakka
		[44566] = true, -- Ozumat (TW)
		[44752] = true, -- Faceless Sapper (TW)
		[203230] = true, -- https://www.wowhead.com/npc=203230/dragonfire-golem
		[100818] = true, -- https://www.wowhead.com/npc=100818/bellowing-idol
		[125828] = true, -- Soulspawn
	},
	UnitBlacklist = {
		[200948] = true, -- Nokhud Last Boss Battlefield
		[200944] = true, -- Nokhud Last Boss Battlefield
		[200945] = true, -- Nokhud Last Boss Battlefield
		[127019] = true, -- Freehold Training Dummy
	},
	Dummies = {
		[219250] = true,
		[225982] = true,
		[225982] = true,
		[225976] = true,
		[225977] = true,
		[225983] = true,
		[225984] = true,
		[225985] = true,
		[225978] = true,

		[100440] = true,
		[100441] = true,
		[100648] = true,
		[101824] = true,
		[101956] = true,
		[102045] = true,
		[102048] = true,
		[102052] = true,
		[102995] = true,
		[103397] = true,
		[103402] = true,
		[103404] = true,
		[104530] = true,
		[104770] = true,
		[105272] = true,
		[105273] = true,
		[105274] = true,
		[105275] = true,
		[105276] = true,
		[105277] = true,
		[105278] = true,
		[107104] = true,
		[107202] = true,
		[107427] = true,
		[107428] = true,
		[107429] = true,
		[107430] = true,
		[107483] = true,
		[107484] = true,
		[107555] = true,
		[107556] = true,
		[107557] = true,
		[107577] = true,
		[107580] = true,
		[107581] = true,
		[108420] = true,
		[109066] = true,
		[109067] = true,
		[109084] = true,
		[109090] = true,
		[109091] = true,
		[109092] = true,
		[109093] = true,
		[109094] = true,
		[109095] = true,
		[109096] = true,
		[109097] = true,
		[109595] = true,
		[109963] = true,
		[111385] = true,
		[111824] = true,
		[112439] = true,
		[112672] = true,
		[113636] = true,
		[113674] = true,
		[113676] = true,
		[113687] = true,
		[113858] = true,
		[113859] = true,
		[113860] = true,
		[113862] = true,
		[113863] = true,
		[113864] = true,
		[113871] = true,
		[113963] = true,
		[113964] = true,
		[113966] = true,
		[113967] = true,
		[114749] = true,
		[114832] = true,
		[114840] = true,
		[115898] = true,
		[115899] = true,
		[11875] = true,
		[122327] = true,
		[12385] = true,
		[12426] = true,
		[126712] = true,
		[126781] = true,
		[127019] = true,
		[131975] = true,
		[131983] = true,
		[131985] = true,
		[131989] = true,
		[131990] = true,
		[131992] = true,
		[131994] = true,
		[131997] = true,
		[131998] = true,
		[132036] = true,
		[132976] = true,
		[134324] = true,
		[13619] = true,
		[136640] = true,
		[138048] = true,
		[143119] = true,
		[143509] = true,
		[143947] = true,
		[144074] = true,
		[144075] = true,
		[144076] = true,
		[144077] = true,
		[144078] = true,
		[144079] = true,
		[144080] = true,
		[144081] = true,
		[144082] = true,
		[144083] = true,
		[144085] = true,
		[144086] = true,
		[144986] = true,
		[149860] = true,
		[151022] = true,
		[153285] = true,
		[153292] = true,
		[154564] = true,
		[154567] = true,
		[154580] = true,
		[154583] = true,
		[154585] = true,
		[154586] = true,
		[160325] = true,
		[160737] = true,
		[161840] = true,
		[16211] = true,
		[165012] = true,
		[171937] = true,
		[173919] = true,
		[173942] = true,
		[173954] = true,
		[173955] = true,
		[173957] = true,
		[174484] = true,
		[174487] = true,
		[174488] = true,
		[174489] = true,
		[174491] = true,
		[174565] = true,
		[174566] = true,
		[174567] = true,
		[174568] = true,
		[174569] = true,
		[174570] = true,
		[174571] = true,
		[174954] = true,
		[174978] = true,
		[175015] = true,
		[175449] = true,
		[175450] = true,
		[175451] = true,
		[175452] = true,
		[175455] = true,
		[175456] = true,
		[17578] = true,
		[180544] = true,
		[180674] = true,
		[184083] = true,
		[189082] = true,
		[19139] = true,
		[1921] = true,
		[193563] = true,
		[194643] = true,
		[194644] = true,
		[194645] = true,
		[194646] = true,
		[194648] = true,
		[198594] = true,
		[194649] = true,
		[197833] = true,
		[197834] = true,
		[199026] = true,
		[24792] = true,
		[25225] = true,
		[25297] = true,
		[2673] = true,
		[2674] = true,
		[30527] = true,
		[31144] = true,
		[31146] = true,
		[32541] = true,
		[32542] = true,
		[32543] = true,
		[32545] = true,
		[32546] = true,
		[32666] = true,
		[32667] = true,
		[36529] = true,
		[44171] = true,
		[44389] = true,
		[44548] = true,
		[44614] = true,
		[44703] = true,
		[44794] = true,
		[44820] = true,
		[44848] = true,
		[44937] = true,
		[46647] = true,
		[48304] = true,
		[4952] = true,
		[4957] = true,
		[5652] = true,
		[5723] = true,
		[59245] = true,
		[59246] = true,
		[59247] = true,
		[59248] = true,
		[59249] = true,
		[59250] = true,
		[60197] = true,
		[64446] = true,
		[65310] = true,
		[66374] = true,
		[67127] = true,
		[70057] = true,
		[70245] = true,
		[76192] = true,
		[76193] = true,
		[76194] = true,
		[78984] = true,
		[79414] = true,
		[79786] = true,
		[79787] = true,
		[79788] = true,
		[83545] = true,
		[83546] = true,
		[83547] = true,
		[83552] = true,
		[83558] = true,
		[83565] = true,
		[83571] = true,
		[83573] = true,
		[83574] = true,
		[83576] = true,
		[87317] = true,
		[87318] = true,
		[87320] = true,
		[87321] = true,
		[87322] = true,
		[87329] = true,
		[87760] = true,
		[87761] = true,
		[87762] = true,
		[88288] = true,
		[88289] = true,
		[88314] = true,
		[88316] = true,
		[88835] = true,
		[88836] = true,
		[88837] = true,
		[88906] = true,
		[88967] = true,
		[89078] = true,
		[89321] = true,
		[92164] = true,
		[92165] = true,
		[92166] = true,
		[92167] = true,
		[92168] = true,
		[92169] = true,
		[93828] = true,
		[94457] = true,
		[96442] = true,
		[97668] = true,
		[98581] = true,
		[79987] = true,
		[189632] = true,
		[189617] = true,
	},
	ArenaUnitBlacklist = {
		[114569] = true,
		[114572] = true,
		[114573] = true,
		[114574] = true,
		[114575] = true,
		[114577] = true,
		[114578] = true,
		[114579] = true,
		[114580] = true,
		[114581] = true,
		[114611] = true,
		[114925] = true,
		[115068] = true,
		[115069] = true,
		[115070] = true,
		[115076] = true,
		[115077] = true,
		[115083] = true,
		[115086] = true,
		[115087] = true,
		[115091] = true,
		[115093] = true,
		[115097] = true,
		[115107] = true,
		[115109] = true,
		[117078] = true,
		[134955] = true,
		[137530] = true,
		[138894] = true,
		[138899] = true,
		[139060] = true,
		[139068] = true,
		[141184] = true,
		[143121] = true,
		[143122] = true,
		[143126] = true,
		[143133] = true,
		[143134] = true,
		[143245] = true,
		[169468] = true,
		[188479] = true,
		[196472] = true,
		[15214] = true,
		[23472] = true,
		[28567] = true,
	},
	ImmuneCCUnits = {
		[186739] = true,
		[186151] = true,
		[193535] = true,
		[193532] = true,
		[184018] = true,
		[190245] = true,
		[189340] = true,
		[184125] = true,
		[191736] = true,
		[189813] = true,
		[186121] = true,
		[190609] = true,
		[184422] = true,
		[184972] = true,
		[189478] = true,
		[186616] = true,
		[189722] = true,
		[186116] = true,
		[187771] = true,
		[189727] = true,
		[189232] = true,
		[184986] = true,
		[193435] = true,
		[186644] = true,
		[193533] = true,
		[181861] = true,
		[188252] = true,
		[196482] = true,
		[189729] = true,
		[186122] = true,
		[184124] = true,
		[193534] = true,
		[195723] = true,
		[197025] = true,
		[190496] = true,
		[186615] = true,
		[186120] = true,
		[186738] = true,
		[194181] = true,
		[189901] = true,
		[189719] = true,
	}
}
