extends GamePopup

@onready var buttons = $CenterContainer/VBoxContainer/Buttons

signal level_selected(level_type)

var level_choices = [Events.LEVEL_TYPES.BATTLE, Events.LEVEL_TYPES.SHOP, Events.LEVEL_TYPES.EVENT]
var all_choices = []
var selected = null

# Called when the node enters the scene tree for the first time.
func _ready():
    super()
    level_choices.shuffle()
    build_options()

func build_options():
    all_choices = []
    for i in range(3):
        var choice = level_choices.pick_random()
        all_choices.append(choice)
    if all_choices[0] == all_choices[1] and all_choices[1] == all_choices[2]:
        build_options()
        return

    for choice in all_choices:
        var choice_button = Button.new()
        match choice:
            Events.LEVEL_TYPES.BATTLE:
                choice_button.text = "Battle"
            Events.LEVEL_TYPES.SHOP:
                choice_button.text = "Shop"
            Events.LEVEL_TYPES.EVENT:
                choice_button.text = "Event"
        selected = choice
        choice_button.pressed.connect(send_level_select)
        buttons.add_child(choice_button)

func send_level_select():
    level_selected.emit(selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
