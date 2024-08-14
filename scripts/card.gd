# Card.gd
extends Node2D

@onready var name_label = $NameLabel
@onready var cost_label = $CostLabel
@onready var effect_label = $EffectLabel

var card_name: String
var cost: int
var effect: String
var shape: Array = []  # Array of Vector2i representing the card's shape

var dragging = false
var start_position = Vector2.ZERO

func _ready():
	update_display()
	
	var area = $Area2D
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	area.input_pickable = true

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				start_position = global_position
				z_index = 2
			else:
				dragging = false
				z_index = 0
				if not get_parent().get_global_rect().has_point(get_global_mouse_position()):
					global_position = start_position
				else:
					get_parent().get_parent().try_play_card(self)

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()

func update_display():
	if name_label: name_label.text = card_name
	if cost_label: cost_label.text = str(cost)
	if effect_label: effect_label.text = effect

func setup(new_name: String, new_cost: int, new_effect: String, new_shape: Array):
	card_name = new_name
	cost = new_cost
	effect = new_effect
	shape = new_shape
	update_display()

func _on_mouse_entered():
	scale = Vector2(0.6, 0.6)
	z_index = 1

func _on_mouse_exited():
	if not dragging:
		scale = Vector2(0.5, 0.5)
		z_index = 0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if get_global_rect().has_point(get_global_mouse_position()):
					dragging = true
					start_position = position
					z_index = 2
			else:
				dragging = false
				z_index = 0
				if not get_parent().get_global_rect().has_point(get_global_mouse_position()):
					position = start_position
				else:
					get_parent().get_parent().get_parent().try_play_card(self)

	if dragging and event is InputEventMouseMotion:
		position += event.relative

func get_global_rect():
	var size = Vector2(100, 150)  # Adjust based on your card size
	return Rect2(global_position - size/2, size)
