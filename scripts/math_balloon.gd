extends Node2D

@onready var label: Label = $Panel/Label
@onready var panel: Panel = $Panel

func set_question(text):
	panel.position = Vector2(0, 15)
	label.text = text
