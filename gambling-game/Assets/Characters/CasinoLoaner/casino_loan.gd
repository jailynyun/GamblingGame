extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var loan_menu = $LoanMenu
@onready var player = $"../Player"

func _ready() -> void:
	loan_menu.visible = false
	interactable.interact = _on_interact
	GameManager.day_changed.connect(_on_day_changed)
	
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	
func _on_interact():
	Dialogic.VAR.money = GameManager.money
	Dialogic.VAR.loan_amount = GameManager.loan_amount
	
	if GameManager.loan_amount == 0:
		Dialogic.start("casino_loan")
	else:
		Dialogic.start("loaned_money")
	player.can_move = false
	
func _on_dialogic_signal(argument: String):
	if argument == "loan_menu":
		loan_menu.visible = true
		player.can_move = false
	
	if argument == "pay_back":
		pay_back_loan()
		
	if argument == "leave_convo":
		player.can_move = true


func _on_close_button_pressed() -> void:
	loan_menu.visible = false
	player.can_move = true
	

func _on_loan_menu_loan_submitted(loan_amt: Variant) -> void:
	GameManager.loan_amount = loan_amt * 1.5
	GameManager.money += loan_amt
	loan_menu.visible = false
	Dialogic.start("scam")

func pay_back_loan():
	GameManager.money -= GameManager.loan_amount
	GameManager.loan_amount = 0

func _on_day_changed(_day: int) -> void:
	if GameManager.loan_amount > 0:
		GameManager._lose_next_limb()
		Dialogic.start("take_a_limb")
		player.can_move = false
		
