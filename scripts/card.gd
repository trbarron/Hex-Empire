# Card.gd
extends Node2D

var card_name: String
var cost: int
var effect: String

func _ready():
	update_display()

func update_display():
	$NameLabel.text = card_name
	$CostLabel.text = str(cost)
	$EffectLabel.text = effect

func _on_Card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_parent().card_selected(self)
