extends Control

@onready var spell_combos = preload("res://ui/spell_combos.tscn")
@onready var markers = %Markers
@onready var dice_holder = %DiceHolder
@onready var combos = %Combos
@onready var roll_label = %RollLabel

@export var debug:bool = false

var entity : Entity = null

func _ready() -> void:
    if not debug:
        set_dice(entity)
    SignalBus.show_spell_options.connect(show_spell_options)
    SignalBus.swap_dice.connect(set_dice)
    SignalBus.roll_dice.connect(update_roll_label)
    Globals.player.rolled.connect(player_rolled)

func update_roll_label(whose_turn):
    if whose_turn == Globals.player:
        roll_label.show()
        roll_label.text = "Roll %s/%s" % [Globals.player.rolls, Globals.player.max_rolls]

func player_rolled():
    if Globals.player.rolls == Globals.player.max_rolls:
        Globals.player.lock_dice()

func clear() -> void:
    # remove any dice in the tray
    roll_label.hide()
    for d in dice_holder.get_children():
        print("Removing %s" % d)
        entity.disable_dice()
        d.put_away()

func set_dice(who, clear_dice=true) -> void:
    if clear_dice:
        clear()
    # set the tray to a new owner
    var i = 0
    if is_instance_valid(who):
        for d in who.dice:
            var pos = %Markers.get_child(i)
            d.position = pos.position - (d.size/2)

            dice_holder.add_child(d)
            i += 1
        who.enable_dice()
    dice_holder.rotation_degrees = randi_range(-5, 5)

func show_spell_options(spell:Spell):
    var combos = spell_combos.instantiate()
    combos.spell = spell
    add_child(combos)

func add_combos(spell:Spell) -> void:
    # add the combos screen to the tray
    for c in combos.get_children():
        c.queue_free()
    var combos = spell_combos.instantiate()
    combos.spell = spell
    combos.add_child(combos)
