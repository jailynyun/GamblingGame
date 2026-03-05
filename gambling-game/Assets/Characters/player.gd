extends CharacterBody2D

# Movement Settings
@export var acceleration := 40.0
@export var max_speed := 500.0
@onready var sprite2D = %Sprite2D
var walk_time := 0.0

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
	
	var speed = velocity.length()
	
	# Player Movement Animation
	if speed > 10:
		walk_time += delta
		var wave = sin(walk_time * 12.0)
		var intensity = clamp(speed / max_speed, 0.0, 1.0)
		var time = Time.get_ticks_msec() / 1000.0
		sprite2D.rotation = sin(time * 12.0) * 0.15
		var squash_amount = abs(wave) * 0.1 * intensity
		sprite2D.scale.y = 1.0 - squash_amount
		sprite2D.scale.x = 1.0 + squash_amount
	else:
		sprite2D.rotation = lerp(sprite2D.rotation, 0.0, delta * 10.0)
