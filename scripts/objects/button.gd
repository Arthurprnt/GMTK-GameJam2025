extends StaticBody2D
class_name Bouton

@export var activeTime: float = 1
@onready var pressedAudio: AudioStreamPlayer2D = $PressedAudio

@onready var pressedTimer: Timer = $PressedTimer

enum State {
	Pressed,
	NotPressed
}
var currentState: State = State.NotPressed

func _ready() -> void:
	pressedTimer.wait_time = activeTime

func _on_pressed_timer_timeout() -> void:
	currentState = State.NotPressed
