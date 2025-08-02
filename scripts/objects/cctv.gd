extends Node2D

@onready var visibleNotifier: VisibleOnScreenNotifier2D = $VisibleNotifier

func _on_visible_notifier_screen_entered() -> void:
	if !(GLOBAL.currentLevel in GLOBAL.cctvSeen):
		GLOBAL.cctvSeen.append(GLOBAL.currentLevel)
		if GLOBAL.cctvSeen.size() == GLOBAL.cctvNb:
			GLOBAL.sceneManager.ost.stop()
			GLOBAL.sceneManager.changeScene("res://scenes/levels/level_-3.tscn", "level")
			GLOBAL.currentLevel = -3
			GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)
