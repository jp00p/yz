extends Node3D

@onready var die = preload("res://magic_die.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(5):
		var new_die = die.instantiate()
		new_die.global_position = $Dice.global_position + Vector3(randf(),randf(),randf())
		$Dice.add_child(new_die)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

