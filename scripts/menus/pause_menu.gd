extends CanvasLayer

@onready var resumeButton: Button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ResumeButton

var releasedButton: bool = false

func closeMenu() -> void:
	visible = false
	releasedButton = false
	get_tree().paused = false

func _ready() -> void:
	resumeButton.grab_focus()
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("menu"):
		resumeButton.grab_focus()
		releasedButton = true
	elif Input.is_action_pressed("menu") && releasedButton:
		closeMenu()

func _on_resume_button_pressed() -> void:
	closeMenu()

func _on_restart_button_pressed() -> void:
	closeMenu()
	GLOBAL.player.kill()

func _on_help_button_pressed() -> void:
	queue_free()
	GLOBAL.sceneManager.changeScene("res://scenes/menus/help_menu.tscn", "menu")

func _on_options_button_pressed() -> void:
	queue_free()
	GLOBAL.sceneManager.changeScene("res://scenes/menus/option_echap_menu.tscn", "menu")

func _on_quit_button_pressed() -> void:
	closeMenu()
	GLOBAL.sceneManager.changeScene("res://scenes/menus/main_menu.tscn", "control")
