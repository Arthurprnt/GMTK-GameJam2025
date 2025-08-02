extends Control

@onready var backButton: Button = $MarginContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	backButton.grab_focus()

func _on_back_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/options_menu.tscn", "control")
