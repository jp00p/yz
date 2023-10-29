class_name Player extends Entity

func _ready():
	super()
	dice = create_initial_dice()
	var starting_spells = Globals.all_spells.keys().slice(0,8)
	for spell in starting_spells:
		add_spell(spell)
	max_shield = 100
	shield = max_shield
