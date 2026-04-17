extends Control

@onready var day_label: Label = $DayLabel
@onready var day_progress_bar: ProgressBar = $DayProgressBar
@onready var debt_label: Label = $DebtLabel
@onready var deadline_label: Label = $DeadlineLabel
@onready var limbs_label: Label = $LimbsLabel
@onready var money_label: Label = $MoneyLabel

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.debt_changed.connect(_on_debt_changed)
	GameManager.limb_lost.connect(_on_limb_lost)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_won.connect(_on_game_won)

	_refresh_all()

func _process(_delta: float) -> void:
	money_label.text = "Money: $" + str(GameManager.money)

func _refresh_all() -> void:
	_on_day_changed(GameManager.current_day)
	_on_time_changed(
		GameManager.get_day_progress(),
		GameManager.get_seconds_left_in_day(),
		GameManager.current_day
	)
	_on_debt_changed(
		GameManager.debt_round_index + 1,
		GameManager.get_current_amount_due(),
		GameManager.total_paid
	)

	var limbs_text := "Lost limbs: "
	if GameManager.lost_limbs.is_empty():
		limbs_text += "None"
	else:
		limbs_text += ", ".join(GameManager.lost_limbs)
	limbs_label.text = limbs_text

	money_label.text = "Money: $" + str(GameManager.money)

func _on_day_changed(day: int) -> void:
	day_label.text = "Day " + str(day)

func _on_time_changed(day_progress: float, seconds_left_in_day: float, _current_day: int) -> void:
	day_progress_bar.value = 100.0 - (day_progress * 100.0)

	var mins := int(seconds_left_in_day) / 60
	var secs := int(seconds_left_in_day) % 60
	var deadline_time := GameManager.get_time_until_debt_check()
	var deadline_mins := int(deadline_time) / 60
	var deadline_secs := int(deadline_time) % 60

	deadline_label.text = "Day ends in %02d:%02d | Shark in %02d:%02d" % [
		mins, secs, deadline_mins, deadline_secs
	]

func _on_debt_changed(current_round: int, amount_due: int, total_paid: int) -> void:
	if GameManager.is_game_won:
		debt_label.text = "Debt paid: $10000 / $10000"
	else:
		debt_label.text = "Round %d due: $%d | Paid: $%d / $10000" % [
			min(current_round, 3),
			amount_due,
			total_paid
		]

func _on_limb_lost(limb_name: String, _limbs_lost: int) -> void:
	var limbs_text := "Lost limbs: " + ", ".join(GameManager.lost_limbs)
	limbs_label.text = limbs_text

func _on_game_over() -> void:
	#should switch to ending scene (lose)
	debt_label.text = "GAME OVER"
	deadline_label.text = "The loan shark got you."

func _on_game_won() -> void:
	#should switch to ending scene (win)
	debt_label.text = "Debt paid off!"
	deadline_label.text = "You survived the casino."
