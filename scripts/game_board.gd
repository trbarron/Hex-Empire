class_name GameBoard
extends TileMap


# Offset coordinates for hexagonal grid neighbors
const HEX_DIRECTIONS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

const HIGHLIGHT_LAYER = 1  # Use a separate layer for highlights
const HIGHLIGHT_SOURCE_ID = 4  # Assume we're using the first tile source
const HIGHLIGHT_ATLAS_COORDS = Vector2i(0, 0)  # Adjust based on your tileset
const HIGHLIGHT_ALTERNATIVE_TILE = 2  # The alternative tile id for highlight

# Dictionary to store game pieces on the board
var pieces = {}

# Custom colors for highlighting
var highlight_color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
var valid_move_color = Color(0, 1, 0, 0.3)  # Green, semi-transparent


var cell_size: Vector2i

func _ready():
	# Set up the highlight layer
	set_layer_modulate(HIGHLIGHT_LAYER, Color(1, 1, 1, 1))  # Start with full opacity
	set_layer_z_index(HIGHLIGHT_LAYER, 1)  # Ensure it's above the main layer

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

func highlight_cell(grid_pos: Vector2i, color: Color = highlight_color):
	set_cell(HIGHLIGHT_LAYER, grid_pos, HIGHLIGHT_SOURCE_ID, HIGHLIGHT_ATLAS_COORDS, HIGHLIGHT_ALTERNATIVE_TILE)
	# We'll use the layer's modulate to control the highlight color
	set_layer_modulate(HIGHLIGHT_LAYER, color)

func unhighlight_cell(grid_pos: Vector2i):
	erase_cell(HIGHLIGHT_LAYER, grid_pos)

func clear_highlights():
	clear_layer(HIGHLIGHT_LAYER)

func highlight_valid_moves(card):
	clear_highlights()
	for y in range(get_used_rect().position.y, get_used_rect().end.y):
		for x in range(get_used_rect().position.x, get_used_rect().end.x):
			var grid_pos = Vector2i(x, y)
			if can_play_card(card, grid_pos):
				highlight_card_shape(card, grid_pos)

func highlight_card_shape(card, origin: Vector2i):
	for shape_pos in card.shape:
		var highlight_pos = origin + shape_pos
		if is_valid_grid_pos(highlight_pos):
			highlight_cell(highlight_pos, valid_move_color)

func can_play_card(card, origin: Vector2i) -> bool:
	for shape_pos in card.shape:
		var check_pos = origin + shape_pos
		if not is_valid_grid_pos(check_pos) or check_pos in pieces:
			return false
	return true

func play_card(card, origin: Vector2i) -> bool:
	if can_play_card(card, origin):
		for shape_pos in card.shape:
			var place_pos = origin + shape_pos
			place_piece(card, place_pos)
		return true
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
