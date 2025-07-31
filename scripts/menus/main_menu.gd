extends Control

@onready var playButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/PlayButton
@onready var blackFade: ColorRect = $BlackFade

var exit: bool = false
var exitValue: float = 1.8

func _ready() -> void:
	playButton.grab_focus()

func _on_play_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/level_menu.tscn", "control")

func _on_button_pressed() -> void:
	exit = true

func _physics_process(delta: float) -> void:
	if exit:
		blackFade.modulate = Color(255, 255, 255, move_toward(blackFade.modulate.a, exitValue, 5*delta))
		if blackFade.modulate.a >= exitValue-0.01:
			get_tree().quit()
