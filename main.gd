extends Control

@onready var dice_combo = preload("res://dice_combo_container.tscn")

@onready var ring_holder = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails/PlayerRings/Rings
@onready var spell_holder = $PlayerUI/MarginContainer/HBoxContainer/PlayerSpellbook/Spells

@onready var shield_graphic = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails/PlayerShield/ShieldGraphic
@onready var main_shield = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails/PlayerShield/MainShield
@onready var flux_shield = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails/PlayerShield/Elementals/Flux
@onready var gaia_shield = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails/PlayerShield/Elementals/Gaia
@onready var ether_shield = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails/PlayerShield/Elementals/Ether

@onready var dice_tray = $DiceUI/DiceTray
@onready var dice_cup = $DiceUI/DiceCup
@onready var roll_button = $DiceUI/RollButton/NinePatchRect/Button
@onready var turn_counter = $DiceUI/RollText
@onready var spell_options = $DiceUI/SpellOptions
@onready var spell_combos = $DiceUI/SpellOptions/Combos

@onready var event_ui = $EventUI
@onready var player_ui = $PlayerUI

@onready var monster_name = $EventUI/MarginContainer/Monster/MonsterDetails/Ribbon/MonsterName
@onready var monster_graphic = $EventUI/MarginContainer/Monster/GraphicHolder/Graphic
@onready var monster_health = $EventUI/MarginContainer/Monster/MonsterDetails/Health
@onready var monster_dice_tray = $EventUI/MarginContainer/Monster/MonsterDiceTray

enum GAME_STATE {
	BATTLE_BEGIN,
	BATTLE_ACTIVE,
	BATTLE_COMPLETE,
	WAITING_TO_MOVE,
	SHOPPING,
	RESTING	
}
var state = null
var all_dice = []
var results = [1,1,1,1,1]
var turn :int = 0
var max_turns :int = 3
var max_dice :int = 5
var end_round :bool = false

var player:Player = null 
var enemy:Enemy = null

var player_shake = 0
var player_shake_mag = 10
var player_pos = Vector2.ZERO

var event_shake = 0
var event_pos = Vector2.ZERO

signal round_complete

func _ready():
	player = Globals.PLAYER.instantiate()
	add_child(player)
	#set_shield_colors()
	set_state(GAME_STATE.BATTLE_BEGIN)
	

func set_state(new_state=null):
	state = new_state
	match state:
		GAME_STATE.BATTLE_BEGIN:
			reset_combat_data()
			load_player()
			load_enemy("Witch")
			update_turn()
			set_state(GAME_STATE.BATTLE_ACTIVE)
		GAME_STATE.BATTLE_ACTIVE:
			pass
		GAME_STATE.BATTLE_COMPLETE:
			pass
			

func reset_combat_data():
	for d in monster_dice_tray.get_children():
		monster_dice_tray.remove_child(d)
	spell_options.visible = false
	results = []
	roll_button.disabled = false

func new_round():
	enemy_attack()
	spell_holder.visible = false
	round_complete.emit()
	results = []
	roll_button.disabled = false
	reset_dice()
	update_turn()

func update_turn(new_turn=0):
	turn = new_turn
	turn_counter.text = "Turn: %s/%s" % [turn, max_turns]
	if turn == max_turns:
		ready_to_score()

func enemy_attack():
	if enemy.hp > 0:
		var results = enemy.roll_dice()
		var timer = get_tree().create_timer(0.66)
		await timer.timeout
		var monster_y = monster_graphic.global_position.y
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
		tween.tween_method(monster_graphic.set_global_position, monster_graphic.global_position, Vector2(monster_graphic.global_position.x, monster_y-20), 0.33).set_ease(Tween.EASE_OUT)
		tween.tween_method(monster_graphic.set_global_position, monster_graphic.global_position, Vector2(monster_graphic.global_position.x, monster_y+10), 0.25)
		tween.tween_method(monster_graphic.set_global_position, monster_graphic.global_position, Vector2(monster_graphic.global_position.x, monster_y), 0.25)
		tween.tween_callback(shake_player_ui)
		await tween.finished
		player.take_damage(10,0)
		player_ui.set_global_position(player_pos)
		

func shake_event_ui():
	event_pos = event_ui.global_position
	event_shake = 18
	
func shake_player_ui():
	player_pos = player_ui.global_position
	player_shake = 18
	
func _process(delta):
	if player_shake > 0:
		player_shake *= 0.9
		var new_pos = player_pos + Vector2(randf_range(-player_shake, player_shake), randf_range(-player_shake, player_shake))
		player_ui.set_global_position(new_pos)
	if event_shake > 0:
		event_shake *= 0.9
		var new_pos = event_pos + Vector2(randf_range(-event_shake, event_shake),randf_range(-event_shake, event_shake))
		event_ui.set_global_position(new_pos)

func reset_dice():
	for d in player.dice:
		d.has_rolled = false
		d.unlock()
	for d in enemy.dice:
		d.has_rolled = false
		d.unlock()

func load_enemy(enemy_name=""):
	enemy = Globals.ENEMY.instantiate()
	enemy.enemy_name = enemy_name
	add_child(enemy)
	monster_name.text = enemy.enemy_name
	monster_health.max_value = enemy.max_hp
	monster_health.value = enemy.max_hp
	monster_graphic.texture = load("res://graphics/enemies/%s.png" % enemy.enemy_name.to_lower())
	for d in enemy.dice:
		monster_dice_tray.add_child(d)
	enemy.hp_changed.connect(set_enemy_healthbar)
	enemy.died.connect(enemy_died)

func enemy_died():
	$EventUI/MarginContainer/Monster/GraphicHolder/MonsterAnimation.play("death")

func set_enemy_healthbar():
	monster_health.value = enemy.hp

func set_shield(amt):
	shield_graphic.get_material().set_shader_parameter("current_mana", amt)

func load_player():
	# load dice
	for d in player.dice:
		dice_tray.add_child(d)
	# load stats
	# load rings
	# load spells
	for s in player.spellbook.values():
		spell_holder.add_child(s)
		s.cast_spell.connect(player_cast_spell)
	set_shield(1)
	player.shield_changed.connect(update_player_shield)

func update_player_shield():
	print(player.shield)
	print(player.max_shield)
	var shield_percent = float(player.shield/player.max_shield)/100
	print(shield_percent)
	set_shield(randf())

func same(a:Array):
	# check if every element in an array is the same
	if a.size() == 0:
		return false
	var first_item = a[0]
	for item in a:
		if item != first_item:
			return false
	return true

func show_cast_components(spell:Spell=null):
	for c in spell_combos.get_children():
		spell_combos.remove_child(c)
	spell_options.visible = true
	for combo in spell.components["dice"]:
		var page = dice_combo.instantiate()
		page.dice = combo
		page.spell = spell
		spell_combos.add_child(page)

		
func player_cast_spell(spell:Spell=null):
	spell_options.visible = false
	if spell.components["dice"].size() > 1:
		show_cast_components(spell)
	else:
		handle_spell(spell)

func handle_spell(spell:Spell):
	if spell.effect == Globals.SPELL_EFFECTS.DAMAGE_ENEMY:
		var base_damage = spell.components.points[0]
		var element_makeup = []
		for d in spell.components["dice"][0]:
			element_makeup.append([d.element, d.value])
			await d.apply_effects(player, enemy)
		#enemy.take_damage(base_damage, element_makeup)
		shake_event_ui()
	var timer = get_tree().create_timer(0.5)
	await timer.timeout
	event_ui.set_global_position(event_pos)
	new_round()
		

func set_shield_colors():
	var flux_bg = flux_shield.get_theme_stylebox("background")
	var flux_fill = flux_shield.get_theme_stylebox("fill")
	flux_bg.bg_color = Color("Black")
	flux_fill.bg_color = Globals.elements["Flux"][0]
	
	var gaia_bg = gaia_shield.get_theme_stylebox("background")
	var gaia_fill = gaia_shield.get_theme_stylebox("fill")
	gaia_bg.bg_color = Color("Black")
	gaia_fill.bg_color = Globals.elements["Gaia"][0]
	
	var ether_bg = ether_shield.get_theme_stylebox("background")
	var ether_fill = ether_shield.get_theme_stylebox("fill")
	ether_bg.bg_color = Color("Black")
	ether_fill.bg_color = Globals.elements["Ether"][0]


func ready_to_score():
	roll_button.disabled = true
	Globals.PLAYER_DICE_RESULTS = results
	for spell in spell_holder.get_children():
		if !spell.has_cast:
			spell.set_locked(false)

func score_set(scoring_row):
	for spell in spell_holder.get_children():
		spell.set_locked(true)
	new_round()

func _on_roll_button_pressed():
	results = []
	spell_holder.visible = true
	await get_tree().create_timer(0.5).timeout
	for die in player.dice:
		die.roll()
	var hands = check_dice_conditions(player.dice) # our final yahtzee "hands"
	show_valid_spells(hands) # show which spells we can cast
	update_turn(turn+1)

func show_valid_spells(hands):
	for spell in player.spellbook.values():
		spell.visible = false
		if !spell.has_cast:
			if spell.hand in hands.keys() and len(hands[spell.hand]) > 0 and len(hands[spell.hand]["points"]) > 0:
				spell.visible = true
				spell.components = hands[spell.hand]
				spell.points = hands[spell.hand]["points"]
				
			
func sum(arr=[], die=false):
	var total = 0
	for i in arr:
		if not die:
			total += i
		else:
			total += i.value
	return total

func _on_reset_pressed():
	get_tree().reload_current_scene()

func number_to_words(number):
	var units = ["", "one", "two", "three", "four", "five", "sixe", "seven", "eight", "nine"]
	var teens = ["", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
	var tens = ["", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
	
	if number == 0:
		return "zero"
	elif number < 10:
		return units[number]
	elif number < 20:
		return teens[number - 10]
	elif number < 100:
		var ten = number / 10
		var unit = number % 10
		return tens[ten] + ("-" if unit > 0 else "") + units[unit]
	else:
		return "one hundred"  # Adjust this for higher numbers if necessary

func generate_combinations(data, start, length, current_combination, result):
	if current_combination.size() == length:
		result.append(current_combination.duplicate())
		return

	for i in range(start, data.size()):
		current_combination.append(data[i])
		generate_combinations(data, i + 1, length, current_combination, result)
		current_combination.pop_back()

func get_combinations(data, length):
	var result = []
	var current_combination = []
	generate_combinations(data, 0, length, current_combination, result)
	return result

func check_dice_conditions(dice_array):
	var conditions = { # Dictionary to store all valid hands
		"One pair": { "dice": [], "points": [] },
		"Two pair": { "dice": [], "points": [] },
		"Three of a kind":{ "dice": [], "points": [] },
		"Four of a kind":{ "dice": [], "points": [] },
		"Full house":{ "dice": [], "points": [] },
		"Small straight":{ "dice": [], "points": [] },
		"Large straight":{ "dice": [], "points": [] },
		"Yahtzee":{ "dice": [], "points": [] },
		"Chance":{ "dice": [], "points": [] }
	}
	var dice_counts = {}  # Dictionary to store dice values and their counts
	var included_dice = {}  # Dictionary to store included dice for each condition
	
	# Count the occurrences of each dice value
	for dice in dice_array:
		var value = dice.value
		if value not in dice_counts:
			dice_counts[value] = 0
		dice_counts[value] += 1
		if value not in included_dice:
			included_dice[value] = []
		included_dice[value].append(dice)
	
	# Check for one or more of a single number
	# These are worth the sum of the dice with that number
	for value in dice_counts.keys():
		#print(dice_counts[value])
		var count = dice_counts[value]
		if count >= 1:
			var number_label = number_to_words(value).capitalize() + "s"
			conditions[number_label] = { "dice": [], "points": [] }
			var included = []
			for dice in included_dice[value]:
				included.append(dice)
			conditions[number_label]["dice"].append(included)
			conditions[number_label]["points"].append(sum(included, true))
		
	# Check for one pair, two pairs, three of a kind, four of a kind, full house, and Yahtzee
	var pair_values = []
	var three_of_a_kind_values = []

	for value in dice_counts.keys():
		var count = dice_counts[value]
		if count >= 2:
			if count == 2: # is it ONLY one pair?
				pair_values.append(value)
				var included = []
				for dice in included_dice[value]:
					included.append(dice)
				conditions["One pair"]["dice"].append(included)
				conditions["One pair"]["points"].append(included[0].value + included[1].value) # one pair is worth the sum of the pair of dice
			else:
				# otherwise we gotta get all the combination of dice pairs
				var combinations = get_combinations(included_dice[value], 2)
				for combo in combinations:
					if combo.size() > 1:
						conditions["One pair"]["dice"].append(combo)
						conditions["One pair"]["points"].append(combo[0].value + combo[1].value)
		
		if count >= 3:
			three_of_a_kind_values.append(value)
			var combinations = get_combinations(included_dice[value], 3)
			for combo in combinations:
				conditions["Three of a kind"]["dice"].append(combo)
				conditions["Three of a kind"]["points"].append(sum(dice_array, true)) # 3oak is worth all the dice summed up
			
			if count >= 4:
				conditions["Four of a kind"]["dice"].append(included_dice[value])
				conditions["Four of a kind"]["points"].append(sum(dice_array, true)) # 4oak is worth all the dice summed up
				if count == 5:
					conditions["Yahtzee"]["dice"].append(included_dice[value])
					conditions["Yahtzee"]["points"].append(50) # yahtzee is worth 50 points
	
	if pair_values.size() >= 2:
		var combinations = get_combinations(pair_values, 2)
		for combo in combinations:
			
			var included_pairs = []
			for value in combo:
				included_pairs += included_dice[value]
			conditions["Two pair"]["dice"].append(included_pairs) # not using this right now
			
	if three_of_a_kind_values.size() >= 1 and pair_values.size() >= 1:
		var combinations = get_combinations(three_of_a_kind_values, 1)
		var full_house_combinations = get_combinations(pair_values, 1)
		for three_of_a_kind_combo in combinations:
			for pair_combo in full_house_combinations:
				var included_three = []
				var included_two = []
				for value in three_of_a_kind_combo:
					included_three += included_dice[value]
				for value in pair_combo:
					included_two += included_dice[value]
				var all_included_dice = included_three + included_two
				conditions["Full house"]["dice"].append(all_included_dice)
				conditions["Full house"]["points"].append(25)
	
	# Check for all possible small straights
	var distinct_values = dice_counts.keys()
	distinct_values.sort()
	for i in range(len(distinct_values) - 3):
		var is_straight = true
		for j in range(i, i + 4):
			if len(distinct_values) > j + 1:
				if distinct_values[j] + 1 != distinct_values[j + 1]:
					is_straight = false
					break
		
		if is_straight:
			var included = []
			for j in range(i, i + 4):
				included += included_dice[distinct_values[j]]
			conditions["Small straight"]["dice"].append(included)
			conditions["Small straight"]["points"].append(30) # small straight is 30 points
	
	# Check for all possible large straights
	if len(distinct_values) == 5 and distinct_values[4] - distinct_values[0] == 4:
		var included = []
		for value in distinct_values:
			included += included_dice[value]
		conditions["Large straight"]["dice"].append(included)
		conditions["Large straight"]["points"].append(40) # large straight is 40 points
	
	conditions["Chance"]["dice"].append(dice_array)
	conditions["Chance"]["points"].append(sum(dice_array, true))
	
	return conditions
