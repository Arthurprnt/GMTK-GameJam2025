extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var closeButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var instructionsLabel: Label = $MarginContainer/VBoxContainer/InstructionsLabel

func changeToMenu(path: String) -> void:
	GLOBAL.sceneManager.changeScene(path, "menu")
	queue_free()

func closeMenu() -> void:
	changeToMenu("res://scenes/menus/pause_menu.tscn")

func _ready() -> void:
	closeButton.grab_focus()
	if GLOBAL.currentLevel == -2:
		instructionsLabel.text = "Who is she ?"
	elif GLOBAL.currentLevel == -1:
		instructionsLabel.text = "What the fu-"
	elif GLOBAL.currentLevel == 0:
		instructionsLabel.text = "Something's off..."
	elif GLOBAL.currentLevel == 1:
		instructionsLabel.text = "Press O to record your actions.\nPress P to summon your recorded clone."
	elif GLOBAL.currentLevel == 2:
		instructionsLabel.text = "Plates can power devices.\nYou can press TAB to check the links between objects."
	elif GLOBAL.currentLevel <= 4:
		instructionsLabel.text = "Buttons can also power devices.\nYou can interact with it by pressing E while facing it.\nYou can hold a cube by pressing E while facing it.\nPress E again to place it on the floor.\nCubes can activate plates."
	elif GLOBAL.currentLevel == 5:
		instructionsLabel.text = "Force fields will destroy cubes touching it.\nYour clones will also make the interactions you made."
	elif GLOBAL.currentLevel == 6:
		instructionsLabel.text = "Kill fields will kill you or your clones when touching it."
	elif GLOBAL.currentLevel == 7:
		instructionsLabel.text = "Pulsors change the gravity applied to object in it."
	elif GLOBAL.currentLevel <= 9:
		instructionsLabel.text = "Pulsors change the gravity based on its color.\nIf it's blue it will push.\nIf it's orange it will pull."
	else:
		instructionsLabel.text = "You already know everything about this game.\nTrust yourself."

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		closeMenu()

func _on_close_button_pressed() -> void:
	closeMenu()
