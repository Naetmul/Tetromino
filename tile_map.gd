extends TileMap

# Tetrominoes
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

var shapes_all := [i, t, o, z, s, l, j]
var shapes := []

# Grid variables
const COLS: int = 10
const ROWS: int = 20

# Movement variables
const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const LEFT_IDX = 0
const RIGHT_IDX = 1
const DOWN_IDX = 2

var steps: Array
const STEPS_REQ: int = 50
const START_POS := Vector2i(5, 1)
var cur_pos: Vector2i
var speed: float
const ACCEL: float = 0.25

# Game piece variables
var piece_type
var next_piece_type
var rotation_index: int = 0
var active_piece: Array

# Game variables
var score: int
const REWARD: int = 100
var is_game_running: bool

# TileMap variables
var tile_set_id: int = 0
var piece_atlas: Vector2i
var next_piece_atlas: Vector2i

# Layer variables
var board_layer: int = 0
var active_layer: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	$HUD.get_node("StartButton").pressed.connect(new_game)

func new_game() -> void:
	# Reset variables
	score = 0
	speed = 1.0
	steps = [0, 0, 0]
	is_game_running = true

	$HUD.get_node("GameOverLabel").hide()
	# Clear everything
	clear_piece()
	clear_board()
	clear_panel()

	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)

	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_all.find(piece_type), 0)
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_all.find(next_piece_type), 0)
	create_piece()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_game_running:
		if Input.is_action_pressed("ui_left"):
			steps[LEFT_IDX] += 10
		elif Input.is_action_pressed("ui_right"):
			steps[RIGHT_IDX] += 10
		elif Input.is_action_pressed("ui_down"):
			steps[DOWN_IDX] += 10
		elif Input.is_action_just_pressed("ui_up"):
			rotate_piece()

		# Apply downward movement every frame
		steps[DOWN_IDX] += speed
		for i_dir in range(DIRECTIONS.size()):
			if steps[i_dir] > STEPS_REQ:
				move_piece(DIRECTIONS[i_dir])
				steps[i_dir] = 0


func pick_piece() -> Array:
	if shapes.is_empty():
		shapes = shapes_all.duplicate()
		shapes.shuffle()
	return shapes.pop_front()

func create_piece() -> void:
	# Reset variables
	steps = [0, 0, 0]
	cur_pos = START_POS
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas)

	# Show next piece
	draw_piece(next_piece_type[0], Vector2i(15, 6), next_piece_atlas)

func clear_piece() -> void:
	for point in active_piece:
		erase_cell(active_layer, cur_pos + point)

func draw_piece(piece, coords, atlas) -> void:
	for point in piece:
		set_cell(active_layer, coords + point, tile_set_id, atlas)

func rotate_piece() -> void:
	if can_rotate():
		clear_piece()
		rotation_index = (rotation_index + 1) % 4
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, cur_pos, piece_atlas)

func move_piece(direction: Vector2i) -> void:
	if can_move(direction):
		clear_piece()
		cur_pos += direction
		draw_piece(active_piece, cur_pos, piece_atlas)
	else:
		if direction == Vector2i.DOWN:
			land_piece()
			check_rows()
			piece_type = next_piece_type
			piece_atlas = next_piece_atlas
			next_piece_type = pick_piece()
			next_piece_atlas = Vector2i(shapes_all.find(next_piece_type), 0)
			clear_panel()
			create_piece()
			check_game_over()

# Check if there is space to move
func can_move(direction: Vector2i) -> bool:
	var can = true
	for point in active_piece:
		if not is_free(cur_pos + point + direction):
			can = false
			break
	return can

func can_rotate() -> bool:
	var can = true
	var new_rotation_index = (rotation_index + 1) % 4
	for point in piece_type[new_rotation_index]:
		if not is_free(cur_pos + point):
			can = false
			break
	return can

func is_free(coords) -> bool:
	return get_cell_source_id(board_layer, coords) == -1

func land_piece() -> void:
	# Remove each segment from the active layer and move to the board layer
	for point in active_piece:
		erase_cell(active_layer, cur_pos + point)
		set_cell(board_layer, cur_pos + point, tile_set_id, piece_atlas)

func clear_panel() -> void:
	for x in range(14, 19):
		for y in range(5, 9):
			erase_cell(active_layer, Vector2i(x, y))


func check_rows() -> void:
	var row: int = ROWS
	while row > 0:
		var count = 0
		for col in range(COLS):
			if not is_free(Vector2i(col + 1, row)):
				count += 1
		# If row is full then erase it
		if count == COLS:
			shift_rows(row)
			score += REWARD
			$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
			speed += ACCEL
		else:
			row -= 1


func shift_rows(row: int) -> void:
	var atlas: Vector2i
	for y in range(row, 1, -1):
		for x in range(COLS):
			atlas = get_cell_atlas_coords(board_layer, Vector2i(x + 1, y - 1))
			if atlas == Vector2i(-1, -1):
				erase_cell(board_layer, Vector2i(x + 1, y))
			else:
				set_cell(board_layer, Vector2i(x + 1, y), tile_set_id, atlas)

func clear_board() -> void:
	for y in range(ROWS):
		for x in range(COLS):
			erase_cell(board_layer, Vector2i(x + 1, y + 1))


func check_game_over() -> void:
	for point in active_piece:
		if not is_free(cur_pos + point):
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			is_game_running = false
			break