extends CanvasLayer

@onready var backButton: Button = $MarginContainer/MarginContainer/VBoxContainer/BackButton
@onready var controlsButton: Button = $MarginContainer/MarginContainer/VBoxContainer/ControlsButton
@onready var audioButton: Button = $MarginContainer/MarginContainer/VBoxContainer/AudioButton


func changeToMenu(path: String) -> void:
	GLOBAL.sceneManager.changeScene(path, "menu")
	queue_free()

func closeMenu() -> void:
	changeToMenu("res://scenes/menus/pause_menu.tscn")

func _ready() -> void:
	backButton.grab_focus()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		closeMenu()

func _on_back_button_pressed() -> void:
	closeMenu()

func _on_controls_button_pressed() -> void:
	changeToMenu("res://scenes/menus/controls_echap_menu.tscn")

func _on_audio_button_pressed() -> void:
	changeToMenu("res://scenes/menus/audio_echap_menu.tscn")
