extends Control 

@export var n_options: int = 5 
@export var spinners: Array[Control] 
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
		for s in spinners:
			s.material.set_shader_parameter("y_offset", offsets[s]["to"])
	)
#
#func spin(): 
	#values = [] 
	#var spin_step = 1.0 / float(n_options) 
	#var offsets = {} 
	#for s in spinners: 
		#values.append(randi_range(0, n_options - 1)) 
		#offsets[s] = {'from': s.material.get_shader_parameter('y_offset'), 'to': 3.0 + values[-1] * spin_step } 
		#
		#if tween: tween.kill() 
		#tween = get_tree().create_tween() 
		#tween.tween_method(func (v): 
			#for s in spinners: 
				#s.material.set_shader_parameter('y_offset', lerpf(offsets[s].from, offsets[s].to, v)),
			#0.0, 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC) 
		#tween.tween_callback(func (): 
			#for s in spinners:
				#s.material.set_shader_parameter('y_offset', offsets[s].to))
			#
