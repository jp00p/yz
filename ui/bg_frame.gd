extends TextureRect

var parallax_amount = 0.0055
var parallax_speed = 0.125
@export var opacity : float = 1.0
@onready var image = %Image

func _process(delta):
    var mouse_position = get_global_mouse_position()
    var node_position = global_position
    var x_offset = -(mouse_position.x - node_position.x) * parallax_amount
    var y_offset = -(mouse_position.y - node_position.y) * parallax_amount + 40
    image.position.x = lerp(image.position.x, x_offset, parallax_speed)
    image.position.y = lerp(image.position.y, y_offset, parallax_speed)
    self_modulate.a = lerp(self_modulate.a, opacity, 0.15)
