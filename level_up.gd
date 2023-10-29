extends Control

var possible_options = ["+1 face", "+2 face", "x2 points", "x1.5 points"]
# Called when the node enters the scene tree for the first time.
func _ready():
	for option in possible_options:
		var opt_button = Button.new()
		opt_button.text = option
		$HBoxContainer.add_child(opt_button)
