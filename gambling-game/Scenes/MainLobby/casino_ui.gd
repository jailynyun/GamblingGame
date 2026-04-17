extends CanvasLayer
class_name CasinoUI

@export var player_path: NodePath

@onready var dimmer: ColorRect = $Dimmer
@onready var mini_game_window: Control = $MiniGameWindow
@onready var subviewport: SubViewport = $MiniGameWindow/SubViewportContainer/SubViewport
@onready var close_button: Button = $MiniGameWindow/CloseButton
@onready var player = get_node("../CharacterBody2D")

var transition_tween: Tween
var is_open := false

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)

	dimmer.visible = false
	dimmer.modulate.a = 0.0

	mini_game_window.visible = false
	mini_game_window.scale = Vector2(0.92, 0.92)
	mini_game_window.modulate.a = 0.0

func open_minigame(scene_to_open: PackedScene) -> void:
	if scene_to_open == null or is_open:
		return

	for child in subviewport.get_children():
		child.queue_free()

	var game_instance := scene_to_open.instantiate()
	subviewport.add_child(game_instance)

	player.can_move = false
	is_open = true

	_play_open_transition()

func _on_close_pressed() -> void:
	if not is_open:
		return

	player.can_move = true
	is_open = false

	_play_close_transition()

func _play_open_transition() -> void:
	if transition_tween:
		transition_tween.kill()

	dimmer.visible = true
	mini_game_window.visible = true

	dimmer.modulate.a = 0.0
	mini_game_window.modulate.a = 0.0
	mini_game_window.scale = Vector2(0.92, 0.92)

	transition_tween = create_tween()
	transition_tween.set_parallel(true)
	transition_tween.tween_property(dimmer, "modulate:a", 0.55, 0.22)
	transition_tween.tween_property(mini_game_window, "modulate:a", 1.0, 0.18)
	transition_tween.tween_property(mini_game_window, "scale", Vector2(1.02, 1.02), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	transition_tween.chain().tween_property(mini_game_window, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _play_close_transition() -> void:
	if transition_tween:
		transition_tween.kill()


	transition_tween = create_tween()
	transition_tween.set_parallel(true)
	transition_tween.tween_property(dimmer, "modulate:a", 0.0, 0.18)
	transition_tween.tween_property(mini_game_window, "modulate:a", 0.0, 0.15)
	transition_tween.tween_property(mini_game_window, "scale", Vector2(0.96, 0.96), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	transition_tween.finished.connect(_finish_close)

func _finish_close() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	mini_game_window.visible = false
	dimmer.visible = false
	mini_game_window.scale = Vector2(1.0, 1.0)
