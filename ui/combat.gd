extends HBoxContainer

signal enable_player_input
signal disable_player_input
signal enemy_died
signal player_died
signal enemy_turn_complete

@onready var monster_graphic = $MonsterDetails/Row/GraphicHolder/Graphic
@onready var monster_dice_tray = $MonsterDetails/Row/MonsterDiceTray
@onready var monster_details = $MonsterDetails

var enemy : Enemy = null
var player : Player = null
var enemy_name = "Witch"
var whose_turn : Entity
var combat_round : int = 0

func _ready():
    monster_dice_tray.visible = false
    enemy = Enemy.new()
    enemy.enemy_name = enemy_name
    enemy.died.connect(enemy_died_animation)
    enemy.attacked.connect(enemy_attack_complete)
    add_child(enemy)

    var enemy_stats = Globals.ENTITY_STATS.instantiate()
    enemy_stats.entity = enemy
    monster_details.add_child(enemy_stats)
    monster_graphic.texture = load("res://graphics/enemies/%s.png" % enemy.enemy_name.to_lower())

    for d in enemy.dice:
        monster_dice_tray.add_child(d)

    player.casted_spell.connect(player_turn_complete)

    whose_turn = player
    advance_combat()

func enemy_attack_complete():
    print("Enemy turn complete")
    whose_turn = player
    enemy_turn_complete.emit()
    advance_combat()

func player_turn_complete():
    print("Player turn complete")
    whose_turn = enemy
    advance_combat()

func advance_combat():
    Globals.reset_panels.emit()
    whose_turn.status_tick()
    await Utils.wait()
    if player.hp <= 0:
        player_died.emit()
    if enemy.hp <= 0:
        enemy_died.emit()
    combat_round += 1
    match whose_turn:
        player:
            print("Player turn start")
            player.rolls = 0
            player.reset_dice()
            enable_player_input.emit()
        enemy:
            print("Enemy turn start")
            disable_player_input.emit()
            monster_dice_tray.visible = true
            enemy.attack(player)
            await Utils.wait()

func enemy_died_animation():
    $GraphicHolder/MonsterAnimation.play("death")
    await $GraphicHolder/MonsterAnimation.animation_finished
