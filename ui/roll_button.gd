extends Control

@onready var button = %Button
var entity : Entity = null

func _ready() -> void:
    SignalBus.toggle_roll_button_state.connect(set_state)

func set_state(state="") -> void:
    if state == "disabled":
        button.disabled = true
    else:
        button.disabled = false

func _on_button_pressed() -> void:
    # tell the rest of the game who just rolled
    SignalBus.roll_dice.emit(entity)
    button.disabled = true
    await Globals.player.rolled
    button.disabled = false
