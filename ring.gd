class_name Ring extends Control

var ring_name = "Ring"
var rarity = 1
var base_price = 100
var effect = null
var elements = []
var chance = 0.5
var description = "Has a chance to enchant your die"
var graphic

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass

func activate(die):
	var roll = randf_range(0.0, 1.0)
	if roll >= chance:
		pass
