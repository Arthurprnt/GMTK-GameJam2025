extends Control

@onready var backButton: Button = $MarginContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	backButton.grab_focus()

func _on_back_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/main_menu.tscn", "control")

func _on_controls_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/controls_menu.tscn", "control")

func _on_audio_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/audio_menu.tscn", "control")
