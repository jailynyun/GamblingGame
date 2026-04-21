extends Control

var card_names = []
var card_values = []
var card_images = {}

var playerScore = 0
var dealerScore = 0
var playerCards = []
var dealerCards = []

var cardsShuffled = {}

var ace_found

var MIN_X = 83.33
var MIN_Y = 116.66

var money = 1000
var curr_bet = 0
var round_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$amount.text = "$" + str(money)
	$bet.text = "$" + str(curr_bet)
	#$Buttons/VBoxContainer/Replay.visible = false
	$WinnerText.visible = false
	$PlayerHitMarker.visible = false
	$DealerHitMarker.visible = false
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	get_tree().root.content_scale_factor
	updateText()
	update_ui()
	if curr_bet == 0:
		$Play.disabled = true
	
		
	## Create cards
	#updateText()
	#create_card_data()
	#
	## Generate initial 2 player cards	
	#await get_tree().create_timer(0.7).timeout
	#generate_card("player")
	#updateText()
	#await get_tree().create_timer(0.5).timeout
	#generate_card("player")
	#updateText()
	#
	## Generate dealers cards; note how first one is true as we want to show the back
	#await get_tree().create_timer(0.5).timeout
	#generate_card("dealer", true)
	#updateText()
	#await get_tree().create_timer(0.5).timeout
	#generate_card("dealer")
	#updateText()
	#await get_tree().create_timer(1).timeout
	#
	#if playerScore == 21:
		#playerWin(true)

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _on_hit_pressed():
	#print("enter_hit")
	$PlayerHitMarker.visible = true
	generate_card("player")
	# Play "hit!" animation
	$AnimationPlayer.play("HitAnimationP")
	updateText()
	if playerScore == 21:
		_on_stand_pressed()  # Player auto-stands on 21
	elif playerScore > 21:
		check_aces()  # Check to see if any 11-aces can convert to 1-aces
		if playerScore > 21:  # Score still surpasses 21
			playerLose()
			

func check_aces():
	# If player is over 21 and has any 11-aces, convert them to 1 so they stay under 21
	while playerScore > 21:
		ace_found = false
		for card_index in range(len(playerCards)):
			if playerCards[card_index][0] == 11:  # Ace with value 11
				playerCards[card_index][0] = 1  # Convert ace to 1
				ace_found = true
				break
		if not ace_found:
			break  # No more aces to convert, exit loop
		recalculate_player_score()
		updateText()
	
	
func recalculate_player_score():
	playerScore = 0
	for card in playerCards:
		playerScore += card[0]



func _on_stand_pressed():
		
	# Flip dealer's first card, dealer keeps hitting until score is above 16 or player's score
	$Buttons/VBoxContainer/Hit.disabled = true
	#$PlayerHitMarker.visible = false #I added this. not sure if its needed
	$Buttons/VBoxContainer/Stand.disabled = true
	#$Buttons/VBoxContainer/OptionalMove.disabled = true
	$DealerHitMarker.visible = true
	$WhoseTurn.text = "Dealer's\nTurn"
	
	await get_tree().create_timer(1.5).timeout
	var dealer_hand_container = $Cards/Hands/DealerHand
	if dealer_hand_container.get_child_count() > 0:
		var child_to_remove = dealer_hand_container.get_child(0)
		child_to_remove.queue_free()
	else:
		print("Dealer hand is empty, no card to remove.")
		
	# Remove the first card from the container (the back of card texture)
	#var child_to_remove = dealer_hand_container.get_child(0)
	#child_to_remove.queue_free()  # Remove the node from the scene
	
	# Create a new TextureRect node for the card image
	var card = dealerCards[0]
	var card_texture_rect = TextureRect.new()
	var card_texture = ResourceLoader.load(card[1])
	card_texture_rect.texture = card_texture
	card_texture_rect.expand = true
	card_texture_rect.custom_minimum_size = Vector2(MIN_X, MIN_Y)  # change size here
	card_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE

	# Add the card as a child to the HBoxContainer
	dealer_hand_container.add_child(card_texture_rect)
	dealer_hand_container.move_child(card_texture_rect, 0)
	
	# Add score to dealerScore
	if card[0] == 11 and dealerScore > 10:  # Aces are 1 if score is too high for 11
		dealerScore += 1
	else:
		dealerScore += card[0]
	updateText()
	
	# Dealer hits until score surpasses player or 17
	while dealerScore < playerScore and dealerScore < 17:
		await get_tree().create_timer(1.5).timeout
		# Play "hit!" animation for dealer
		$AnimationPlayer.play("HitAnimationD")
		generate_card("dealer")
		updateText()
		
	# Evaluate results
	if dealerScore > 21 or dealerScore < playerScore:  # Dealer bust or dealer less than player
		playerWin()
	elif playerScore < dealerScore and dealerScore <= 21:  # Dealer is between player score and 22
		playerLose()
	else:  # Tie
		playerDraw()
	
	
func create_card_data():
	card_names.clear()
	card_values.clear()
	card_images.clear()
	
	# Generate card names for ranks 2 to 10
	for rank in range(2, 11):
		for suit in ["Clubs", "Diamonds", "Hearts", "Spades"]:
			card_names.append(suit + "_" + str(rank))
			card_values.append(rank)

	# Generate card names for face cards (jack, queen, king, ace)
	for face_card in ["jack", "queen", "king", "ace"]:
		for suit in ["clubs", "diamonds", "hearts", "spades"]:
			card_names.append(suit + "_" + face_card)
			if face_card != "ace":
				card_values.append(10)
			else:
				card_values.append(11)	
				
	
	# Load card values and image paths into the dictionary
	for card in range(len(card_names)):
		card_images[card_names[card]] = [card_values[card], 
			"res://Assets/Art/cards/" + card_names[card] + ".png"]
		
	#add the the of card image with key "back"
	card_images["back"] = [0, "res://Assets/Art/cards/Card_back.png"]
	
	cardsShuffled = card_names.duplicate()
	cardsShuffled.shuffle()

	
func generate_card(hand, back=false):
	if cardsShuffled.is_empty():
		create_card_data()
	# Assuming you have already loaded card images into the dictionary as shown in your code
	var random_card

	# If back is true assign card image to back
	if back:
		#only enters when after the player stands for the first time???? why?
		print("entered back")
		
		# We display the back of the card, but a real card needs to be pulled
		# so that it can be shown when the player Stands
		random_card = card_images["back"]
		dealerCards.append(card_images[cardsShuffled.pop_back()])
	else:
		# Get a random card
		var random_card_name = cardsShuffled.pop_back()
		random_card = card_images[random_card_name] 
		# random_card is an array [card value, card image path]

	# Create a new TextureRect node for card
	var card_texture = ResourceLoader.load(random_card[1])
	var card_texture_rect = TextureRect.new()
	card_texture_rect.texture = card_texture
	card_texture_rect.expand = true
	
	#CHANGE SIZE OF CARD
	card_texture_rect.custom_minimum_size = Vector2(MIN_X, MIN_Y)  
	card_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	
	# Get a reference to the existing HBoxContainer
	var card_hand_container
	if hand == "player":
		card_hand_container = $Cards/Hands/PlayerHand
		$PlayerHitMarker.visible = true
		
		if random_card[0] == 11 and playerScore > 10:  # Aces are 1 if score is too high for 11
			playerScore += 1
		else:
			playerScore += random_card[0]
		playerCards.append(random_card)
	elif hand == "dealer":
		card_hand_container = $Cards/Hands/DealerHand
		if random_card[0] == 11 and dealerScore > 10:  # Aces are 1 if score is too high for 11
			dealerScore += 1
		else:
			dealerScore += random_card[0]
		dealerCards.append(random_card)
	else:
		return
		
	# Add the card as a child to the HBoxContainer
	card_hand_container.add_child(card_texture_rect)


func updateText():
	# Update the labels displayed on screen for the dealer and player scores.
	$DealerScore.text = str(dealerScore)
	$PlayerScore.text = str(playerScore)


func playerLose():
	# Player has lost: display red text, disable buttons, ask to play again
	$WinnerText.text = "DEALER\nWINS"
	$WinnerText.set("theme_override_colors/font_color", "ff5342")
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	#don't show any marker
	$PlayerHitMarker.visible = false
	$DealerHitMarker.visible = false
	#$Buttons/VBoxContainer/OptionalMove.disabled = true
	await get_tree().create_timer(1).timeout
	$WinnerText.visible = true
	await get_tree().create_timer(0.5).timeout
	#$Buttons/VBoxContainer/Replay.visible = true
	$Play.disabled = false
	
	#update_ui()
	money -= curr_bet
	reset_ui()
	
	$Play.text = "Play Again"
	$Play.disabled = curr_bet <= 0
	
func playerWin(blackjack=false):
	
	# Player has won: display text (already set if not blackjack),
	# display buttons and ask to play again
	if blackjack:
		$WinnerText.text = "PLAYER WINS\nBY BLACKJACK"
		$WinnerText.set("theme_override_colors/font_color", "#daffd6")
	
	$WinnerText.text = "PLAYER\nWINS"
	$WinnerText.set("theme_override_colors/font_color", "#daffd6")
	
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	#don't show any marker
	$PlayerHitMarker.visible = false
	$DealerHitMarker.visible = false
	
	#$Buttons/VBoxContainer/OptionalMove.disabled = true
	
	await get_tree().create_timer(1).timeout
	$WinnerText.visible = true
	await get_tree().create_timer(0.5).timeout
	#$Buttons/VBoxContainer/Replay.visible = true
	
	money += (2 * curr_bet)
	#update_ui()
	reset_ui()
	
	$Play.text = "Play Again"
	$Play.disabled = curr_bet <= 0
	
	
func playerDraw():
	# Nobody wins: display white text, disable buttons and ask to play again
	$WinnerText.text = "DRAW"
	$WinnerText.set("theme_override_colors/font_color", "white")
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	$PlayerHitMarker.visible = false
	$DealerHitMarker.visible = false
	
	#$Buttons/VBoxContainer/OptimalMove.disabled = true
	await get_tree().create_timer(1).timeout
	$WinnerText.visible = true
	await get_tree().create_timer(0.5).timeout
	#$Buttons/VBoxContainer/Replay.visible = true
	
	
	#update_ui()
	reset_ui()
	
	$Play.text = "Play Again"
	$Play.disabled = curr_bet <= 0


func _on_exit_pressed():
	get_tree().quit()


func _on_replay_pressed():
	reset_board()

func reset_ui():
	curr_bet = 0
	
	$Money.disabled = false
	round_active = false
	
	
	update_ui()
	
	
#NOT USING OPTIMAL MOVE
func _on_button_pressed():
	# AI logic to determine optimal move
	
	if len(dealerCards) < 2:  # Player clicked button before dealer cards loaded
		return
	var dealerUpCard = dealerCards[2][0]
	var hasAce = playerHasAce(playerCards)
	
	if hasAce:
		# Handle cases when player has an ace
		if playerScore >= 19:
			_on_stand_pressed()
		elif playerScore == 18 and dealerUpCard <= 8:
			_on_stand_pressed()
		elif playerScore == 18 and dealerUpCard >= 9:
			_on_hit_pressed()
		else:
			_on_hit_pressed()
	else:
		# Handle cases when player does not have an ace
		if playerScore >= 17 and playerScore <= 20:
			_on_stand_pressed()
		elif playerScore >= 13 and playerScore <= 16:
			if dealerUpCard >= 2 and dealerUpCard <= 6:
				_on_stand_pressed()
			else:
				_on_hit_pressed()
		elif playerScore == 12:
			if dealerUpCard >= 4 and dealerUpCard <= 6:
				_on_stand_pressed()
			else:
				_on_hit_pressed()
		elif playerScore >= 4 and playerScore <= 11:
			_on_hit_pressed()
		else:
			_on_stand_pressed()

func playerHasAce(cards):
	for card in cards:
		if card[0] == 11:
			return true
	return false


func _on_money_pressed() -> void:
	#money -= 100
	curr_bet += 100
	update_ui()

func update_ui():
	$amount.text = "$" + str(money)
	$bet.text = "$" + str(curr_bet)
	
	$Money.disabled = round_active or money < 100
	$Play.disabled = curr_bet <= 0
	
func reset_board():
	# Reset scores and hands
	playerScore = 0
	dealerScore = 0
	playerCards.clear()
	dealerCards.clear()
	ace_found = false
	
	# Reset deck data
	card_names.clear()
	card_values.clear()
	card_images.clear()
	cardsShuffled.clear()
	
	# Clear card visuals
	for child in $Cards/Hands/PlayerHand.get_children():
		child.queue_free()
		
	for child in $Cards/Hands/DealerHand.get_children():
		child.queue_free()
	
	# Reset round UI
	$WinnerText.visible = false
	$WinnerText.text = ""
	$PlayerHitMarker.visible = false
	$DealerHitMarker.visible = false
	$WhoseTurn.text = "Player's\nTurn"
	#$Buttons/VBoxContainer/Replay.visible = false
	$Play.disabled = false
	
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	#$Play.disabled = true
	
	round_active = false
	updateText()
	update_ui()

func _on_play_pressed() -> void:
	if curr_bet <= 0:
		return
	
	reset_board()
	round_active = true
	$Buttons/VBoxContainer/Stand.disabled = false
	$Buttons/VBoxContainer/Hit.disabled = false
	$Play.disabled = true
	
	$Money.disabled = true
	# Create cards
	
	create_card_data()
	
	# Generate initial 2 player cards	
	await get_tree().create_timer(0.7).timeout
	generate_card("player")
	updateText()
	await get_tree().create_timer(0.5).timeout
	generate_card("player")
	updateText()
	
	# Generate dealers cards; note how first one is true as we want to show the back
	await get_tree().create_timer(0.5).timeout
	generate_card("dealer", true)
	updateText()
	await get_tree().create_timer(0.5).timeout
	generate_card("dealer")
	updateText()
	await get_tree().create_timer(1).timeout
	
	if playerScore == 21:
		playerWin(true)
