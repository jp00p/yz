class_name Die extends ColorRect

@onready var border = $Border
@onready var numerals = $Numerals

var faces = 6

var holder:Entity = null # who owns this die
var held = false # held for a yahtzee hand (by clicking)
var locked = false # locked in (after being held and the other dice rolled)
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
  set_prefix(null)
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
    if new_prefix and new_prefix in Globals.dice_prefixes.keys():
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

func roll():
  numerals.visible = true
  visible = true
  if active:
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
    await tween.finished
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

func lock():
  locked = true

# instead of attacking directly, dice should modify the output of spells
func attack(target:Entity):
    return
    var damage = value
    if active:
        var shake_target = "Player"
        if target is Enemy:
            shake_target = "Event"
        damage = value
        print("%s die is attacking (value: %s, damage: %s)" % [prefix, value, damage])
        var pos = global_position
        var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
        tween.tween_method(set_global_position, global_position, Vector2(global_position.x, global_position.y - 25), 0.5)
        tween.tween_method(set_global_position, global_position, pos, 0.2)
        var final_damage = apply_effects(target, damage)
        await tween.finished
        #target.take_damage(final_damage, element)
        #Globals.shake_panel.emit(shake_target)

func apply_effects(target:Entity, damage:int):
    var all_effects = []
    var final_damage = damage
    # get effects from material, element and prefixes
    if die_material and Globals.dice_materials[die_material]["roll_effect"]:
        all_effects.append(Globals.dice_materials[die_material])
    if prefix and Globals.dice_prefixes[prefix]["roll_effect"]:
        all_effects.append(Globals.dice_prefixes[prefix])
    if element and Globals.dice_elements[element]["roll_effect"]:
        all_effects.append(Globals.dice_elements[element])
    #TODO: dice should affect spells, not attack DIRECTLY
    for effect in all_effects:
        var mod = Expression.new()  # used for damage/healing formulas
        match(effect["roll_effect"]):
            Globals.DICE_EFFECTS.DAMAGE_ADJUSTMENT:
                print("Adjusting damage with this formula: %s" % effect["effect_params"][0])
                mod.parse(effect["effect_params"][0], ["v"])
                final_damage = mod.execute([value])
                #Globals.new_floating_text(get_center(), str(final_damage))
                print("Base damage:%s - Final damage: %s" % [damage, final_damage])
            Globals.DICE_EFFECTS.ADD_HEALTH:
                print("Adding health to dice owner with this formula: %s" % effect["effect_params"][0])
                mod.parse(effect["effect_params"][0], ["v"])
                var health = mod.execute([value])
                holder.hp += health
                #Globals.new_floating_text(get_center(), str(health))
                print("PARAMS:[%s] Healed self for %s" % [effect["effect_params"][0], health])
            _:
                print("The default effect has occurred")
    return final_damage

func unlock():
  held = false
  border.border_color = element_colors["border"]
  locked = false

func _on_gui_input(event):
  if !visual_only and event is InputEventMouseButton and active:
    if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        toggle_held()
