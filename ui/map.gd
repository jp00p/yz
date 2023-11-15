extends Node2D

@onready var map_point = preload("res://ui/map_point.tscn")

var the_map = []
var final_map = []
var map_padding = 64
var map_points = 9
var path_length = 128
var point_size = 32
var route_horizontal_space = 128
var routes = 3
var x = map_padding
var y = map_padding
var path_row = []

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()

    for point in range(map_points):

        var point_data = {
            "x":x,
            "y":y,
            "type":0,
            "neighbor":null
        }

        path_row.append(point_data) # add a column to the row
        x += route_horizontal_space + point_size + randi_range(-point_size, point_size) # jiggle x coords

        if (point+1) % routes == 0:
            # split routes
            y += path_length
            x = map_padding
            the_map.push_front(path_row) # keep rows in order
            path_row = [] # clear row for next iteration

    print(the_map.size())
    # build array of map nodes out of the map data
    for row in range(the_map.size()):
        var new_row = []
        for p in range(the_map[row].size()):
            var point_scene = map_point.instantiate()
            point_scene.position.x = the_map[row][p]["x"]
            point_scene.position.y = the_map[row][p]["y"]
            point_scene.type = the_map[row][p]["type"]
            new_row.append(point_scene)
        final_map.append(new_row)

    # add neighbors to map nodes
    for row in range(final_map.size()):
        for p in range(final_map[row].size()):
            if (row + 1) < final_map.size():
                final_map[row][p].neighbor = final_map[row+1][p]

    for row in final_map:
        for map_node in row:
            add_child(map_node)
