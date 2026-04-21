extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var loan_menu = $LoanMenu
@onready var player = $"../Player"

func _ready() -> void:
	loan_menu.visible = false
	interactable.interact = _on_interact
	
func _on_interact():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("casino_loan_timeline")
	player.can_move = false
	
func _on_dialogic_signal(argument: String):
	if argument == "loan_menu":
		loan_menu.visible = true
		player.can_move = false
		
	if argument == "leave_convo":
		player.can_move = true


func _on_close_button_pressed() -> void:
	loan_menu.visible = false
	player.can_move = true
	Dialogic.start("scam_timeline")
	
