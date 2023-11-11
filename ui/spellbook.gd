extends Control

@onready var spell_holder = %Spells
@onready var score_scroll = %ScoreScroll

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
