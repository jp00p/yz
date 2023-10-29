class_name Enemy extends Entity

var enemy_name = "Cat"

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	var enemy_data = Globals.all_enemies[enemy_name]
	max_hp = enemy_data["hp"]
	hp = max_hp
	for s in enemy_data["spells"]:
		add_spell(s)
	add_dice(enemy_data["dice"])
