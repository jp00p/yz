extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $ParallaxLayer.motion_offset.x += 0.05
    $ParallaxLayer.motion_offset.y -= 0.07
