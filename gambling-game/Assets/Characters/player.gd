extends CharacterBody2D

# Movement Settings
@export var acceleration := 50.0
@export var max_speed := 500.0
@onready var sprite2D = %Sprite2D
var walk_time := 0.0
var wobble_speed := 12.0
var wobble_rotation := 15 # In Degrees
var min_squash_percent := .2 # Sprite2D will squash at least 20%
var max_squash_percent := .4 # Sprite2D will squash at most 40%

func _physics_process(delta):
	# Player Movement
	var input_vector := Vector2(Input.get_axis("left","right"), Input.get_axis("forward","backward")).normalized()
	
	# Player Movement Acceleration
	if (input_vector != Vector2.ZERO):
		# Link acceleration to frame rate
		velocity += input_vector * acceleration
		velocity = velocity.limit_length(max_speed)
	
	# Player Movement Decceleration
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	
	move_and_slide()
	
	var speed = velocity.length()
	
	# Player Movement Animation
	if speed > acceleration:
		# Measure Walk Time as Time to get an increasing value
		walk_time += delta
		# Sin produces a value from -1 to 1, and a full oscillation takes 2π ≈ 6 seconds if we use sin(walk_time)
		# So multiply walk_time with wobble_speed to increase the rate that the wave oscillatesd
		var wave = sin(walk_time * wobble_speed)
		# Returns 1.0 when the speed reaches max_speed
		var intensity = clamp(speed / max_speed, 0.0, 1.0)
		# Link the sprite rotation to the wobble rotation in degrees, multiply by intensity 
		# to get max rotation at max speed
		sprite2D.rotation_degrees = wave * wobble_rotation * intensity
		# Squash range to create max squash at low speed, and low squash at high speed, that way the character has
		# a boing effect when the player barely moves
		var squash_range = lerp(max_squash_percent, min_squash_percent, intensity)
		var squash_amount = abs(wave) * squash_range
		sprite2D.scale.y = 1.0 - squash_amount
		sprite2D.scale.x = 1.0 + squash_amount
	else:
		# Reset Values
		walk_time = 0.0
		sprite2D.rotation_degrees = lerp(sprite2D.rotation_degrees, 0.0, delta * 10.0)
		sprite2D.scale.y = lerp(sprite2D.scale.y, 1.0, delta * 10.0)
		sprite2D.scale.x = lerp(sprite2D.scale.x, 1.0, delta * 10.0)
