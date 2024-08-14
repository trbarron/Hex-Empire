extends Node2D

@onready var game_board = $GameBoard
@onready var game_manager = $GameManager
@onready var hand_container = $UI/HandContainer
@onready var turn_label = $UI/TurnLabel

var dragged_card = null

func _ready():
	connect_signals()
	setup_game()


func setup_game():
	game_manager.game_board = game_board
	game_manager.initialize_game()

func connect_signals():
	game_manager.connect("turn_changed", Callable(self, "_on_turn_changed"))
	game_manager.connect("game_over", Callable(self, "_on_game_over"))

func _on_turn_changed(player_index):
	turn_label.text = "Player " + str(player_index + 1) + "'s Turn"
	update_hand_display()

func update_hand_display():
	# Clear existing cards
	for child in hand_container.get_children():
		child.queue_free()
	
	# Add cards from current player's hand
	var current_player = game_manager.players[game_manager.current_player_index]
	for i in range(current_player.hand.size()):
		var card = current_player.hand[i]
		hand_container.add_child(card)
		
		# Adjust card position and scale
		card.scale = Vector2(0.5, 0.5)  # Scale down the card if needed
		card.position.y = -50 * sin(PI * i / (current_player.hand.size() - 1))  # Create an arc effect
		card.position.x = 200 * i

func _on_game_over(winner):
	print("Game over! Winner: Player ", winner)
	show_game_over_screen(winner)

func update_ui_for_new_turn(player_index):
	# Update UI elements to reflect the new turn
	pass

func show_game_over_screen(winner):
	# Show a game over screen with the winner
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = game_board.world_to_grid(get_global_mouse_position())
		if dragged_card and game_board.can_play_card(dragged_card, grid_pos):
			play_card(dragged_card, grid_pos)
			dragged_card = null
		else:
			handle_board_click(event.position)

func _process(delta):
	if dragged_card:
		var grid_pos = game_board.world_to_grid(get_global_mouse_position())
		game_board.highlight_valid_moves(dragged_card)

func try_play_card(card):
	dragged_card = card
	game_board.highlight_valid_moves(card)

func play_card(card, grid_pos):
	if game_board.play_card(card, grid_pos):
		var current_player = game_manager.players[game_manager.current_player_index]
		current_player.hand.erase(card)
		update_hand_display()
		game_board.clear_highlights()


func handle_board_click(click_position):
	var grid_pos = game_board.world_to_grid(click_position)
	if game_board.is_valid_grid_pos(grid_pos):
		# Handle the click on a valid board position
		# This might involve playing a card, selecting a piece, etc.
		pass


func _on_end_turn_button_pressed():
	game_manager.end_turn()
