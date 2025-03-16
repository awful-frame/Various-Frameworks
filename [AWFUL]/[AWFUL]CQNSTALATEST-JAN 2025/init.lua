local Unlocker, awful, project = ...



project.settings = {}
project.subscription = {}
project.util = {}


project.util.id = {}
project.util.objects = {}
project.util.spell = {}
project.util.spells = {}

project.util.spells.items = {}
project.util.spells.racials = {}

project.util.spells.defensive = {}
project.util.spells.offensive = {}

project.util.debug = {}
project.util.debug.alert = {}

project.util.best_target = {}

project.util.cast = {}
project.util.cast.block = {}
project.util.cast.overlap = {}
project.util.cast.options = {}

project.util.thresholds = {}

project.util.check = {}
project.util.check.scenario = {}
project.util.check.target = {}
project.util.check.player = {}
project.util.check.enemy = {}

project.util.scan = {}

project.util.enemy = {}
project.util.enemy.target = {}
project.util.enemy.best_target = {}
project.util.enemy.best_target.attackers = {}
project.util.enemy.best_target.defensives = {}

project.util.friend = {}
project.util.friend.best_target = {}
project.util.friend.best_target.attackers = {}
project.util.friend.best_target.defensives = {}


project.util.cc = {}

project.util.draw = {}
project.util.draw.unit = {}
project.util.draw.unit.circle = {}

project.util.totems = {}

project.util.evade = {}
project.util.cc = {}

project.util.interrupt = {}
project.util.party_damage = {}
project.util.tank_buster = {}
project.util.pve_debuffs = {}
project.util.dbm_bars = {}

project.util.dispel = {}
project.util.dispel.magic = {}

project.util.racials = {}

project.priest = {}
project.priest.spells = {}
project.priest.discipline = awful.Actor:New({ spec = 1, class = "priest" })
project.priest.discipline.rotation = {}
project.priest.discipline.rotation.util = {}