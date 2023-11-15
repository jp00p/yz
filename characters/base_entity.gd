class_name Entity extends Node

signal hp_changed
signal poison_changed
signal block_changed
signal died
signal attacked(target)
signal casted_spell
signal rolled

var hp :int = 1 : set = set_hp
var max_hp :int = 100
var dice: Array[Die] = []
var spellbook: Dictionary = {}
var shake_target = "Player"

var rolls = 0
var max_rolls = 3

var poison = 0 : set = set_poison # poison decays 1 per turn
var poison_decay_mod : int = 0 # more of this, less poison per turn

var block = 0 : set = set_block # block resets to 0 every turn
var block_decay_mod : int = 0 # more of this, more block stays

func _ready():
    if is_instance_of(self, Enemy):
        shake_target = "Event"

func reset_dice():
    for d in dice:
        d.reset()

func take_damage(damage_amount, element_type=null):
    print("Ouch!")
    self.hp = max((self.hp - damage_amount), 0)
    #Shake.make_shake(self, 10)
    #SignalBus.shake_panel.emit(shake_target)

func take_poison_damage() -> void:
    if poison > 0:
        await Utils.wait()
        print("Taking poison damage!")
        take_damage(poison)
        self.poison = poison - (1 + poison_decay_mod)


func block_decay():
    print("Resetting block!")
    if block > 0:
        await Utils.wait()
        self.block = 0 + block_decay_mod

func status_tick(phase="start"):
    match phase:
        "start":
            block_decay()
        "end":
            take_poison_damage()

func lock_dice():
    dice.map(func(d): d.lock())

func set_hp(val):
    hp = min(val, max_hp)
    hp_changed.emit()
    if hp <= 0:
        hp = 0
        #disable_dice()
        died.emit()

func set_poison(val):
    poison = max(val, 0)
    poison_changed.emit()

func set_block(val):
    block = max(val, 0)
    block_changed.emit()

func disable_dice():
    for d in dice:
        d.put_away()

func enable_dice():
    pass

func create_initial_dice() -> Array:
    # load initial five dice
    add_dice(5)
    return dice

func add_spell(spellname) -> Spell:
    # add spell to spellbook
    # returns spell object
    if spellname not in Spells.ALL_SPELLS.keys():
        return
    var new_spell = Spell.new(spellname)
    new_spell.caster = self
    spellbook[spellname] = new_spell
    return new_spell

func add_dice(num_dice=1) -> void:
    for d in range(num_dice):
        var new_die = Globals.DIE.instantiate()
        new_die.holder = self
        self.dice.append(new_die)

func roll_dice():
    self.rolls += 1
    dice.map(func(d): d.roll())
    await get_tree().create_timer(1).timeout
    rolled.emit()


func attack(target:Entity) -> void:
    # tell the game this character wants to attack
    # enemies have their own attack logic
    # players will manually roll/cast spell
    var target_name = "Enemy"
    var attacker = "Player"
    if target is Player:
        target_name = "Player"
        attacker = "Enemy"
    print("%s attacked %s" % [attacker, target_name])
    attacked.emit(target)

func prepare_spells() -> void:
    var hands = Utils.generate_hands(dice)
    Utils.debug_hands(hands)
    print_dice()
    # given a set of yahtzee hands
    # set spells' components (dice + score)
    for spell in spellbook.values():
        if spell.hand in hands.keys():
            spell.components = hands[spell.hand]
            spell.prepared = true

func get_ready_spells() -> Array:
    var ready_spells = []
    for spell in spellbook.values():
        if spell.prepared and !spell.has_cast:
            ready_spells.append(spell)
    return ready_spells

func cast_spell(spell:Spell, target:Entity):
    spell.cast(target)
    casted_spell.emit()

func reset_spells(preparation=true, cast_status=false):
    for spell in spellbook:
        if preparation:
            spell.prepared = false
        if cast_status:
            spell.has_cast = false

func heal(amt:int) -> void:
    print("Ooh I'm healed")
    self.hp += amt

func add_poison(amt:int) -> void:
    print("Ow I'm poisoned!")
    self.poison += amt

func add_block(amt:int) -> void:
    print("Gird thy loins!")
    self.block += amt

func print_dice():
    var ds = ""
    for d in self.dice:
        ds += "[%s" % d.value
        if d.held:
            ds += "*"
        ds += "] "
    print("DICE: %s" % ds)

