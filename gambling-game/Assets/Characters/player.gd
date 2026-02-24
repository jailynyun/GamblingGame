extends CharacterBody2D

# Movement Settings
@export var acceleration := 40.0
@export var max_speed := 500.0

func _physics_process(delta):
	# Player Movement
	var input_vector := Vector2(Input.get_axis("left","right"), Input.get_axis("forward","backward"))
	
	# Player Movement Acceleration
	if (input_vector != Vector2.ZERO):
		velocity += input_vector * acceleration
		velocity = velocity.limit_length(max_speed)
	
	# Player Movement Decceleration
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	
	move_and_slide()
