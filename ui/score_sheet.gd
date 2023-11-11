extends Control

@onready var score_row = preload("res://ui/score_row.tscn")
@onready var score_holder = %Scores

# Called when the node enters the scene tree for the first time.
func _ready():
    for hand in Spells.HAND_INFO.keys():
        var hand_name = Spells.hand_name(hand)
        var hand_info = Spells.HAND_INFO[hand]
        var row = score_row.instantiate()
        var line = HSeparator.new()
        row.hand = hand
        row.hand_name = hand_name
        row.hand_info = hand_info
        score_holder.add_child(row)
        score_holder.add_child(line)
