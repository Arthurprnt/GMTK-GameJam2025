extends StaticBody2D
class_name ActivableDoor

@export var activatedPos: Vector2 = Vector2(0, 0)
@export var activationSpeed: float = 180
@export var energySources: Array[StaticBody2D] = []

@onready var openningAudio: AudioStreamPlayer2D = $OpenningAudio
@onready var closingAudio: AudioStreamPlayer2D = $ClosingAudio

var notActivatedPos: Vector2
var playedSound: bool = true

enum State {
	Activated,
	NotActivated
}
var currentState: State = State.NotActivated

func _ready() -> void:
	notActivatedPos = global_position

func _physics_process(delta: float) -> void:
	var newState: State = State.Activated
	for es in energySources:
		if es.currentState == es.State.NotPressed:
			newState = State.NotActivated
	if currentState != newState:
		playedSound = false
	currentState = newState
	
	match currentState:
		State.NotActivated:
			if !playedSound:
				playedSound = true
				closingAudio.play()
			global_position.x = move_toward(global_position.x, notActivatedPos.x, delta * activationSpeed)
			global_position.y = move_toward(global_position.y, notActivatedPos.y, delta * activationSpeed)
		State.Activated:
			if !playedSound:
				playedSound = true
				openningAudio.play()
			global_position.x = move_toward(global_position.x, activatedPos.x, delta * activationSpeed)
			global_position.y = move_toward(global_position.y, activatedPos.y, delta * activationSpeed)
