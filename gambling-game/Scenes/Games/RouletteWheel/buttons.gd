extends Control

var numbers_pressed = []


func _on_1_toggled(toggled_on: bool) -> void:
	numbers_pressed.push_back(1)


func _on_2_toggled(toggled_on: bool) -> void:
	numbers_pressed.push_back(2)


func _on_3_toggled(toggled_on: bool) -> void:
	numbers_pressed.push_back(3)


func _on_4_toggled(toggled_on: bool) -> void:
	numbers_pressed.push_back(4)
