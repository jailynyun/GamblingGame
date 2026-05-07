extends Control

#@onready var pause_button: TextureButton = $"../PauseButton"
#@onready var canvas_layer: CanvasLayer = $PanelContainer/VBoxContainer/CanvasLayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	canvas_layer.visible = false
	$AnimationPlayer.play("RESET")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			print("enter 2nd escape")
			resume()
		else:
			print("enter 1st escape")
			pause()
#func _process(delta: float) -> void:
	#testEsc()
	

func resume():
	get_tree().paused = false
	canvas_layer.visible = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	canvas_layer.visible = true
	$AnimationPlayer.play("blur")
	
#func testEsc():
	#if Input.is_action_just_pressed("esc") and !get_tree().paused:
		#print("enter 1st escape")
		#print(get_tree().paused)
		#pause()
		#print(get_tree().paused)
	#elif Input.is_action_just_pressed("esc") and get_tree().paused:
		#print("enter 2nd escape pause menu not visible")
		#resume()
	
func _on_pause_button_pressed() -> void:
	pause()

func _on_resume_pressed() -> void:
	print("resume pressed")
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	GameManager.reset_game()


func _on_main_menu_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
