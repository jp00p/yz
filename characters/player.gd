class_name Player extends Entity

var rolls = 0
var max_rolls = 3

func _ready():
    super()
    self.hp = 100
    dice = create_initial_dice()
    var starting_spells = Spells.ALL_SPELLS
    for spell in starting_spells:
        add_spell(spell)
