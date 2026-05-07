extends Node2D

@onready var minigame_ui = $Minigame_UI
@onready var cutscene = $"Y-sort/LoanSharkCutscene"
@onready var door_in = $Markers/DoorIn
@onready var player = $"Y-sort/Player"
@onready var door_out = $Markers/DoorOut


func _ready() -> void:
	minigame_ui.visible = true
	cutscene.setup_refs(door_in, player, door_out)
