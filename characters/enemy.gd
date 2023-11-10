class_name Enemy extends Entity

var enemy_name = ""
var portrait = ""
var enemy_data

func _init(new_enemy_name):
    enemy_name = new_enemy_name
    enemy_data = Enemies.ALL_ENEMIES[enemy_name]

func _ready():
    super()
    max_hp = enemy_data["hp"]
    hp = max_hp
    for s in enemy_data["spells"]:
        add_spell(s)
    add_dice(5)
    portrait = enemy_data["portrait"]

func assign_name(new_name) -> Enemy:
    self.enemy_name = new_name
    return self

func set_hp(val):
    super(val)
    if hp <= 0:
        Globals.enemy_died.emit()

func attack(target:Entity):
    # roll dice
    # pick a valid spell
    # cast it!
    await Utils.wait(1.5)
    roll_dice()
    await Utils.wait(1.5)
    prepare_spells()
    var ready_spells = get_ready_spells()
    var selected_spell:Spell = null
    for s in spellbook.keys():
        if spellbook[s].prepared:
            ready_spells.append(spellbook[s])
    if ready_spells.size() > 0:
        selected_spell = ready_spells.pick_random()
    if selected_spell:
        print("Enemy selected spell %s" % selected_spell.spell_name)
        await cast_spell(selected_spell, target)
        await Utils.wait(1)
    else:
        #TODO: SCRATCH
        print("No valid spells")
    attacked.emit()

    super(target)
