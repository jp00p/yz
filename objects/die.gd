class_name Die extends ColorRect

@onready var border = $Border
@onready var numerals = $Numerals

var faces = 6

var rolling = false

var holder:Entity = null # who owns this die
var held = false : set = set_held # held for a yahtzee hand (by clicking)
var locked = false : set = set_locked # locked in (after being held and the other dice rolled)
var value = 0 # the value rolled
var has_rolled = false # did it roll already?

var element = "Basic"
var die_material = "Bone"
var prefix = "Jagged"

var atlas_texture = null
var die_size = Globals.DIE50
var visual_only = false

var element_colors = {}
var test_prefixes = ["Jagged", "Pure", "None"]

var active = true

func _ready():
    visible = false
    numerals.visible = false
    set_element("Basic")
    set_die_material("Wood")
    set_prefix("None")
    atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = load("res://graphics/normal_dice.png")
    atlas_texture.region = Rect2(0,0,64,64)
    numerals.texture = atlas_texture
    pivot_offset = size/2
    draw_face()

    if visual_only:
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        visible = true
        numerals.visible = true

func reset():
    # reset this die to it's unrolled state
    value = 0
    has_rolled = false
    unlock()

func get_center():
    var pos = global_position
    var new_pos = Vector2(pos.x+(size.x/2), pos.y-(size.y/2))
    return new_pos

func clone():
  var new_die = self.duplicate()
  new_die.element = element
  new_die.value = value
  new_die.visual_only = true
  return new_die

func set_element(element_name=null):
  if element_name and element_name in Globals.dice_elements.keys():
      element = element_name
      element_colors = Globals.dice_elements[element_name]["colors"]
      tooltip_text = element_name
      color = element_colors["background"]
      #label.add_theme_color_override("font_color", element_colors["foreground"])
      border.border_color = element_colors["border"]

func set_die_material(new_material=null):
  if new_material and new_material in Globals.dice_materials.keys():
      die_material = new_material

func set_prefix(new_prefix=null):
    if new_prefix != "None" and new_prefix in Globals.dice_prefixes.keys():
        prefix = new_prefix
    if new_prefix == "Pure":
        var mat = ShaderMaterial.new()
        mat.shader = load("res://objects/rainbow.gdshader")
        material = mat
    if new_prefix == "Jagged":
        var graphic = TextureRect.new()
        graphic.texture = load("res://graphics/jagged.png")
        graphic.show_behind_parent = true
        graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
        graphic.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
        add_child(graphic)

func draw_face():
    # draw the pips based on the spritesheet
    if value > 0:
        if randi() % 10 > 5:
            numerals.flip_h = true
        if randi() % 10 > 5:
            numerals.flip_v = true
        var sprite_value = value - 1
        var w = 64
        var h = 64
        var x = sprite_value * 64
        var y = 0
        atlas_texture.region = Rect2(x, y, w, h)

func _process(delta):
    pass
#    if rolling:
#        if randf() > 0.4:
#            value = randi() % faces + 1
#            draw_face()

func roll():
    visible = true
    numerals.visible = true

    if held:
        locked = true

    if locked:
        return

    value = randi() % faces + 1 # RRRROLLLLLL
    draw_face()

    scale = Vector2.ZERO
    rotation_degrees = randi()%1070

    if randf() > 0.5:
        rotation_degrees = -rotation_degrees

    visible = true
    #rolling = true

    var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
    tween.tween_property(self, "scale", Vector2(1,1), randf_range(0.2,0.5)).set_ease(Tween.EASE_IN_OUT)
    tween.parallel().tween_property(self, "rotation_degrees", 0, randf_range(0.4,0.7)).set_ease(Tween.EASE_OUT)
    await tween.finished

    has_rolled = true
    return value

func put_away():
    visible = false

func toggle_held():
  if has_rolled and !locked and holder is Player:
    held = !held
  if held:
    border.border_color = Color("#ff0000")
  else:
    border.border_color = element[2]

func set_locked(val):
    locked = val
    if not locked:
        self.held = false

func set_held(val):
    held = val
    if held:
        border.border_color = Color("Red")
    else:
        border.border_color = Color("White")

func lock():
  self.locked = true

func unlock():
  self.locked = false

func _on_gui_input(event):
  if !visual_only and event is InputEventMouseButton and active:
    if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        self.held = !held
