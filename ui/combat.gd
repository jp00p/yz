extends PanelContainer

signal enable_player_input
signal disable_player_input
signal player_ready_to_cast
signal enemy_died
signal player_died
signal player_turn_complete
signal enemy_turn_complete

@onready var enemy_details = %MonsterDetails
@onready var image = %Image
@onready var bg_frame = %BGFrame

var enemy : Enemy = null
var player : Player = null
var enemy_name = "Witch"
var whose_turn : Entity
var combat_round : int = 0

func _ready():

    player = Globals.player
    player.casted_spell.connect(finish_player_turn)
    for spell in player.spellbook.values():
        spell.cast_spell.connect(player_cast_spell)

    Globals.roll_dice.connect(dice_rolled)
    Globals.add_dice_tray.emit(Globals.player) # create dice tray and assign to player

    enemy = Enemy.new(enemy_name)
    enemy.attacked.connect(finish_enemy_turn)
    add_child(enemy)

    var enemy_stats = Globals.ENTITY_STATS.instantiate()
    enemy_stats.entity = enemy
    enemy_details.add_child(enemy_stats)

    whose_turn = player
    advance_combat()


#func show_cast_components(spell:Spell=null):
#    player_dice_tray.add_combo(spell)

func player_cast_spell(spell:Spell=null):
    if spell.components.size() > 1:
        Globals.show_spell_options.emit(spell)
    else:
        player.cast_spell(spell, enemy)


func finish_enemy_turn():
    print("Enemy turn complete")
    enemy_turn_complete.emit()
    next_turn()

func finish_player_turn():
    print("Player turn complete")
    await Utils.wait(3)
    Globals.spellbook.disable()
    player_turn_complete.emit()
    next_turn()

func dice_rolled(who:Entity):
    if who.rolls != who.max_rolls:
        await who.roll_dice()
    if whose_turn == player and player.rolls == player.max_rolls:
        player.prepare_spells()
        Globals.spellbook.enable()
        Globals.toggle_roll_button_state.emit("disabled")

func advance_combat():
    whose_turn.status_tick("start") # status tick at start of turn
    who_died()
    combat_round += 1
    Globals.swap_dice.emit(whose_turn, true)
    match whose_turn:
        player:
            print("Player turn start")
            player.rolls = 0
        enemy:
            print("Enemy turn start")
            await enemy.attack(player)

func next_turn():
    await whose_turn.status_tick("end") # status tick at end of turn
    if whose_turn == enemy:
        whose_turn = player
        Globals.toggle_roll_button_state.emit("enabled")
    else:
        whose_turn = enemy
    advance_combat()

func who_died():
    if player.hp <= 0:
        player_died.emit()
    if enemy.hp <= 0:
        enemy_died.emit()
