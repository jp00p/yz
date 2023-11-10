extends PanelContainer

@onready var health_bar = %HealthBar
@onready var health_value = %HealthValue
@onready var poison_value = %PoisonValue
@onready var block_value = %BlockValue
@onready var portrait = %Portrait

var entity:Entity = null

func _ready():
    if is_instance_valid(entity):
        entity.hp_changed.connect(update_health)
        entity.block_changed.connect(update_block)
        entity.poison_changed.connect(update_poison)
        update_health()
        update_block()
        update_poison()
        if entity is Enemy:
            portrait.texture = load("res://graphics/ui/enemies/%s" % entity.portrait)

func update_health():
    var health_percent = float(entity.hp) / float(entity.max_hp)
    health_bar.value = health_percent
    health_value.text = "%s / %s" % [entity.hp, entity.max_hp]

func update_block():
    print("Updating block UI")
    block_value.text = str(entity.block)

func update_poison():
    print("Updating poison UI")
    poison_value.text = str(entity.poison)
