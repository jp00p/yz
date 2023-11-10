extends Control

@onready var button = %Button
var entity : Entity = null

func _ready() -> void:
    Globals.toggle_roll_button_state.connect(set_state)

func set_state(state="") -> void:
    print("Setting roll button state to %s" % state)
    if state == "disabled":
        button.disabled = true
    else:
        button.disabled = false

func _on_button_pressed() -> void:
    # tell the rest of the game who just rolled
    Globals.roll_dice.emit(entity)
