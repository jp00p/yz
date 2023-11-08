extends PanelContainer

@onready var hand_label = $MarginContainer/Cols/Info/Stats/Hand
@onready var name_label = $MarginContainer/Cols/Info/Stats/SpellName
@onready var score_label = $MarginContainer/Cols/Info/Details/Score
@onready var effect_label = $MarginContainer/Cols/Info/Details/Effect

var spell:Spell = null
var stylebox_normal
var stylebox_hover

func _ready():
    visible = false
    if is_instance_valid(spell):
        spell.preparation_changed.connect(update_preparation)
        spell.score_changed.connect(update_score_label)
        spell.score_has_range.connect(update_score_label)
        stylebox_normal = get_theme_stylebox("panel")
        var bg = stylebox_normal.duplicate()
        bg.bg_color = Color("black")
        stylebox_hover = bg

        hand_label.text = Spells.hand_name(spell.hand)
        name_label.text = str(spell.spell_name)
        score_label.text = str(spell.score)
        effect_label.text = str(spell.description)

func update_score_label(score_range:String=""):
    if score_range != "":
        score_label.text = score_range
    else:
        score_label.text = str(spell.score)

func update_preparation():
    visible = spell.prepared

func _on_mouse_entered():
    hover("on")

func _on_mouse_exited():
    hover("off")

func hover(state="off"):
    if state != "off":
        add_theme_stylebox_override("panel", stylebox_hover)
    else:
        add_theme_stylebox_override("panel", stylebox_normal)

func _on_gui_input(event) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            spell.cast_spell.emit(spell)
