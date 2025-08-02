extends CanvasLayer

@onready var backButton: Button = $MarginContainer/MarginContainer/VBoxContainer/BackButton

func changeToMenu(path: String) -> void:
	GLOBAL.sceneManager.changeScene(path, "menu")
	queue_free()

func closeMenu() -> void:
	changeToMenu("res://scenes/menus/option_echap_menu.tscn")

func _ready() -> void:
	backButton.grab_focus()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		closeMenu()

func _on_back_button_pressed() -> void:
	closeMenu()
