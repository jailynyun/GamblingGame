extends Sprite2D

@onready var skip_button : Button = $"../Buttons/Skip"
@onready var play_again_button : Button = $"../Buttons/PlayAgain"

var numbers := 38              # how many slots on the wheel

var velocity = 0.5
var deceleration                     # how fast it slows
var target_angle := 0.0
var spun := false

signal wheel_stopped

func _ready() -> void:
	skip_button.visible = false
	play_again_button.visible = false

func _process(delta):
	if spun:
		skip_button.visible = true
		velocity = max(velocity - deceleration * delta, 0.0)
		rotation += velocity * delta
		if velocity == 0:
			wheel_stopped.emit()
			skip_button.visible = false
			play_again_button.visible = true
		
	else:
		rotation += velocity * delta
		play_again_button.visible = false
		
	
		
	
	
func spin_wheel(number: int):
	if spun:
		return
	
	velocity = 3
	
	# angle per slot
	var angle_step = TAU / numbers
	var current_rotation = global_rotation

	# align number to top (adjust -PI/2 if needed)
	target_angle = number * angle_step

	# make sure it spins extra rounds before stopping
	target_angle += TAU * 2
	
	var displacement = (target_angle - current_rotation)
	print("target angle: ", target_angle)
	print("current rotation: ", current_rotation)
	print("displacement: ", displacement)
	
	# calculating deceleration 
	deceleration = (velocity*velocity)/(2*displacement)
	print("dec: ",deceleration)
	
	spun = true




func _on_play_again_pressed() -> void:
	spun = false
	velocity = .5


func _on_skip_pressed() -> void:
	if spun:
		velocity = 0
		rotation = target_angle
