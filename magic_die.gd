extends RigidBody3D

var rotation_speed = 10  # Rotation speed in degrees per frame
var jump_height = 2  # Jump height in units
var jump_duration = 1  # Jump duration in seconds

func _ready():
	# Call the function to start the bouncing and rotating effect
	jump_and_rotate()

func bounce_and_rotate():
	set_axis_velocity(Vector3(0,0,0))
	# Apply a random impulse to the cube to make it bounce
	var impulse = Vector3(randf(), randf(), randf()).normalized() * 10
	apply_impulse(Vector3(0, 0, 0), impulse)
	
	# Generate a random rotation axis and angle
	var rotation_axis = Vector3(randf(), randf(), randf()).normalized()
	var rotation_angle = randf() * 2000  # You can adjust the rotation speed by changing the multiplier
	# Rotate the cube using the generated axis and angle
	apply_torque_impulse(Vector3(randf(),randf(),randi()%5))
	#rotation_degrees = Vector3(randi()%90,randi()%90,randi()%90)
	#angular_velocity = Vector3(randi()%180,randi()%180,randi()%180)


func jump_and_rotate():
	global_position.x = 0
	global_position.z = 0
	global_position.y = 10
	#apply_impulse(Vector3(randf(), randf(), randf())*5)
	#apply_torque_impulse(Vector3(randi()%5, randi()%5, randi()%5))
	
	#var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	# Jump animation
	#var jump_target = Vector3(position.x, position.y+jump_height, position.z)
	#tween.tween_property(self, 'position', jump_target, 0.3)
	# Rotation animation
	#var start_rotation = rotation_degrees
	#var end_rotation = rotation_degrees + Vector3(randi()%360, randi()%360, randi()%360)  # One full rotation
	#tween.tween_property(self, 'rotation_degrees', end_rotation, 0.3)
	#tween.interpolate_property(self, 'rotation_degrees:x', start_rotation.x, end_rotation.x, jump_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	#tween.interpolate_property(self, 'rotation_degrees:y', start_rotation.y, end_rotation.y, jump_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	#tween.interpolate_property(self, 'rotation_degrees:z', start_rotation.z, end_rotation.z, jump_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	# Connect signals for animation completion
	#tween.tween_callback(_on_jump_complete)

func _on_jump_complete():
	print("All done")
	# Animation complete, stop rotating and reset position
	# rotation_degrees = Vector3(0, 0, 0)
	# global_transform.origin.y = 0

func get_face_index_from_normal(normal: Vector3) -> int:
	# Define the normals of the six faces of a cube
	var face_normals = [
		Vector3(0, 1, 0),  # Top face
		Vector3(0, -1, 0),  # Bottom face
		Vector3(1, 0, 0),  # Right face
		Vector3(-1, 0, 0),  # Left face
		Vector3(0, 0, 1),  # Front face
		Vector3(0, 0, -1)  # Back face
	]
	
	# Find the index of the closest matching face normal
	var closest_index = 0
	var closest_dot = -1.0
	
	for i in range(6):
		var dot = face_normals[i].dot(normal)
		if dot > closest_dot:
			closest_dot = dot
			closest_index = i
	
	return closest_index


func _on_body_entered(body):
	print("Wassup")

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("Hi")



func _on_sleeping_state_changed():
	
	# Get the normal of the face the cube landed on
	var landed_face_normal = -transform.basis.y
	
	# Determine the face index based on the normal
	var face_index = get_face_index_from_normal(landed_face_normal)
	
	# Print the landed face index
	print("Cube landed on face:", face_index)
