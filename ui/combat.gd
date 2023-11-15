extends PanelContainer

signal enable_player_input
signal disable_player_input
signal player_ready_to_cast
signal enemy_died
signal player_died
signal player_turn_complete
signal enemy_turn_complete
signal combat_complete

@onready var enemy_details = %MonsterDetails

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

    SignalBus.roll_dice.connect(dice_rolled)
    SignalBus.add_dice_tray.emit(Globals.player) # create dice tray and assign to player

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
        SignalBus.show_spell_options.emit(spell)
    else:
        player.cast_spell(spell, enemy)

func finish_enemy_turn():
    print("Enemy turn complete")
    await Utils.wait(1)
    enemy_turn_complete.emit()
    next_turn()

func finish_player_turn():
    print("Player turn complete")
    await Utils.wait(1)
    player_turn_complete.emit()
    next_turn()

func dice_rolled(who:Entity):
    if who.rolls != who.max_rolls:
        who.roll_dice()
    if whose_turn == player and player.rolls == player.max_rolls:
        player.prepare_spells()
        Globals.spellbook.enable()
        SignalBus.toggle_roll_button_state.emit("disabled")

func advance_combat():
    if combat_round > 0:
        SignalBus.swap_dice.emit(whose_turn, true)
    whose_turn.status_tick("start") # status tick at start of turn
    if not check_who_died():
        combat_round += 1
        match whose_turn:
            player:
                print("Player turn start")
                player.rolls = 0
            enemy:
                print("Enemy turn start")
                await enemy.attack(player)

func next_turn():
    await whose_turn.status_tick("end") # status tick at end of turn
    if not check_who_died():
        if whose_turn == enemy:
            whose_turn = player
            SignalBus.toggle_roll_button_state.emit("enabled")
        else:
            whose_turn = enemy
        advance_combat()

func check_who_died():
    if player.hp <= 0:
        player_died.emit()
        combat_complete.emit()
        print("Someone died!")
        return true
    if enemy.hp <= 0:
        enemy_died.emit()
        combat_complete.emit()
        print("Someone died!")
        return true
    return false
