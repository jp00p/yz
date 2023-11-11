extends Node2D

const margin = 10

var children: Array = []
var current_color = Color("Orange")

func add_child_event(child):
    if !children.has(child):
        children.append(child)
        queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, 8, current_color)

    for child in children:
        var line = child.position - position
        var normal = line.normalized()
        line -= margin * normal
        var color = Color("Gray")
        draw_line(normal * margin, line, color, 2, true)

func _on_reference_rect_mouse_entered():
    current_color = Color("Blue")
    queue_redraw()

func _on_reference_rect_mouse_exited():
    current_color = Color("Orange")
    queue_redraw()


func _on_reference_rect_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("Wee")
