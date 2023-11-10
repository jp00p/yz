class_name Player extends Entity

func _ready():
    super()
    print("Player is ready")
    self.hp = 100
    dice = create_initial_dice()
    var starting_spells = Spells.ALL_SPELLS
    for spell in starting_spells:
        add_spell(spell)
