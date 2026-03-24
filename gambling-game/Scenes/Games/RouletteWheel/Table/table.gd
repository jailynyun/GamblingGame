extends Control

var bets = []

signal finalized_bets(b:Array)

func _on_bet_added(num_clicked) -> void:
	bets.push_back(num_clicked)


func _on_spin_pressed() -> void:
	finalized_bets.emit(bets)
