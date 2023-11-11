extends Node2D

const plane_len = 30
const node_count = plane_len * plane_len / 12
const path_count = 8

const map_scale = 20.0

var events = {}
var event_scene = preload("res://event.tscn")

func _ready():
    var generator = preload("res://objects/map_generator.gd").new()
    var map_data = generator.generate(plane_len, node_count, path_count)

    for k in map_data.nodes.keys():
        var point = map_data.nodes[k]
        var event = event_scene.instantiate()
        event.position = point * map_scale + Vector2(200, 0)
        add_child(event)
        events[k] = event

    for path in map_data.paths:
        for i in range(path.size() - 1):
            var index1 = path[i]
            var index2 = path[i + 1]
            events[index1].add_child_event(events[index2])


func _on_control_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            get_tree().reload_current_scene()
