extends PanelContainer

@onready var hand_label = $MarginContainer/Cols/Info/Stats/HBoxContainer/Hand
@onready var name_label = $MarginContainer/Cols/Info/Stats/HBoxContainer/SpellName
@onready var score_label = $MarginContainer/Cols/Info/Stats/HBoxContainer/Score
@onready var effect_label = $MarginContainer/Cols/Info/Stats/Effect

var spell:Spell = null
var stylebox_normal
var stylebox_hover
var can_cast = false

func _ready():
    visible = false
    if is_instance_valid(spell):
        spell.preparation_changed.connect(update_preparation)
        spell.scores_changed.connect(update_score_label)
        hand_label.text = Spells.hand_name(spell.hand)
        name_label.text = str(spell.spell_name)
        score_label.text = str(spell.score)
        effect_label.text = str(spell.description)


func cast():
    pass

func update_score_label():
    score_label.text = spell.get_scores_label()

func update_preparation():
    visible = spell.prepared

func _on_mouse_entered():
    hover("on")

func _on_mouse_exited():
    hover("off")

func hover(state="off"):
    pass
    #if state != "off":
        #$ColorRect.show()
    #else:
        #$ColorRect.hide()

func _on_gui_input(event) -> void:
    if can_cast:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
                spell.cast_spell.emit(spell)
                Globals.spellbook.disable()
                queue_free()
        if event is InputEventMouseMotion:
            pass

func burn_up():
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position.y", 150, 0.5)
    tween.parallel().tween_property(self, "modulate.a", 0.0, 0.5)
    await tween.finished
    queue_free()
