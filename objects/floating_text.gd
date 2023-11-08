class_name FloatingText extends Control

var text_location:Vector2 = Vector2.ZERO
var text_value = ""

func _ready():
    global_position = text_location
    $Label.text = text_value

func float_away(direction="up"):
    var dir = -1
    if direction == "down":
        dir = 1
    var tween = get_tree().create_tween()
    tween.tween_method(set_position, global_position, Vector2(global_position.x, global_position.y+(20*dir)), 1.0)
    tween.tween_property(self, "modulate", Color(1.,1.,1.,0.0), 1.0)
    await tween.finished
    tween.tween_callback(self.queue_free)
