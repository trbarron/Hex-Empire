# GameManager.gd
extends Node

signal turn_changed(player_index)
signal card_played(card, position)

var players = []
var current_player_index = 0

func _ready():
	initialize_game()

func initialize_game():
	# Create players (for simplicity, we'll create 2 players)
	for i in range(2):
		players.append({
			"hand": [],
			"deck": create_deck()
		})
	start_turn()

func create_deck():
	# Placeholder function to create a deck of cards
	var deck = []
	for i in range(20):  # Create 20 cards for each player
		var card = load("res://scenes/card.tscn").instantiate()
		card.card_name = "Card " + str(i)
		card.cost = randi() % 3 + 1  # Random cost between 1 and 3
		card.effect = "Sample effect"
		deck.append(card)
	return deck

func start_turn():
	var current_player = players[current_player_index]
	if current_player.hand.size() < 5:  # Draw up to 5 cards
		var cards_to_draw = 5 - current_player.hand.size()
		for i in range(cards_to_draw):
			if current_player.deck.size() > 0:
				var card = current_player.deck.pop_back()
				current_player.hand.append(card)
	emit_signal("turn_changed", current_player_index)

func end_turn():
	current_player_index = (current_player_index + 1) % players.size()
	start_turn()

func play_card(card, position):
	var current_player = players[current_player_index]
	if card in current_player.hand:
		current_player.hand.erase(card)
		emit_signal("card_played", card, position)
		# Implement card effect here
