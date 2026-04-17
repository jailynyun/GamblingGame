extends Area2D

@export var interact_name: String = ""
@export var is_interactable: bool = true
@export var target_scene: PackedScene
@export var casino_ui_path: NodePath

func interact() -> void:
	if target_scene == null:
		return

	var casino_ui = get_node(casino_ui_path)
	casino_ui.open_minigame(target_scene)
