extends Area2D

@onready var orbAudio: AudioStreamPlayer2D = $OrbAudio

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		orbAudio.play()
		GLOBAL.endLevel.emit()
		await orbAudio.finished
		queue_free()
