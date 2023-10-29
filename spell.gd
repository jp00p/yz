class_name Spell extends NinePatchRect

signal cast_spell(spell:Spell)

@onready var info_panel = $Margin/Info
@onready var spell_label = info_panel.get_node("Label")
@onready var spell_value = info_panel.get_node("Details/Value")
@onready var spell_effect = info_panel.get_node("Details/Effect")
@onready var spell_checkmark = info_panel.get_node("Details/Checkmark")
@onready var spell_details = info_panel.get_node("Details")
@onready var spell_icon = info_panel.get_node("TextureRect")
var points = [] : set = set_points
var label = ""
var hand = ""
var locked = false
var has_cast = false
var icon = "S_Buff07.png"
var components = {}
var effect = Globals.SPELL_EFFECTS.DAMAGE_ENEMY

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	spell_label.text = label
	spell_value.text = str(points)
	#spell_checkmark.visible = false
	spell_icon.texture = load("res://spell_icons/"+icon)
	set_locked(true)

func set_details(spellname):
	label = Globals.all_spells[spellname]["name"]
	hand = spellname
	tooltip_text = spellname
	icon = Globals.all_spells[spellname]["icon"]

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !locked:
			cast_spell.emit(self)
				
func set_locked(state):
	locked = state

func set_points(val):
	# when points are set, they could be a range
	# so we want to show min-max points
	# or just a single number
	if !has_cast:
		points = val
		var points_copy = points.duplicate()
		points_copy.sort()
		if points_copy.size() > 1 and points_copy[0] != points_copy[-1]:
			spell_value.text = str(points_copy[0]) + "-" + str(points_copy[-1])
		else:
			spell_value.text = str(points[0])
