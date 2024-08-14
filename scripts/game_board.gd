extends TileMap
class_name GameBoard

# Offset coordinates for hexagonal grid neighbors
const HEX_DIRECTIONS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

# Dictionary to store game pieces on the board
var pieces = {}

# Custom colors for highlighting
var highlight_color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
var valid_move_color = Color(0, 1, 0, 0.3)  # Green, semi-transparent

# Reference to a highlight overlay
var highlight_overlay: TileMap

func _ready():
	setup_highlight_overlay()

# Setup a separate TileMap for highlighting
func setup_highlight_overlay():
	highlight_overlay = TileMap.new()
	highlight_overlay.tile_set = tile_set  # Use the same tileset
	add_child(highlight_overlay)

# Convert world position to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))

# Convert grid coordinates to world position
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(grid_pos))

# Check if a grid position is valid (on the board)
func is_valid_grid_pos(grid_pos: Vector2i) -> bool:
	return get_cell_source_id(0, grid_pos) != -1

# Get all valid neighbors of a grid position
func get_neighbors(grid_pos: Vector2i) -> Array:
	var neighbors = []
	for direction in HEX_DIRECTIONS:
		var neighbor = grid_pos + direction
		if is_valid_grid_pos(neighbor):
			neighbors.append(neighbor)
	return neighbors

# Place a game piece on the board
func place_piece(piece, grid_pos: Vector2i):
	if is_valid_grid_pos(grid_pos) and not grid_pos in pieces:
		pieces[grid_pos] = piece
		piece.position = grid_to_world(grid_pos)
		add_child(piece)
		return true
	return false

# Remove a game piece from the board
func remove_piece(grid_pos: Vector2i):
	if grid_pos in pieces:
		var piece = pieces[grid_pos]
		pieces.erase(grid_pos)
		remove_child(piece)
		return piece
	return null

# Get a piece at a specific grid position
func get_piece(grid_pos: Vector2i):
	return pieces.get(grid_pos)

# Highlight a specific cell
func highlight_cell(grid_pos: Vector2i, color: Color = highlight_color):
	# Assuming your tileset has a tile with atlas coordinates (0, 0) for highlighting
	highlight_overlay.set_cell(0, grid_pos, 0, Vector2i(0, 0))
	highlight_overlay.set_cell_modulate(0, grid_pos, color)

# Remove highlight from a specific cell
func unhighlight_cell(grid_pos: Vector2i):
	highlight_overlay.erase_cell(0, grid_pos)

# Clear all highlights
func clear_highlights():
	highlight_overlay.clear()

# Highlight all valid move positions for a card
func highlight_valid_moves(card):
	for y in range(get_used_rect().position.y, get_used_rect().end.y):
		for x in range(get_used_rect().position.x, get_used_rect().end.x):
			var grid_pos = Vector2i(x, y)
			if can_play_card(card, grid_pos):
				highlight_cell(grid_pos, valid_move_color)

# Check if a card can be played at a specific grid position
func can_play_card(card, grid_pos: Vector2i) -> bool:
	# Basic check: cell is valid and empty
	if not is_valid_grid_pos(grid_pos) or grid_pos in pieces:
		return false
	
	# Add more complex rules here, for example:
	# - Check if the card is adjacent to a friendly piece
	# - Check if the card meets terrain requirements
	# - Check if the player has enough resources to play the card
	
	# For now, we'll just check if there's an adjacent piece
	var has_adjacent_piece = false
	for neighbor in get_neighbors(grid_pos):
		if neighbor in pieces:
			has_adjacent_piece = true
			break
	
	return has_adjacent_piece or pieces.is_empty()

# Play a card at a specific grid position
func play_card(card, grid_pos: Vector2i) -> bool:
	if can_play_card(card, grid_pos):
		return place_piece(card, grid_pos)
	return false

# Get all occupied positions on the board
func get_occupied_positions() -> Array:
	return pieces.keys()

# Find path between two positions (using A* algorithm)
func find_path(start: Vector2i, end: Vector2i) -> Array:
	var astar = AStar2D.new()
	
	# Add all valid positions to AStar
	for y in range(get_used_rect().position.y, get_used_rect().end.y):
		for x in range(get_used_rect().position.x, get_used_rect().end.x):
			var pos = Vector2i(x, y)
			if is_valid_grid_pos(pos):
				astar.add_point(pos_to_id(pos), Vector2(pos.x, pos.y))
	
	# Connect neighboring points
	for pos in astar.get_points():
		var grid_pos = id_to_pos(pos)
		for neighbor in get_neighbors(grid_pos):
			var neighbor_id = pos_to_id(neighbor)
			if astar.has_point(neighbor_id):
				astar.connect_points(pos, neighbor_id)
	
	# Find path
	var path = astar.get_point_path(pos_to_id(start), pos_to_id(end))
	return path

# Helper function to convert position to unique ID for AStar
func pos_to_id(pos: Vector2i) -> int:
	return pos.y * 1000 + pos.x

# Helper function to convert ID back to position
func id_to_pos(id: int) -> Vector2i:
	return Vector2i(id % 1000, id / 1000)
