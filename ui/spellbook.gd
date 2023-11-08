extends Control

@onready var spell_holder = $ScrollContainer/MarginContainer/Spells

var entity:Entity = null

func _ready():
    if is_instance_valid(entity):
        for spell in entity.spellbook.values():
            var spell_card = Globals.SPELL_CARD.instantiate()
            spell_card.spell = spell
            spell_holder.add_child(spell_card)
