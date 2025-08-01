extends Area2D

@export var defaultState: State = State.Activated
@export var height: float = 32
@export var energySources: Array[StaticBody2D] = []

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var particles: CPUParticles2D = $Particles

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

func _draw() -> void:
	if Input.is_action_pressed("tab"):
		for es in energySources:
			draw_line(to_local(global_position), to_local(es.global_position), GLOBAL.linesColor, 1, false)

func _ready() -> void:
	sprite.scale.y = height/32
	hitbox.shape.size = Vector2(3, height)
	particles.emission_rect_extents = Vector2(6, height/2)
	particles.amount = int(height * 0.35)

func _physics_process(_delta: float) -> void:
	queue_redraw()
	if energySources != []:
		var newState: State = otherState(defaultState)
		for es in energySources:
			if es.currentState == es.State.NotPressed:
				newState = defaultState
		currentState = newState
	
	match currentState:
		State.Activated:
			particles.emitting = true
			sprite.visible = true
			hitbox.disabled = false
		State.NotActivated:
			particles.emitting = false
			sprite.visible = false
			hitbox.disabled = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player || body is Clone:
		body.kill()
