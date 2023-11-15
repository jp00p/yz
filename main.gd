extends Control

# the main game screen
# ------------------------------------
# this file should mostly handle UI
# and connecting signals

@onready var popup = preload("res://ui/popup.tscn")
@onready var level_select = preload("res://ui/next_level.tscn")
@onready var dice_combo = preload("res://ui/dice_combo_container.tscn")
@onready var combat_panel = preload("res://ui/combat.tscn")
@onready var dice_tray = preload("res://ui/dice_tray.tscn")

@onready var all_elements = %Elements
@onready var event_ui = %EventUI
@onready var player_ui = %PlayerUI
@onready var dice_ui = %DiceUI
@onready var roll_button_ui = %RollButtonUI
@onready var spellbook_ui = %SpellbookUI
@onready var background = %BGFrame

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

var player:Player = null
var current_event = null
var player_spellbook = null
var player_dice_tray = null
var player_roll_button = null

var player_shake = 0
var player_default_pos = Vector2.ZERO

var event_shake = 0
var event_default_pos = Vector2.ZERO

func _ready():
    hide_starting_elements()
    load_player()
    SignalBus.shake_panel.connect(shake_ui)
    SignalBus.reset_panels.connect(reset_shake)
    SignalBus.create_floating_text.connect(add_floating_text_ui)
    SignalBus.add_dice_tray.connect(create_dice_tray)
    player_default_pos = player_ui.global_position
    event_default_pos = event_ui.global_position
    await get_tree().create_timer(2).timeout
    set_state(GAME_STATE.COMBAT)
    show_all_elements()

func hide_starting_elements():
    get_tree().call_group("DebugUI", "queue_free")
    roll_button_ui.visible = false
    all_elements.visible = false
    background.visible = false
    player_ui.visible = false
    set_bg_shader_dissolve(0.0)
    set_elements_shader_dissolve(0.0)

func show_all_elements():
    all_elements.visible = true
    background.visible = true
    player_ui.visible = true
    var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT_IN)
    tween.tween_method(set_bg_shader_dissolve, 0.0, 1.0, 0.5)
    tween.tween_method(set_elements_shader_dissolve, 0.0, 1.0, 1.0)
    return tween

func set_bg_shader_dissolve(val:float):
    (background.image.material as ShaderMaterial).set_shader_parameter("dissolve_value", val)

func set_elements_shader_dissolve(val:float):
    (all_elements.material as ShaderMaterial).set_shader_parameter("dissolve_value", val)

func set_state(new_state=null):
    state = new_state
    player_default_pos = player_ui.global_position
    event_default_pos = event_ui.global_position

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
    pass
    #roll_button.disabled = false

func enable_player_input():
    pass
    #roll_button.disabled = false

func disable_player_input():
    #roll_button.disabled = true
    player.disable_dice()

func create_dice_tray(whose):
    # create dice tray and assign to entity
    var dice_tray = Globals.DICE_TRAY.instantiate()
    dice_tray.entity = whose
    dice_ui.add_child(dice_tray)

func shake_ui(which_panel):
    print("Shaking %s" % which_panel)
    if which_panel == "Event":
        event_shake = 5
    else:
        player_shake = 5

func _process(_delta):
    if player_shake > 0:
        player_shake *= 0.9
        var new_pos = player_ui.global_position + Vector2(randf_range(-player_shake, player_shake), randf_range(-player_shake, player_shake))
        player_ui.set_global_position(new_pos)

    if event_shake > 0:
        event_shake *= 0.9
        var new_pos = event_ui.global_position + Vector2(randf_range(-event_shake, event_shake),randf_range(-event_shake, event_shake))
        event_ui.set_global_position(new_pos)

func start_new_combat(enemy_name=""):
    var new_combat = combat_panel.instantiate()
    new_combat.enemy_name = enemy_name
    new_combat.enable_player_input.connect(enable_player_input)
    new_combat.disable_player_input.connect(disable_player_input)
    new_combat.enemy_turn_complete.connect(enemy_turn_complete)
    new_combat.player_turn_complete.connect(player_turn_complete)
    new_combat.combat_complete.connect(show_battle_complete)
    event_ui.add_child(new_combat)
    current_event = new_combat
    await show_all_elements().finished
    roll_button_ui.visible = true

func show_battle_complete():
    for n in event_ui.get_children():
        n.queue_free()
    for n in dice_ui.get_children():
        n.queue_free()
    var battle_complete = popup.instantiate()
    battle_complete.popup_closed.connect(show_next_level_options)
    add_child(battle_complete)
    await battle_complete.show_popup()

func enemy_turn_complete():
    pass #dice_tray.hide()

func player_turn_complete():
    pass
    # Globals.spellbook.disable()

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
    set_state(GAME_STATE.BATTLE_COMPLETE)

func player_died():
    set_state(GAME_STATE.GAME_OVER)

func load_player():
    player = Globals.player
    player.died.connect(player_died)
    player_ui.add_child(Globals.player_stats)
    spellbook_ui.add_child(Globals.spellbook)
    roll_button_ui.add_child(Globals.roll_button)

func show_player_spells():
    Globals.spellbook.enable()


func add_floating_text_ui(floating_text:FloatingText):
    $Floaters.add_child(floating_text)
    floating_text.float_away()
