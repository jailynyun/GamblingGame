extends Node

signal day_changed(day: int)
signal time_changed(day_process: float, seconds_left_in_day: float, current_day: int)
signal debt_changed(current_round: int, amount_due: int, total_paid: int)
signal limb_lost(limb_name: String, limbs_lost: int)
signal game_over()
signal game_won()

const DAY_LENGTH := 120.0 #120 sec = 2 min = 1 day
const DEBT_CHECK_DAYS := 2
const DEBT_CHECK_TIME := DAY_LENGTH * DEBT_CHECK_DAYS #4 min

const DEBT_ROUNDS : Array[int] = [2000, 3000, 5000]
const LIMB_ORDER : Array[String] = ["Arm", "Eye", "Leg"]

var money: int = 500 #start w 500

var elapsed_time: float = 0.0
var current_day: int = 1

var debt_round_index: int = 0
var total_paid: int = 0

var time_since_last_debt_check: float = 0.0
var limbs_lost_count: int = 0
var lost_limbs: Array[String] = []

var is_game_over := false
var is_game_won := false

func _process(delta: float) -> void:
	if is_game_over or is_game_won:
		return
	
	elapsed_time += delta
	time_since_last_debt_check += delta
	
	var new_day := int(floor(elapsed_time / DAY_LENGTH)) + 1
	if new_day != current_day:
		current_day =  new_day
		day_changed.emit(current_day)
		
	var seconds_into_day := fmod(elapsed_time, DAY_LENGTH)
	var day_progress := seconds_into_day  / DAY_LENGTH
	var seconds_left_in_day := DAY_LENGTH - seconds_into_day
	
	time_changed.emit(day_progress, seconds_left_in_day, current_day)
	
	if debt_round_index < DEBT_ROUNDS.size() and time_since_last_debt_check >= DEBT_CHECK_TIME:
		time_since_last_debt_check -= DEBT_CHECK_TIME
		_handle_debt_deadline()

func _input(event: InputEvent) -> void:
	if is_game_over or is_game_won:
		return

	if event.is_action_pressed("skip"):
		skip_day()

func _handle_debt_deadline() -> void:
	if debt_round_index >= DEBT_ROUNDS.size():
		return
		
	var amount_due := get_current_amount_due()

	if money >= amount_due:
		money -= amount_due #autopay money
		total_paid += amount_due #paid round
		debt_round_index += 1 #next round starts

		var next_due := get_current_amount_due()
		debt_changed.emit(debt_round_index + 1, next_due, total_paid)

		if debt_round_index >= DEBT_ROUNDS.size():
			is_game_won = true
			game_won.emit()
	else:
		_lose_next_limb()

func _lose_next_limb() -> void:
	if limbs_lost_count >= LIMB_ORDER.size():
		is_game_over = true
		game_over.emit()
		return

	var limb_name : String = LIMB_ORDER[limbs_lost_count]
	lost_limbs.append(limb_name)
	limbs_lost_count += 1
	limb_lost.emit(limb_name, limbs_lost_count)

	if limbs_lost_count >= LIMB_ORDER.size():
		is_game_over = true
		game_over.emit()

func get_current_amount_due() -> int:
	if debt_round_index >= DEBT_ROUNDS.size():
		return 0
	return DEBT_ROUNDS[debt_round_index]

func add_money(amount: int) -> void:
	money += amount

func remove_money(amount: int) -> void:
	money = max(0, money - amount)

func get_day_progress() -> float:
	var seconds_into_day := fmod(elapsed_time, DAY_LENGTH)
	return seconds_into_day / DAY_LENGTH

func get_seconds_left_in_day() -> float:
	var seconds_into_day := fmod(elapsed_time, DAY_LENGTH)
	return DAY_LENGTH - seconds_into_day

func get_days_until_debt_check() -> int:
	var time_left := DEBT_CHECK_TIME - time_since_last_debt_check
	return int(ceil(time_left / DAY_LENGTH))

func get_time_until_debt_check() -> float:
	return max(0.0, DEBT_CHECK_TIME - time_since_last_debt_check)

func reset_game() -> void:
	money = 500
	elapsed_time = 0.0
	current_day = 1
	debt_round_index = 0
	total_paid = 0
	time_since_last_debt_check = 0.0
	limbs_lost_count = 0
	lost_limbs.clear()
	is_game_over = false
	is_game_won = false

	debt_changed.emit(1, get_current_amount_due(), total_paid)
	time_changed.emit(0.0, DAY_LENGTH, current_day)
	day_changed.emit(current_day)
	
func skip_day() -> void:
	var seconds_into_day := fmod(elapsed_time, DAY_LENGTH)
	var seconds_to_next_day := DAY_LENGTH - seconds_into_day

	# safety: if already exactly at boundary
	if is_zero_approx(seconds_to_next_day):
		seconds_to_next_day = DAY_LENGTH

	elapsed_time += seconds_to_next_day
	time_since_last_debt_check += seconds_to_next_day

	# force update immediately (instead of waiting for _process)
	var new_day := int(floor(elapsed_time / DAY_LENGTH)) + 1
	if new_day != current_day:
		current_day = new_day
		day_changed.emit(current_day)

	var seconds_into_day_new := fmod(elapsed_time, DAY_LENGTH)
	var day_progress := seconds_into_day_new / DAY_LENGTH
	var seconds_left := DAY_LENGTH - seconds_into_day_new

	time_changed.emit(day_progress, seconds_left, current_day)

	# handle debt if we crossed a deadline
	while debt_round_index < DEBT_ROUNDS.size() and time_since_last_debt_check >= DEBT_CHECK_TIME:
		time_since_last_debt_check -= DEBT_CHECK_TIME
		_handle_debt_deadline()
