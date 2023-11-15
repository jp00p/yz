extends Node

var shaking_nodes = []

func _ready():
    var timer = Timer.new()
    timer.set_one_shot(false)
    timer.set_wait_time(0.3)
    timer.timeout.connect(reset_shake)
    add_child(timer)
    timer.start()

func make_shake(node_to_shake, amt):
    if is_instance_valid(node_to_shake):
        var orig_position = node_to_shake.position
        shaking_nodes.append({ "node": node_to_shake, "amount": amt, "original_position": orig_position })

func _process(_delta):
    for n in shaking_nodes:
        if is_instance_valid(n["node"]):
            print("Shaking %s" % n)
            if n["amount"] > 0:
                n["amount"] = n["amount"] * 0.9
                n["node"].position = n["node"].position + Vector2(randf_range(-n["amount"], n["amount"]),randf_range(-n["amount"], n["amount"]))

func reset_shake():
    for n in shaking_nodes:
        if n["amount"] <= 0:
            print("Erasing %s" % n)
            n["node"].position = n["original_position"]
            shaking_nodes.erase(n)
