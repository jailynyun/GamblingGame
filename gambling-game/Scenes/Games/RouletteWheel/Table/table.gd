extends Control

var bets = []

signal finalized_bets(b:Array)
signal bet_added

func _on_bet_added(num_clicked) -> void:
	bets.push_back(num_clicked)
	bet_added.emit()


func _on_spin_pressed() -> void:
	finalized_bets.emit(bets)
