extends Control

@onready var start_button = %Start
@onready var options_button = %Options

# Called when the node enters the scene tree for the first time.
func _ready():
    start_button.pressed.connect(start_game)
    options_button.pressed.connect(show_options)

func start_game():
    get_tree().change_scene_to_file("res://main.tscn")

func show_options():
    pass
