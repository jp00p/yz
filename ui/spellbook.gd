extends Control

@onready var spell_holder = %Spells

var entity:Entity = null

func _ready():
    visible = false
    if is_instance_valid(entity):
        for spell in entity.spellbook.values():
            var spell_card = Globals.SPELL_CARD.instantiate()
            spell_card.spell = spell
            spell_holder.add_child(spell_card)

func enable():
    mouse_filter = Control.MOUSE_FILTER_PASS
    visible = true
    $AnimationPlayer.play("show")

func disable():
    mouse_filter = Control.MOUSE_FILTER_STOP
    $AnimationPlayer.play("hide")
    await $AnimationPlayer.animation_finished
    visible = false

func disable_spells():
    for s in spell_holder.get_children():
        s.can_cast = false

func enable_spells():
    for s in spell_holder.get_children():
        s.can_cast = true

func _on_animation_player_animation_started(_anim_name):
    disable_spells()


func _on_animation_player_animation_finished(anim_name):
    if anim_name == "show":
        enable_spells()
