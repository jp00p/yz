extends Node2D

var type
var neighbor:Node2D
var center = Vector2.ZERO

func _ready():
    print(neighbor)

    if neighbor:
        neighbor.modulate.a = 0.5



func _process(delta):
    queue_redraw()

func _draw():
    draw_circle(position, 32, Color("Orange"))
    if neighbor:
        var line = (neighbor.position + position) * 32
        draw_line(position, line, Color("Blue"), 2.0)
