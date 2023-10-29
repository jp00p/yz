class_name Die extends ColorRect

@onready var label = $Center/Label
@onready var border = $Border
@onready var level_up_options = preload("res://level_up.tscn")
var faces = 6
var held = false
var locked = false
var value = 1
var xp = 0
var level = 1
var ready_to_level = false
var level_up_options_visible = false
var has_rolled = false
var all_elements = Globals.elements.keys()
var element = all_elements.pick_random()
var atlas_texture = null
var die_size = Globals.DIE50
var visual_only = false

# BATTLE:
# elemental affinity
# requires a certain number of points to defeat
# only some hands are effective

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	label.text = ""
	set_element(element)
	atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = load("res://normal_dice.png")
	atlas_texture.region = Rect2(0,0,64,64)
	$TextureRect.texture = atlas_texture
	custom_minimum_size = die_size
	size = die_size
	pivot_offset = size/2
	draw_face()
	if visual_only:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = true

func clone():
	var new_die = self.duplicate()
	new_die.element = element
	new_die.value = value
	new_die.visual_only = true
	return new_die

func set_element(element_name="Basic"):
	#var elemental_keys = Globals.elements.keys()
	#var element_name = elemental_keys.pick_random()
	element = element_name
	var element_colors = Globals.elements[element_name]
	tooltip_text = element_name
	color = element_colors[0]
	label.add_theme_color_override("font_color", element_colors[1])
	border.border_color = element_colors[2]
	
func draw_face():
	$TextureRect.visible = true
	if randi() % 10 > 5:
		$TextureRect.flip_h = true
	if randi() % 10 > 5:
		$TextureRect.flip_v = true
	var sprite_value = value - 1
	var w = 64
	var h = 64
	var x = sprite_value * 64
	var y = 0
	atlas_texture.region = Rect2(x, y, w, h)

func roll():
	if held:
		locked = true
	if locked:
		return value
	value = randi() % faces + 1
	draw_face()
	visible = true
	scale = Vector2(0,0)
	rotation_degrees = randi()%1070
	if randf() > 0.5:
		rotation_degrees = -rotation_degrees
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1,1), randf_range(0.2,0.5)).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "rotation_degrees", 0, randf_range(0.4,0.7)).set_ease(Tween.EASE_OUT)
	has_rolled = true	
	return value

func toggle_held():
	if has_rolled and !locked:
		held = !held
		if held:
			border.border_color = Color("#ff0000")
		else:
			border.border_color = element[2]

func level_up():
	pass

func show_level_up_options():
	if !level_up_options_visible:
		var new_level = level_up_options.instantiate()
		add_child(new_level)
		level_up_options_visible = true

func lock():
	locked = true
	
func apply_effects(player:Player, enemy:Enemy):
	print("Apply dice effect")
	var pos = global_position
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_method(set_global_position, global_position, Vector2(global_position.x, global_position.y - 25), 0.5)
	tween.tween_method(set_global_position, global_position, pos, 0.2)
	await tween.finished
	print("Dice effect finished")
	
func unlock():
	held = false
	border.border_color = element[2]
	locked = false

func _on_gui_input(event):
	if !visual_only and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if ready_to_level:
				show_level_up_options()
			else:
				toggle_held()
