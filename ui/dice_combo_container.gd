extends ColorRect

signal combo_selected

@onready var dice_holder = %Dices

var spell:Spell
var dice:Array= []
var score = 0

func _ready():
    for d in dice:
        var die_proxy = d.clone()
        dice_holder.add_child(die_proxy)

func _on_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            spell.components = [{"dice": dice, "score": score }]
            spell.cast_spell.emit(spell)
            combo_selected.emit()

func _on_mouse_entered():
    color.a = 0.5

func _on_mouse_exited():
    color.a = 0
