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

func _ready() -> void:
	sprite.scale.y = height/32
	var tempHixbox = hitbox.shape.duplicate()
	tempHixbox.size = Vector2(3, height)
	hitbox.shape = tempHixbox
	particles.emission_rect_extents = Vector2(6, height/2)
	particles.amount = int(height * 0.35)

func _draw() -> void:
	if Input.is_action_pressed("tab"):
		for es in energySources:
			draw_line(to_local(global_position), to_local(es.global_position), GLOBAL.linesColor, 1, false)

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
	if body is Cube:
		body.queue_free()
	elif body is CharacterBody2D:
		if body.holdingCube:
			# HORRIBLE CODE INCOMING DONT MIND
			#======================================================================
			var cubeStartingX: float = body.holdedCube.global_position.x - 8
			var cubeEndingX: float = body.holdedCube.global_position.x + 8
			var fieldStartingX: float = global_position.x - 1.5
			var fieldEndingX: float = global_position.x + 1.5
			
			var cubeStartingY: float = body.holdedCube.global_position.y - 8
			var cubeEndingY: float = body.holdedCube.global_position.y + 8
			var fieldStartingY: float = global_position.y - (height/2)
			var fieldEndingY: float = global_position.y + (height/2)
			
			if rotation_degrees != 0:
				var temp: float = fieldStartingX
				fieldStartingX = fieldStartingY
				fieldStartingY = temp
				temp = fieldEndingX
				fieldEndingX = fieldEndingY
				fieldEndingY = temp
			
			if (cubeStartingX < fieldStartingX && fieldStartingX < cubeEndingX) ||\
			   (cubeStartingY < fieldStartingY && fieldStartingY < cubeEndingY):
				body.holdedCube.queue_free()
			#======================================================================
