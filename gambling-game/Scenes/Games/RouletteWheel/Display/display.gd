extends Control

@onready var money_label : Label = $Money
@onready var bet_label : Label = $Bet
@onready var result_label : Label = $Result

var money = 0
var bet = 0
var spun = false

func _ready() -> void:
	_update_labels()

func _update_labels() -> void:
	money_label.text = "Money: %d" % money
	bet_label.text = "Bet: %d" % bet
	result_label.text = ""

func _on_table_bet_added() -> void:
	money -= 100
	bet += 100
	_update_labels()


func _on_get_money(m: Variant) -> void:
	money = m
	_update_labels()


func _on_play_again_pressed() -> void:
	bet = 0
	_update_labels()


func _on_get_result(won: Variant, win_amt: Variant) -> void:
	if won:
		result_label.text = "WIN!!! +%d" % win_amt
	else:
		result_label.text = "losee :(( %d" % win_amt


func _on_wheel_get_spun(s: Variant) -> void:
	spun = s


func _on_reset_pressed() -> void:
	money = GameManager.money
	bet = 0
	_update_labels()
