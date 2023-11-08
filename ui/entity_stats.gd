extends Control

@onready var health_bar = $Container/Health/HealthBar
@onready var health_value = $Container/Health/HealthValue
@onready var poison_value = $Container/SubStats/Poison/PoisonValue
@onready var block_value = $Container/SubStats/Block/BlockValue

var entity:Entity = null

func _ready():
    if is_instance_valid(entity):
        entity.hp_changed.connect(update_health)
        entity.block_changed.connect(update_block)
        entity.poison_changed.connect(update_poison)
        update_health()
        update_block()
        update_poison()

func update_health():
    var health_percent = float(entity.hp) / float(entity.max_hp)
    health_bar.value = health_percent
    health_value.text = "%s / %s" % [entity.hp, entity.max_hp]

func update_block():
    block_value = str(entity.block)

func update_poison():
    poison_value = str(entity.poison)
