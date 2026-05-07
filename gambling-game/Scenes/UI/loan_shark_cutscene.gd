extends Node2D

@onready var shark = $LoanShark

var door_in: Marker2D
var player: Node2D
var door_out: Marker2D

func setup_refs(_door_in, _player, _door_out):
	door_in = _door_in
	player = _player
	door_out = _door_out

func _ready() -> void:
	visible = false
	GameManager.loanshark_cutscene_started.connect(_start_cutscene)

func _start_cutscene(amount_due: int) -> void:
	visible = true

	shark.global_position = door_in.global_position

	# move using code instead of AnimationPlayer positions
	await move_shark(player.global_position, 1.5)

	GameManager.resolve_loanshark_cutscene()

	await get_tree().create_timer(1.5).timeout

	await move_shark(door_out.global_position, 1.5)

	visible = false
	GameManager.finish_loanshark_cutscene()

func move_shark(target: Vector2, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(shark, "global_position", target, duration)
	await tween.finished
