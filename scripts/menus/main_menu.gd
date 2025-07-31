extends Control

@onready var playButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/PlayButton

func _ready() -> void:
	playButton.grab_focus()

func _on_play_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/level_menu.tscn", "control")
