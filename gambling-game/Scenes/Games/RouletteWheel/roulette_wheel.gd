extends Node2D

@onready var wheel = $Wheel

var money = Inventory.money
var bet_size = 100
var spun = false

signal get_money(m)
signal get_bet_size(b)
signal get_result(won, win_amt)
var won = false
var win_amt = 0

var numbers = [
	# green 00 = 1000, green 0 = 100
	["green", 1000], ["red", 1], ["black", 13], ["red", 36], ["black", 24],
	["red", 3], ["black", 15], ["red", 34], ["black", 22], ["red", 5],
	["black", 17], ["red", 32], ["black", 20], ["red", 7], ["black", 11],
	["red", 30], ["black", 26], ["red", 9], ["black", 28], ["green", 100],
	["black", 2], ["red", 14], ["black", 35], ["red", 23], ["black", 4],
	["red", 16], ["black", 33], ["red", 21], ["black", 6], ["red", 18], 
	["black", 31], ["red", 19], ["black", 8], ["red", 12], ["black", 29],
	["red", 25], ["black", 10], ["red", 27]
]

var bets = [] # Size of 38, one for each slot

var bet_rules = {
	61: func(n, _c): return n >= 1 and n <= 18,
	62: func(n, _c): return n % 2 == 0,
	63: func(_n, c): return c == "red",
	64: func(_n, c): return c == "black",
	65: func(n, _c): return n % 2 == 1,
	66: func(n, _c): return n >= 19 and n <= 36,
	
	121: func(n): return n >= 1 and n <= 12,
	122: func(n): return n >= 13 and n <= 24,
	123: func(n): return n >= 25 and n <= 36,
	124: func(n): return n%3==1,
	125: func(n): return n%3==2,
	126: func(n): return n%3==0
}

func _ready() -> void:
	get_money.emit(money)
	get_bet_size.emit(bet_size)

func random_number():
	if spun:
		return
	# random number between 0 and 37
	var random_int = randi() % 38
	print(random_int)
	print(numbers[random_int])
	return random_int

func check_bets(jackpot):
	if spun:
		return
	# get the number on the wheel from the index
	var win_num = numbers[jackpot][1]
	var win_color = numbers[jackpot][0]
	for bet in bets:
		print(bet)
		if bet == win_num:
			print("WIN! 35:1")
			money += 36*bet_size
			win_amt += 36*bet_size
			won = true
		if bet>=61 && bet<=66:
			if bet_rules[bet].call(win_num, win_color):
				print("WIN! 1:1")
				money += 2*bet_size
				win_amt += 2*bet_size
				won = true
		if bet>=121 && bet<=126:
			if bet_rules[bet].call(win_num):
				print("WIN! 2:1")
				money += 3*bet_size
				win_amt += 3*bet_size
				won = true
	
	if !won:
		print("LOSE :(")
	
	print("MONEY: ", money)
		
	


# on spin pressed, will send signal to table, which will get bets and send to here
func _on_finalized_bets(b: Array) -> void:
	if spun:
		return
	
	bets = b
	print(bets)
	money -= (bets.size() * bet_size)
	
	var random_num = random_number()
	wheel.spin_wheel(random_num)
	check_bets(random_num)
	spun = true


func _on_play_again_pressed() -> void:
	bets.clear()
	spun = false


func _on_wheel_stopped() -> void:
	get_money.emit(money)
	get_result.emit(won, win_amt)
	Inventory.money = money
