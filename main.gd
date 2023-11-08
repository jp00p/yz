extends Control

@onready var popup = preload("res://ui/popup.tscn")
@onready var level_select = preload("res://ui/next_level.tscn")
@onready var dice_combo = preload("res://ui/dice_combo_container.tscn")
@onready var combat_panel = preload("res://ui/combat.tscn")

@onready var dice_tray = $DiceUI/DiceTray
@onready var dice_cup = $DiceUI/DiceCup
@onready var roll_button = $DiceUI/RollButton/NinePatchRect/Button
@onready var roll_counter = $DiceUI/RollText
@onready var spell_options = $DiceUI/SpellOptions
@onready var spell_combos = $DiceUI/SpellOptions/Combos

@onready var event_ui = $EventUI
@onready var event_holder = $EventUI/MarginContainer
@onready var player_ui = $PlayerUI
@onready var player_details = $PlayerUI/MarginContainer/HBoxContainer/PlayerDetails

enum GAME_STATE {
    BATTLE_BEGIN,
    BATTLE_ACTIVE,
    BATTLE_COMPLETE,
    COMBAT,
    END_OF_COMBAT,
    WAITING_TO_MOVE,
    SHOPPING,
    RESTING,
    EVENT_ACTIVE,
    EVENT_COMPLETE,
    GAME_OVER
}

var state = null
var all_dice = []

var player:Player = null
var current_event = null
var player_spellbook = null

var player_shake = 0
var player_shake_mag = 10
var player_pos = Vector2.ZERO
var player_default_pos = Vector2.ZERO

var event_shake = 0
var event_pos = Vector2.ZERO
var event_default_pos = Vector2.ZERO

func _ready():
    dice_tray.visible = false
    load_player()
    Globals.shake_panel.connect(shake_ui)
    Globals.reset_panels.connect(reset_shake)
    Globals.create_floating_text.connect(add_floating_text_ui)
    player_default_pos = player_ui.global_position
    event_default_pos = event_ui.global_position
    set_state(GAME_STATE.COMBAT)

func set_state(new_state=null):
    state = new_state
    match state:
        GAME_STATE.WAITING_TO_MOVE:
            pass
        GAME_STATE.COMBAT:
            start_new_combat("Witch")
        GAME_STATE.GAME_OVER:
            print("Game over!")
        GAME_STATE.END_OF_COMBAT:
            show_battle_complete()

func reset_shake():
    print("Resetting shake")
    player_ui.set_global_position(player_default_pos)
    event_ui.set_global_position(event_default_pos)

func reset_combat_data() -> void:
    spell_options.visible = false
    roll_button.disabled = false

func enable_player_input():
    roll_button.disabled = false

func disable_player_input():
    roll_button.disabled = true
    dice_tray.visible = false
    hide_spells()

func hide_spells():
    for s in player_spellbook.get_child(0).get_children():
        s.hide()

func show_spells():
    for s in player_spellbook.get_child(0).get_children():
        s.show()

func shake_ui(which_panel):
    print("Shaking %s" % which_panel)
    if which_panel == "Event":
        event_pos = event_ui.global_position
        event_shake = 18
    else:
        player_pos = player_ui.global_position
        player_shake = 18
    await Utils.wait()

func _process(_delta):
    if player_shake > 0:
        player_shake *= 0.9
        var new_pos = player_pos + Vector2(randf_range(-player_shake, player_shake), randf_range(-player_shake, player_shake))
        player_ui.set_global_position(new_pos)
    if event_shake > 0:
        event_shake *= 0.9
        var new_pos = event_pos + Vector2(randf_range(-event_shake, event_shake),randf_range(-event_shake, event_shake))
        event_ui.set_global_position(new_pos)

func start_new_combat(enemy_name=""):
    var new_combat = combat_panel.instantiate()
    new_combat.player = player
    new_combat.enemy_name = enemy_name
    new_combat.enable_player_input.connect(enable_player_input)
    new_combat.disable_player_input.connect(disable_player_input)
    new_combat.enemy_turn_complete.connect(enemy_turn_complete)
    event_holder.add_child(new_combat)
    current_event = new_combat

func show_battle_complete():
    var battle_complete = popup.instantiate()
    battle_complete.popup_closed.connect(show_next_level_options)
    add_child(battle_complete)
    await battle_complete.show_popup()

func enemy_turn_complete():
    dice_tray.hide()

func show_next_level_options():
    var next_level = level_select.instantiate()
    next_level.level_selected.connect(load_level)
    next_level.popup_closed.connect(next_level.queue_free)
    add_child(next_level)
    await next_level.show_popup()
    set_state(GAME_STATE.WAITING_TO_MOVE)

func load_level(level_type):
    print(level_type)

func enemy_died():
    player.disable_dice()
    set_state(GAME_STATE.BATTLE_COMPLETE)

func player_died():
    player.disable_dice()
    set_state(GAME_STATE.GAME_OVER)

func load_player():
    player = Player.new()
    player.died.connect(player_died)
    add_child(player)
    # load dice
    for d in player.dice:
        dice_tray.add_child(d)

    var player_stats = Globals.ENTITY_STATS.instantiate()
    player_stats.entity = player
    player_details.add_child(player_stats)

    player_spellbook = Globals.SPELLBOOK.instantiate()
    player_spellbook.entity = player
    add_child(player_spellbook)

    # load spells
    for s in player.spellbook.values():
        s.cast_spell.connect(player_cast_spell)

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
    hide_spells()
    if spell.components["dice"].size() > 1:
        show_cast_components(spell)
    else:
        player.cast_spell(spell, current_event.enemy)


func _on_roll_button_pressed():
    dice_tray.show()
    player.rolls += 1
    roll_counter.text = "Roll ~ %s/%s" % [player.rolls, player.max_rolls]
    await get_tree().create_timer(0.25).timeout
    for die in player.dice:
        die.roll()
    var hands = Utils.check_dice_conditions(player.dice) # our final yahtzee "hands"
    player.set_spell_components(hands)
    if player.rolls == player.max_rolls:
        roll_button.disabled = true
        player.prepare_spellbook()
        show_spells()

func add_floating_text_ui(floating_text:FloatingText):
    $Floaters.add_child(floating_text)
    floating_text.float_away()
