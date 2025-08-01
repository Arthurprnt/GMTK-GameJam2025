extends Node2D

@onready var sadAudio: AudioStreamPlayer2D = $SadAudio

func _ready() -> void:
	sadAudio.finished.connect(func(): sadAudio.play())
	sadAudio.play()
