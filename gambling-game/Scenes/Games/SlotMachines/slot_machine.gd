extends Control

@export var n_options: int = 5
@export var spinners: Array[Control]

@onready var spin_button: Button = $SpinButton
@onready var credits_label: Label = $CreditsLabel
@onready var bet_label: Label = $BetLabel
@onready var result_label: Label = $ResultLabel

@onready var bet_1_button: Button = $Bet1Button
@onready var bet_5_button: Button = $Bet5Button
@onready var bet_10_button: Button = $Bet10Button
@onready var bet_25_button: Button = $Bet25Button
@onready var bet_50_button: Button = $Bet50Button
@onready var max_bet_button: Button = $MaxBetButton
@onready var reset_bet_button: Button = $ResetBetButton

var values: Array = []
var tween: Tween
var offsets := {}
var spin_step := 1.0 / float(n_options)

var credits: int = Inventory.money
var bet: int = 5

func _ready() -> void:
	randomize()

	bet_1_button.pressed.connect(func(): _set_bet(1))
	bet_5_button.pressed.connect(func(): _set_bet(5))
	bet_10_button.pressed.connect(func(): _set_bet(10))
	bet_25_button.pressed.connect(func(): _set_bet(25))
	bet_50_button.pressed.connect(func(): _set_bet(50))

	_update_ui()

func _set_bet(amount: int) -> void:
	if credits <= 0:
		return
	bet += clamp(amount, 1, credits)
	_update_ui()

func _on_max_bet_pressed() -> void:
	if credits > 0:
		bet = credits
	_update_ui()
	
func _on_reset_bet_pressed() -> void:
	bet = 0
	_update_ui()

func spin() -> void:
	if bet > credits or credits <= 0:
		result_label.text = "Not enough money!"
		return
	if bet == 0:
		result_label.text = "You need to bet to play"
		return
		
	credits -= bet
	result_label.text = "Spinning..."
	bet_1_button.disabled = true
	bet_5_button.disabled = true
	bet_10_button.disabled = true
	bet_25_button.disabled = true
	bet_50_button.disabled = true
	_update_ui()

	values.clear()
	offsets.clear()

	for s in spinners:
		var value := randi_range(0, n_options - 1)
		values.append(value)

		offsets[s] = {
			"from": s.material.get_shader_parameter("y_offset"),
			"to": 3.0 + value * spin_step
		}

	if tween:
		tween.kill()

	spin_button.disabled = true

	tween = get_tree().create_tween()
	tween.tween_method(_update_spin, 0.0, 1.0, 1.0)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_finish_spin)

func _update_spin(v: float) -> void:
	for s in spinners:
		s.material.set_shader_parameter(
			"y_offset",
			lerpf(offsets[s]["from"], offsets[s]["to"], v)
		)

func _finish_spin() -> void:
	for idx in spinners.size():
			spinners[idx].material.set_shader_parameter("y_offset", values[idx] * spin_step)

	var winnings := _calculate_winnings()
	credits += winnings
	Inventory.money = credits
	
	#bc u lose how much u put in for the bet.. maybe change back?
	if winnings > 0:
		result_label.text = "You won $" + str(winnings/2) + "!"
	else:
		result_label.text = "You lost $" + str(bet) + "."

	if credits > 0 and bet > credits:
		bet = credits

	spin_button.disabled = credits <= 0

	_update_ui()

func _calculate_winnings() -> int:
	if values.size() < 3:
		return 0

	var a = values[0]
	var b = values[1]
	var c = values[2]
	
	#3 match win 10x ur bet
	if a == b and b == c:
		return bet * 10
	#2 match win 2x ur bet but rlly ur winning just how much u bet bc u lose ur bet amt
	if a == b or b == c or a == c:
		return bet * 2

	return 0

func _update_ui() -> void:
	credits_label.text = "Money: $" + str(credits)
	bet_label.text = "Bet: $" + str(bet)

	bet_1_button.disabled = credits < 1
	bet_5_button.disabled = credits < 5
	bet_10_button.disabled = credits < 10
	bet_25_button.disabled = credits < 25
	bet_50_button.disabled = credits < 50
	max_bet_button.disabled = credits <= 0
