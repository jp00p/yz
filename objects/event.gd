extends Node2D

var event_type = Globals.EVENT_TYPES.BATTLE
var event_name = "Test event"
var event_description = "A basic event"

# Called when the node enters the scene tree for the first time.
func _ready():
    match event_type:
        Globals.EVENT_TYPES.BATTLE, Globals.EVENT_TYPES.CHALLENGE:
            # choose creature
            # show creature details
            # start new battle with apppropriate difficulty
            # turn counter, dice tray, spellbook, lots of UI
            pass
        Globals.EVENT_TYPES.REST:
            # show options, restore hp
            # not much UI needed besides buttons
            pass
        Globals.EVENT_TYPES.SHOP:
            # load items, show choices
            # need UI for shop items and current inventory
            pass
        Globals.EVENT_TYPES.EVENT:
            # message, graphics, choice
            # simple UI, maybe a dice tray
            pass
        _:
            pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
