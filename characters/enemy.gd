class_name Enemy extends Entity

var enemy_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
    super()
    var enemy_data = Enemies.ALL_ENEMIES[enemy_name]
    max_hp = enemy_data["hp"]
    hp = max_hp
    for s in enemy_data["spells"]:
        add_spell(s)
    add_dice(5)

func assign_name(new_name) -> Enemy:
    self.enemy_name = new_name
    return self

func set_hp(val):
    super(val)
    if hp <= 0:
        Globals.enemy_died.emit()

func attack(target:Entity):
    roll_dice()
    await Utils.wait()
    var hands = Utils.check_dice_conditions(dice)
    set_spell_components(hands)
    var ready_spells = prepare_spellbook()

    var selected_spell:Spell = null
    for s in spellbook.keys():
        if spellbook[s].prepared:
            ready_spells.append(spellbook[s])
    if ready_spells.size() > 0:
        selected_spell = ready_spells.pick_random()
    if selected_spell:
        print("Enemy selected spell %s" % selected_spell.spell_name)
        await cast_spell(selected_spell, target)
    else:
        print("No valid spells")
    attacked.emit()
    super(target)
