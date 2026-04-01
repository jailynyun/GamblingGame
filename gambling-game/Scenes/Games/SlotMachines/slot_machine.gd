extends Control 

@export var n_options: int = 5 
@export var spinners: Array[Control] 

@onready var spin_button: Button = $SpinButton
@onready var bet_up_button: Button = $BetUpButton
@onready var bet_down_button: Button = $BetDownButton
@onready var credits_label: Label = $CreditsLabel
@onready var bet_label: Label = $BetLabel
@onready var result_label: Label = $ResultLabel

var values: Array; var tween: Tween 

func spin():
	values = []
	var spin_step = 1.0 / float(n_options)
	var offsets = {}

	for s in spinners:
		values.append(randi_range(0, n_options - 1))
		offsets[s] = {
			"from": s.material.get_shader_parameter("y_offset"),
			"to": 3.0 + values[-1] * spin_step
		}

	if tween:
		tween.kill()

	tween = get_tree().create_tween()

	tween.tween_method(func(v):
		for s in spinners:
			s.material.set_shader_parameter(
				"y_offset",
				lerpf(offsets[s]["from"], offsets[s]["to"], v)
			)  # ← NO comma here
	, 0.0, 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	tween.tween_callback(func():
		for idx in spinners.size():
			spinners[idx].material.set_shader_parameter("y_offset", values[idx] * spin_step)
	)
