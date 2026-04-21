extends TileMap

var board_size = 4
enum Layers{hidden,revealed}
var SOURCE_NUM = 0
const hidden_tile_coords = Vector2(6,2)
const hidden_tile_alt = 1
var revealed_spots = []
var tile_pos_to_atlas_pos = {}
var score = 0
var turns_taken = 0

var money = GameManager.money
var bet_size = 0
var game_started = false

@onready var betting_square: Control = $"../CanvasLayer/Betting"
@onready var bet_50_button: Button = $"../CanvasLayer/Betting/Bet50Button"
@onready var bet_100_button: Button = $"../CanvasLayer/Betting/Bet100Button"
@onready var max_bet_button: Button = $"../CanvasLayer/Betting/MaxBetButton"
@onready var reset_bet_button: Button = $"../CanvasLayer/Betting/ResetBetButton"
@onready var play_again_button: Button = $"../CanvasLayer/PlayAgain"

@onready var results_label: Label = $"../CanvasLayer/results_label"
@onready var money_label: Label = $"../CanvasLayer/money_label"
@onready var bet_label: Label = $"../CanvasLayer/bet_label"
@onready var betting_money_label: Label = $"../CanvasLayer/Betting/money_label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	betting_square.visible = true
	results_label.visible = false
	money_label.visible = false
	bet_label.visible = false
	play_again_button.visible = false
	update_text()
	
	
	bet_50_button.pressed.connect(func(): _add_bet(50))
	bet_100_button.pressed.connect(func(): _add_bet(100))
	max_bet_button.pressed.connect(func(): _add_bet(money))
	reset_bet_button.pressed.connect(_reset_bet)
	
	pass # Replace with function body.

func get_tiles_to_use():
	var chosen_tile_coords = []
	var options = range(10)
	options.shuffle()
	for i in range(board_size * int(board_size / 2)):
		var current = Vector2(options.pop_back(), 1)
		for j in range(2):
			chosen_tile_coords.append(current)
	chosen_tile_coords.shuffle()
	return chosen_tile_coords

func setup_board():
	revealed_spots.clear()
	tile_pos_to_atlas_pos.clear()
	
	var cards_to_use = get_tiles_to_use()
	for y in range(board_size):
		for x in range(board_size):
			var current_spot = Vector2(x, y)
			place_single_face_down_card(current_spot)
			var card_atlas_coords = cards_to_use.pop_back()
			tile_pos_to_atlas_pos[current_spot] = card_atlas_coords
			self.set_cell(Layers.revealed, current_spot, 
						SOURCE_NUM, card_atlas_coords)

func place_single_face_down_card(coords: Vector2):
	self.set_cell(Layers.hidden, coords, 
				SOURCE_NUM, hidden_tile_coords, hidden_tile_alt)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = Vector2(local_to_map(to_local(global_clicked)))
			print(pos_clicked)
			var current_tile_alt = get_cell_alternative_tile(Layers.hidden, pos_clicked)
			if current_tile_alt == 1 and revealed_spots.size() < 2:
				self.set_cell(Layers.hidden, pos_clicked, -1)
				revealed_spots.append(pos_clicked)
				if revealed_spots.size() == 2:
					when_two_cards_revealed()

func when_two_cards_revealed():
	# the cards match
	if tile_pos_to_atlas_pos[revealed_spots[0]] == tile_pos_to_atlas_pos[revealed_spots[1]]:
		score += 1
		revealed_spots.clear()
	else:
		# the cards did not match
		put_back_cards_with_delay()
	turns_taken += 1
	update_text()
	
	if(score == 8): # matched all pairs
		end_game()

func update_text():
	$"../CanvasLayer/score_label".text = "Score: %d" % score
	$"../CanvasLayer/turns_label".text = "Turns Taken: %d" % turns_taken
	$"../CanvasLayer/Betting/bet_label".text = "Bet: %d" % bet_size
	betting_money_label.text = "Money: %d" % money
	money_label.text = "Money: %d" % money
	bet_label.text = "Bet: %d" % bet_size
	
func put_back_cards_with_delay():
	await self.get_tree().create_timer(1.5).timeout
	for spot in revealed_spots:
		place_single_face_down_card(spot)
	revealed_spots.clear()

func end_game():
	var winnings = calculate_winnings()
	GameManager.money += winnings
	game_started = false
	
	results_label.visible = true
	if winnings != 0:
		results_label.text = "you win! +%d" % winnings
	else:
		results_label.text = "you lose!"
	
	play_again_button.visible = true

func calculate_winnings():
	var winnings = bet_size
	if(turns_taken <= 12):
		winnings *= 5 # win 500%
	elif (turns_taken <=14):
		winnings *= 2 # win 200%
	elif (turns_taken <= 17):
		winnings = int(winnings * 1.5) # win 150%
	elif (turns_taken <= 20):
		winnings = int(winnings * 1.2) # win 120%
	else:
		winnings = 0 # lose 100%
	
	return winnings

func _add_bet(amount: int):
	if game_started:
		return
	if amount <= 0:
		return
	if money <= 0:
		return

	var actual_amount = min(amount, money)
	bet_size += actual_amount
	money -= actual_amount
	update_text()

func _reset_bet():
	if game_started:
		return

	money += bet_size
	bet_size = 0
	update_text()


func _on_start_pressed() -> void:
	if bet_size <= 0:
		return
	
	GameManager.money = money
	betting_square.visible = false
	money_label.visible = true
	bet_label.visible = true
	game_started = true
	setup_board()


func _on_play_again_pressed() -> void:
	play_again_button.visible = false
	results_label.visible = false
	
	betting_square.visible = true
	
	money = GameManager.money
	bet_size = 0
	score = 0
	turns_taken = 0
	update_text()
