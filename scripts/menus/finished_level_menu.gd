extends CanvasLayer

@onready var levelTime: Label = $MarginContainer/VBoxContainer/LevelTime
@onready var totalTimeLabel: Label = $MarginContainer/VBoxContainer/TotalTimeLabel

@onready var homeButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/HomeButton
@onready var replayButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/ReplayButton
@onready var nextButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/NextButton

func _ready() -> void:
	if is_instance_valid(GLOBAL.clone):
		GLOBAL.clone.queue_free()
	levelTime.text = "Level time:\n" + GLOBAL.msToTimer(GLOBAL.timeInCurrentLevel)
	totalTimeLabel.text = "Total time:\n" + GLOBAL.msToTimer(GLOBAL.totalTimeInLevels)
	if GLOBAL.currentLevel == GLOBAL.nbLevel:
		nextButton.queue_free()
		replayButton.grab_focus()
	else:
		if !((GLOBAL.currentLevel+1) in GLOBAL.levelsUnlocked):
			GLOBAL.levelsUnlocked.append(GLOBAL.currentLevel+1)
		totalTimeLabel.queue_free()
		nextButton.grab_focus()

func _on_home_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/menus/main_menu.tscn", "control")

func _on_replay_button_pressed() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/levels/level_" + str(GLOBAL.currentLevel) + ".tscn", "level")

func _on_next_button_pressed() -> void:
	GLOBAL.timeInCurrentLevel = 0
	GLOBAL.sceneManager.changeScene("res://scenes/levels/level_" + str(GLOBAL.currentLevel+1) + ".tscn", "level")
	GLOBAL.currentLevel += 1
