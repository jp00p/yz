class_name GamePopup extends Panel

signal popup_closed

func _ready():
    self.scale = Vector2.ZERO
    self.visible = false
    self.modulate.a = 0.0

func show_popup():
    visible = true
    var tween = get_tree().create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, 0.3)
    tween.parallel().tween_property(self, "modulate:a", 1.0, 0.3)
    await tween.finished

func hide_popup():
    visible = true
    var tween = get_tree().create_tween()
    tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
    await tween.finished
    visible = false
    popup_closed.emit()
    queue_free()

func _on_continue_pressed():
    hide_popup()
