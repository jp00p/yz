extends Node

@onready var DIE = preload("res://objects/die.tscn")
@onready var SPELL_CARD = preload("res://ui/spell.tscn")
@onready var FLOATING_TEXT = preload("res://objects/floating_text.tscn")
@onready var ENTITY_STATS = preload("res://ui/entity_stats.tscn")
@onready var SPELLBOOK = preload("res://ui/spellbook.tscn")
@onready var ROLL_BUTTON = preload("res://ui/roll_button.tscn")
@onready var DICE_TRAY = preload("res://ui/dice_tray.tscn")

var player:Player = null
var player_stats
var roll_button
var spellbook

enum DICE_EFFECTS {
    NONE,
    ADD_POISON, # how many stacks
    ADD_SHIELD, # how much
    ADD_HEALTH, # how much
    HEAL_POISON, # how many stacks
    DAMAGE_ADJUSTMENT, # how much
    score_ADJUSTMENT, # how much
    HURT_SELF, # how much
    HURT_ENEMY, # how much
    ADD_GOLD, # how much
}

var DIE50 = Vector2(50,50)
var DIE30 = Vector2(30,30)

# die material: wood, bone, iron, gold
# magic element: ether, gaia, flux, weave, ruin
# affixes:
#    # attack dmg: jagged, deadly, viscious,
#    # shield: shimmering, rainbow, prismatic,
#    # healing: pure, holy, divine

var dice_elements = {
    "Basic": { # R
        "strong":null,
        "weak":null,
        "description":null,
        "colors":{
            "background":Color("#ffffff"),
            "foreground":Color("#000000"),
            "border":Color("#000000")
        },
        "roll_effect":null
    },
    "Flux": { # R
        "strong":"Gaia",
        "weak":"Ether",
        "description":"Fire and lightning. Weak against Ether",
        "colors":{
            "background":Color("Orange"),
            "foreground":Color("Yellow"),
            "border":Color("Orchid")
        },
        "roll_effect":null
    },
    "Ether": { # P
        "strong":"Flux",
        "weak":"Gaia",
        "description":"Water and air. Weak against Gaia",
        "colors":{
            "background":Color("Light Sky Blue"),
            "foreground":Color("Medium Blue"),
            "border":Color("Medium Aquamarine")
        },
        "roll_effect":null
    },
    "Gaia": { # S
        "strong":"Ether",
        "weak":"Flux",
        "description":"Earth and metals. Weak against Flux",
        "colors":{
            "background":Color("Web Green"),
            "foreground":Color("Green"),
            "border":Color("Dark Khaki")
        },
        "roll_effect":null
    },
}

var dice_materials = {
    "Wooden": {
        "description":"A basic hand-carved die",
        "roll_effect":null
    },
    "Porcelein": {
        "description":"A nicely-made die.",
        "roll_effect":null
    },
    "Bone":{
        "description":"A morbid die made of human bone. Doubles poison effects",
        "roll_effect":null
    },
    "Iron":{
        "description":"A heavy weighted die. Doubles shield effects.",
        "roll_effect":null
    },
    "Golden":{
        "description":"A die made of pure gold. Gives you gold each roll.",
        "roll_effect":null
    },
    "Meteorite":{
        "description":"Carved from a weird rock. Has unpredictable effects.",
        "roll_effect":null
    },
    "Crystal":{
        "description":"Clear and beautiful. Adds shield each roll.",
        "roll_effect":null
    },
}

var dice_prefixes : Dictionary = {
    "Jagged":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.DAMAGE_ADJUSTMENT,
        "effect_params":["v + 1"]
    },
    "Deadly":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.DAMAGE_ADJUSTMENT,
        "effect_params":["v * 1.5"]
    },
    "Viscious":{
        "description":"Hurts a lot more",
        "roll_effect":DICE_EFFECTS.DAMAGE_ADJUSTMENT,
        "effect_params":["v * 2"]
    },
    "Shimmering":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_SHIELD,
        "effect_params":[1]
    },
    "Prismatic":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_SHIELD,
        "effect_params":[2]
    },
    "Iridescent":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_SHIELD,
        "effect_params":[3]
    },
    "Pure":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_HEALTH,
        "effect_params":["1"]
    },
    "Holy":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_HEALTH,
        "effect_params":["v"]
    },
    "Divine":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_HEALTH,
        "effect_params":["v+2"]
    },

    "Evil":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.HURT_SELF,
        "effect_params":["v * 2", "v / 2"]
    },
    "Painful":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.HURT_SELF,
        "effect_params":["v * 3", "v"]
    },
    "Torturous":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.HURT_SELF,
        "effect_params":["v * 4", "v * 2"]
    },
    "Moldy":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_POISON,
        "effect_params":[1]
    },
    "Venomous":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_POISON,
        "effect_params":[2]
    },
    "Toxic":{
        "description":"Hurts a bit more",
        "roll_effect":DICE_EFFECTS.ADD_POISON,
        "effect_params":[3]
    },
}


func _ready():
    player = Player.new()
    add_child(player)
    player_stats = ENTITY_STATS.instantiate()
    player_stats.entity = player

    spellbook = SPELLBOOK.instantiate()
    spellbook.entity = player

    roll_button = ROLL_BUTTON.instantiate()
    roll_button.entity = player


func new_floating_text(location:Vector2, text:String):
    var floating_text = FLOATING_TEXT.instantiate()
    floating_text.text_location = location
    floating_text.text_value = text
    self.create_floating_text.emit(floating_text)

