extends CanvasLayer

@onready var closeButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/CloseButton

func changeToMenu(path: String) -> void:
	GLOBAL.sceneManager.changeScene(path, "menu")
	queue_free()

func closeMenu() -> void:
	changeToMenu("res://scenes/menus/pause_menu.tscn")

func _ready() -> void:
	closeButton.grab_focus()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		closeMenu()

func _on_close_button_pressed() -> void:
	closeMenu()
