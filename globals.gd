extends Node

@onready var DIE = preload("res://die.tscn")
@onready var SPELL = preload("res://spell.tscn")
@onready var PLAYER = preload("res://player.tscn")
@onready var ENEMY = preload("res://enemy.tscn")

var PLAYER_DICE_RESULTS = []
var ENEMY_DICE_RESULTS = []

enum EVENT_TYPES {
	BATTLE,
	EVENT,
	SHOP,
	REST,
	CHALLENGE
}

enum SPELL_EFFECTS {
	DAMAGE_ENEMY,
	HEAL_SELF
}

var DIE50 = Vector2(50,50)
var DIE30 = Vector2(30,30)

# Colors: ______ BACKGROUND ________ TEXT __________ BORDER _______
var elements = {
	"Basic": [Color("#ffffff"), Color("#333333"), Color("#888888")],
	"Weave": [Color("#ffebbf"), Color("#cc0000"), Color("#ffffff")], 
	"Ruin": [Color("#292225"), Color("#ffffff"), Color("#000000")],
	"Ether": [Color("#669aff"), Color("#ffffff"), Color("#0000ff")],
	"Gaia": [Color("#196357"), Color("#ffffff"), Color("#00ff00")],
	"Flux": [Color("#8e370c"), Color("#ffffff"), Color("#ff0000")],
	#"Oro": [Color("#ffc600"), Color("#444444"), Color("gold")]
}

var all_spells = {
	"Ones": { "name": "Singularity", "icon": "S_Magic01.png", "description": "" }, # sm dmg
	"Twos": { "name": "Bifurcate", "icon": "S_Magic10.png", "description": "" }, # sm dmg + sm heal
	"Threes": { "name": "Tri-wave", "icon": "S_Magic03.png", "description": "" }, # md dmg
	"Fours": { "name": "Fortify", "icon": "S_Buff13.png", "description": "" }, # md heal
	"Fives": { "name": "Pentacle", "icon": "S_Fire08.png", "description": "" }, # md heal + sm dmg
	"Sixes": { "name": "Hex", "icon": "S_Shadow06.png", "description": "" }, # big dmg
	"One pair": { "name": "Duality", "icon": "S_Magic08.png", "description": "" }, #one pair
	"Three of a kind": { "name": "Balance", "icon": "S_Magic06.png", "description": "" }, #three of a kind
	"Four of a kind": { "name": "Bind", "icon": "S_Shadow05.png", "description": "" }, #four of a kind
	"Full house": { "name": "Fusion", "icon": "S_Shadow12.png", "description": "" }, #full house
	"Small straight": { "name": "Melody", "icon": "S_Light03.png", "description": "" }, #sm straight
	"Large straight": { "name": "Aria", "icon": "I_Opal.png", "description": "" }, #lg straight
	"Yahtzee": { "name": "Yahtzara", "icon": "S_Holy08.png", "description": "" }, # yahtzee
	"Chance": { "name": "Wild Magic", "icon": "S_Thunder02.png", "description": "" }, # chance
}

# die material: wood, bone, iron, gold
# magic element: ether, gaia, flux, weave, ruin
# affixes: 
#	# attack dmg: jagged, deadly, viscious,
#	# shield: shimmering, rainbow, prismatic, 
#	# healing: pure, holy, divine

var dice_elements = {
	"Flux": {
		"strong":"",
		"weak":""
	},
	"Ether": {
		"strong":"",
		"weak":""
	},
	"Gaia": {
		"strong":"",
		"weak":""
	},
}

var dice_materials = {
	"Wooden": {
		"description":"",
		"roll_effect":""
	},
	"Bone":{
		"description":"",
		"roll_effect":""
	},
	"Iron":{
		"description":"",
		"roll_effect":""
	},
	"Golden":{
		"description":"",
		"roll_effect":""
	},
	"Meteorite":{
		"description":"",
		"roll_effect":""
	},
	"Crystal":{
		"description":"",
		"roll_effect":""
	},
}

var dice_prefixes = {
	"Might": ["Jagged", "Deadly", "Viscious"], # more damage
	"Shield": ["Shimmering", "Prismatic", "Iridescent"], # helps shield
	"Healing": ["Pure", "Holy", "Divine"], # heals you
	"Evil": ["Evil", "Painful", "Torturous"], # more damage and hurts self
	"Poison": ["Moldy", "Venomous", "Toxic"], # poison
}

func generate_die():
	for i in range(33):
		var element = elements.keys().pick_random()
		var material:String = dice_materials.keys().pick_random().to_lower()
		var prefix_pool = dice_prefixes.keys().pick_random()
		var prefix = dice_prefixes[prefix_pool].pick_random()
		if element == "Basic":
			print("%s %s die" % [prefix, material])
		else:
			print("%s %s die of %s" % [prefix, material, element])

var all_enemies = {
	"Witch" : {
		"challenge":1,
		"hp":30,
		"dice":1,
		"spells":["Ones","Twos","Threes"],
		"weak":["Gaia"],
		"strong":[]
	}
}
