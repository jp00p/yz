class_name Entity extends Node2D

signal hp_changed
signal shield_changed
signal died

var hp :int = 1 : set = set_hp
var max_hp :int = 1
var max_shield :int = 0
var shield :int = max_shield : set = set_shield
var dice: Array[Die] = []
var spellbook: Dictionary = {}

func _ready():
	pass
	
func take_damage(damage_amount, elements):
	if shield <= 0:
		self.hp = max((self.hp - damage_amount), 0)
	self.shield = max((self.shield - damage_amount), 0)
	
func set_hp(val):
	hp = min(val, max_hp)
	hp_changed.emit()
	if hp <= 0:
		died.emit()
	
func set_shield(val):
	shield = min(val, max_shield)
	shield_changed.emit()

func create_initial_dice() -> Array:
	# load initial five dice
	add_dice(5)
	return dice
	
func add_spell(spellname) -> Spell:
	# add spell to spellbook
	# returns spell object
	if spellname not in Globals.all_spells.keys():
		return
	var new_spell = Globals.SPELL.instantiate()
	new_spell.set_details(spellname)
	spellbook[spellname] = new_spell
	return new_spell

func list_spells(only_available_spells=false) -> Array:
	# returns array of spells
	# pass "true" to only return spells that haven't been cast yet
	if not only_available_spells:
		return spellbook.keys()
	var available_spells = []
	for spell in spellbook:
		if not spell.has_cast:
			available_spells.append(spell)
	return available_spells

func add_dice(num_dice=1):
	for d in range(num_dice):
		var new_die = Globals.DIE.instantiate()
		self.dice.append(new_die)

func roll_dice():
	for d in dice:
		d.roll()
	return dice
