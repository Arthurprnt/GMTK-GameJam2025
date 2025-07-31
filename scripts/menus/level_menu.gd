extends Control

@onready var gridContainer: GridContainer = $MarginContainer/GridContainer

var focusedGrab: bool = false

func _ready() -> void:
	for lvl in range(1, GLOBAL.nbLevel+1):
		var newButton: Button = Button.new()
		newButton.text = str(lvl)
		newButton.custom_minimum_size = Vector2(50, 50)
		newButton.pressed.connect(func(): GLOBAL.currentLevel = lvl; GLOBAL.timeInCurrentLevel = 0; GLOBAL.sceneManager.changeScene("res://scenes/levels/level_" + str(lvl) +".tscn", "level"))
		gridContainer.add_child(newButton)
		if !focusedGrab:
			focusedGrab = true
			newButton.grab_focus()
