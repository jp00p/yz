class_name Entity extends Node

signal hp_changed
signal poison_changed
signal block_changed
signal died
signal attacked(target)
signal casted_spell

var hp :int = 1 : set = set_hp
var max_hp :int = 100
var dice: Array[Die] = []
var spellbook: Dictionary = {}
var shake_target = "Player"

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
    Globals.shake_panel.emit(shake_target)

func take_poison_damage() -> void:
    if poison > 0:
        self.hp = max((self.hp - poison), 0)
        self.poison = poison - (1 + poison_decay_mod)

func block_decay():
    if block > 0:
        self.block = 0 + block_decay_mod

func status_tick():
    take_poison_damage()
    block_decay()

func set_hp(val):
    hp = min(val, max_hp)
    hp_changed.emit()
    if hp <= 0:
        hp = 0
        disable_dice()
        died.emit()

func set_poison(val):
    poison = max(val, 0)
    poison_changed.emit()

func set_block(val):
    block = max(val, 0)
    block_changed.emit()

func disable_dice():
    for d in dice:
        d.active = false

func enable_dice():
    for d in dice:
        d.active = true

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

func list_spells(only_available_spells=false) -> Array[Spell]:
    # returns array of spells
    # pass "true" to only return spells that haven't been cast yet
    if not only_available_spells:
        return spellbook.keys()
    var available_spells = []
    for spell in spellbook:
        if not spell.has_cast:
            available_spells.append(spell)
    return available_spells

func add_dice(num_dice=1) -> void:
    for d in range(num_dice):
        var new_die = Globals.DIE.instantiate()
        new_die.holder = self
        self.dice.append(new_die)

func roll_dice() -> Array[Die]:
    for d in dice:
        d.roll()
    return dice

func attack(target:Entity) -> void:
    print("%s attacked %s" % [self.name, target])
    attacked.emit(target)

func set_spell_components(hands) -> void:
    # does the spell match a valid yahtzee hand we rolled?
    for spell in spellbook.values():
        spell.components = {}
        if spell.hand in hands.keys():
            if hands[spell.hand]["dice"].size() > 0:
                spell.components = hands[spell.hand]

func prepare_spellbook() -> Array:
    var ready_spells = []
    for spell in spellbook.values():
        spell.prepared = false
        if spell.components.size() > 0:
            spell.prepared = true
            ready_spells.append(spell)
    return ready_spells

func cast_spell(spell:Spell, target:Entity):
    spell.score = spell.components.score[0]
    spell.cast(target)
    casted_spell.emit()

func heal(amt:int) -> void:
    self.hp += amt

func add_poison(amt:int) -> void:
    self.poison += amt

func add_block(amt:int) -> void:
    self.block += amt
