extends TextureRect

var background_graphics = ["res://graphics/ui/backgrounds/castle pack1.png", "res://graphics/ui/backgrounds/castle pack2.png", "res://graphics/ui/backgrounds/castle pack3.png", "res://graphics/ui/backgrounds/castle pack4.png", "res://graphics/ui/backgrounds/castle pack5.png", "res://graphics/ui/backgrounds/castle pack6.png", "res://graphics/ui/backgrounds/desert background1.png", "res://graphics/ui/backgrounds/desert background2.png", "res://graphics/ui/backgrounds/desert background3.png", "res://graphics/ui/backgrounds/desert background4.png", "res://graphics/ui/backgrounds/desert background5.png", "res://graphics/ui/backgrounds/desert background6.png", "res://graphics/ui/backgrounds/Dungeon Arena1.png", "res://graphics/ui/backgrounds/forest1.png", "res://graphics/ui/backgrounds/forest2.png", "res://graphics/ui/backgrounds/forest3.png", "res://graphics/ui/backgrounds/forest4.png", "res://graphics/ui/backgrounds/forest5.png", "res://graphics/ui/backgrounds/forest6.png", "res://graphics/ui/backgrounds/halloween background1.png", "res://graphics/ui/backgrounds/halloween background2.png", "res://graphics/ui/backgrounds/halloween background3.png", "res://graphics/ui/backgrounds/halloween background4.png", "res://graphics/ui/backgrounds/halloween background5.png", "res://graphics/ui/backgrounds/halloween background6.png", "res://graphics/ui/backgrounds/Mountain Pack1.png", "res://graphics/ui/backgrounds/Mountain Pack2.png", "res://graphics/ui/backgrounds/Mountain Pack3.png", "res://graphics/ui/backgrounds/Mountain Pack4.png", "res://graphics/ui/backgrounds/Mountain Pack5.png", "res://graphics/ui/backgrounds/Mountain Pack6.png", "res://graphics/ui/backgrounds/Sky1.png", "res://graphics/ui/backgrounds/Sky2.png", "res://graphics/ui/backgrounds/Sky3.png", "res://graphics/ui/backgrounds/Sky4.png", "res://graphics/ui/backgrounds/Sky5.png", "res://graphics/ui/backgrounds/Sky6.png"]
var parallax_amount = 0.0055
var parallax_speed = 0.125
@export var opacity : float = 1.0
@onready var image = %Image

func _ready():
    pick_bg()
#    var timer = Timer.new()
#    timer.autostart = true
#    timer.one_shot = false
#    timer.wait_time = 3.0
#    timer.timeout.connect(pick_bg)
#    add_child(timer)

func pick_bg():
    var pick = load(background_graphics.pick_random())
    image.texture = pick

func _process(delta):
    var mouse_position = get_global_mouse_position()
    var node_position = global_position
    var x_offset = -(mouse_position.x - node_position.x) * parallax_amount
    var y_offset = -(mouse_position.y - node_position.y) * parallax_amount + 40
    image.position.x = lerp(image.position.x, x_offset, parallax_speed)
    image.position.y = lerp(image.position.y, y_offset, parallax_speed)
    self_modulate.a = lerp(self_modulate.a, opacity, 0.15)
