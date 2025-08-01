extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GLOBAL.sceneManager.changeScene("res://scenes/levels/level_-2.tscn", "level")
		GLOBAL.currentLevel = -2
		GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)
