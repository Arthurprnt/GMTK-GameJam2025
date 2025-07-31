extends Area2D

@export var defaultState: State = State.Activated
@export var height: float = 32
@export var energySources: Array[StaticBody2D] = []

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox

enum State {
	Activated,
	NotActivated
}
var currentState: State = defaultState

func otherState(state: State) -> State:
	if state == State.Activated:
		return State.NotActivated
	else:
		return State.Activated

func _ready() -> void:
	sprite.scale.y = height/32
	hitbox.shape.size = Vector2(3, height)

func _physics_process(delta: float) -> void:
	if energySources != []:
		var newState: State = otherState(defaultState)
		for es in energySources:
			if es.currentState == es.State.NotPressed:
				newState = defaultState
		currentState = newState
	
	match currentState:
		State.Activated:
			sprite.visible = true
			hitbox.disabled = false
		State.NotActivated:
			sprite.visible = false
			hitbox.disabled = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player || body is Clone:
		body.kill()
