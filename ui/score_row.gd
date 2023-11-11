extends PanelContainer

@onready var dice_examples = %DiceExample
@onready var hand_label = %HandName
@onready var description = %Description
@onready var default_font = preload("res://graphics/CompassPro.ttf")

var hand
var hand_info
var hand_name
var styles
var scratched = false
var marked = false
var score = 0
var lines = []

func _ready():
    Globals.set_score.connect(set_score)
    styles = StyleBoxFlat.new()
    styles.bg_color = Color(0,0,0,0.0)
    add_theme_stylebox_override("panel", styles)
    if hand_info:
        hand_label.text = hand_name
        description.text = hand_info["description"]
        for d in hand_info["dice"]:
            var nd = Globals.DIE.instantiate()
            nd.die_size = Vector2(20,20)
            nd.visual_only = true
            nd.value = d
            dice_examples.add_child(nd)

func _draw():
    if scratched:
        for line in lines:
            draw_line(line[0], line[1], Color("Red"), 6.8, false)
            draw_string(default_font, Vector2(size.x/2-90, size.y/2+12.5), "SCRATCH", HORIZONTAL_ALIGNMENT_CENTER, 180, 38, Color("#990000"))
    if marked:
        var text_loc = Vector2(size.x/2-25, size.y/2+12.5)
        draw_string_outline(default_font, text_loc, str(score), HORIZONTAL_ALIGNMENT_CENTER, 50, 38, 4, Color("Green"))
        draw_string(default_font, Vector2(size.x/2-25, size.y/2+12.5), str(score), HORIZONTAL_ALIGNMENT_CENTER, 50, 38, Color("#000"))


func mark_score():
    $Container.modulate.a = 0.2
    marked = true
    queue_redraw()

func scratch_score():
    $Container.modulate.a = 0.2
    var rect = get_rect()
    var rect_size = rect.size * 1.1
    var jitter = [-randi()%10, randi()%10]
    lines = [
        [Vector2(jitter[1], 0), Vector2(rect_size.x+jitter[0], rect_size.y)],
        [Vector2(rect_size.x, jitter[0]),Vector2(jitter[1], rect_size.y)],
    ]
    scratched = true
    queue_redraw()

func set_score(scoring_hand, amt):
    if scoring_hand == hand:
        if amt > 0:
            score = amt
            mark_score()
        else:
            scratch_score()

func _on_mouse_entered():
    if not scratched:
        styles.bg_color = Color(0,0,0,0.1)

func _on_mouse_exited():
    styles.bg_color = Color(0,0,0,0.0)
