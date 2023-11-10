extends Control

@onready var dice_combo = preload("res://ui/dice_combo_container.tscn")
@onready var combo_rows = %Combos

var spell:Spell

func _ready():
    var used_combos = []
    for combo in spell.components:
        combo["dice"].sort()
        if combo["dice"] not in used_combos:
            var row = dice_combo.instantiate()
            row.dice = combo["dice"]
            row.score = combo["score"]
            row.spell = spell
            row.combo_selected.connect(remove_self)
            combo_rows.add_child(row)
            used_combos.append(combo["dice"])

func remove_self():
    queue_free()
