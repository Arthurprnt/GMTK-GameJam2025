extends Control

@onready var closeButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/CloseButton

func _ready() -> void:
	closeButton.grab_focus()

func _on_close_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/main_menu.tscn", "control")
