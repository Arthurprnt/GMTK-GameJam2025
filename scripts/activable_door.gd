extends StaticBody2D

@export var activatedPos: Vector2 = Vector2(0, 0)
@export var activationSpeed: float = 40
@export var energySources: Array[StaticBody2D] = []

var notActivatedPos: Vector2

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
	currentState = newState
	
	match currentState:
		State.NotActivated:
			global_position.x = move_toward(global_position.x, notActivatedPos.x, delta * activationSpeed)
			global_position.y = move_toward(global_position.y, notActivatedPos.y, delta * activationSpeed)
		State.Activated:
			global_position.x = move_toward(global_position.x, activatedPos.x, delta * activationSpeed)
			global_position.y = move_toward(global_position.y, activatedPos.y, delta * activationSpeed)
