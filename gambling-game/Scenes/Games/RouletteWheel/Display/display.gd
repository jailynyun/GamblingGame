extends Control

@onready var money_label : Label = $Money
var money = 1000

func _process(_delta: float) -> void:
	money_label.text = "Money: " + str(money)

func _on_table_bet_added() -> void:
	money -= 100


func _on_get_money(m: Variant) -> void:
	money = m
