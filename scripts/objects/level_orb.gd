extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GLOBAL.endLevel.emit()
		queue_free()
