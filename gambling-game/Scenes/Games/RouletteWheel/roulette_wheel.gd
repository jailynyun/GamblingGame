extends Node2D

@onready var wheel = $Wheel

var money = 1000

var numbers = [
	["green", 00], ["red", 1], ["black", 13], ["red", 36], ["black", 24],
	["red", 3], ["black", 15], ["red", 34], ["black", 22], ["red", 5],
	["black", 17], ["red", 32], ["black", 20], ["red", 7], ["black", 11],
	["red", 30], ["black", 26], ["red", 9], ["black", 28], ["green", 0],
	["black", 2], ["red", 14], ["black", 35], ["red", 23], ["black", 4],
	["red", 16], ["black", 33], ["red", 21], ["black", 6], ["red", 18], 
	["black", 31], ["red", 19], ["black", 8], ["red", 12], ["black", 29],
	["red", 25], ["black", 10], ["red", 27]
]

var bets = [] # Size of 38, one for each slot


func _ready() -> void:
	bets.resize(38)

func random_number():
	# random number between 0 and 37
	var random_int = randi() % 38
	print(random_int)
	print(numbers[random_int])
	return random_int
	
func _on_spin_pressed() -> void:
	var random_num = random_number()
	wheel.spin_wheel(random_num)
