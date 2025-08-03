extends StaticBody2D
class_name Pulsor

@export var defaultState: State = State.Activated
@export var defaultDir: int = 1
@export var energySources: Array[StaticBody2D] = []
@export var reversingSources: Array[StaticBody2D] = []

@onready var raycast: RayCast2D = $Raycast
@onready var particles: CPUParticles2D = $Particles
@onready var areaHitbox: CollisionShape2D = $Area2D/Hitbox

@onready var blueGrad: Gradient = preload("res://themes/pulsor_gradient_blue.tres")
@onready var orangeGrad: Gradient = preload("res://themes/pulsor_gradient_orange.tres")

var bodiesInPulsor: Array = []
var pulsorCoeff: int = 1
var rotations: Dictionary = {
	"0": Vector2(0, -1),
	"-90": Vector2(-2.5, 0),
	"-180": Vector2(0, 1),
	"-270": Vector2(2.5, 0),
	"90": Vector2(2.5, 0),
	"180": Vector2(0, 1),
	"270": Vector2(-2.5, 0)
}

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
	currentState = defaultState
	pulsorCoeff = defaultDir

func _process(_delta: float) -> void:
	if !raycast.is_colliding():
		raycast.target_position.y -= 4.5
		particles.emission_rect_extents = Vector2(18, raycast.target_position.y/2)
		particles.position = Vector2(0, (raycast.target_position.y/2)-8)
		particles.amount = int(abs(raycast.target_position.y) * 1.5)
		areaHitbox.shape.size = Vector2(32, abs(raycast.target_position.y))
		areaHitbox.position = Vector2(0, (raycast.target_position.y/2)-8)

func _physics_process(_delta: float) -> void:
	if energySources != []:
		var newState: State = otherState(defaultState)
		for es in energySources:
			if es.currentState == es.State.NotPressed:
				newState = defaultState
		currentState = newState
	
	if reversingSources != []:
		var newDir: int = defaultDir * -1
		for es in reversingSources:
			if es.currentState == es.State.NotPressed:
				newDir = defaultDir
		if newDir != pulsorCoeff:
			for body in bodiesInPulsor:
				body.gravity = rotations[str(roundi(rotation_degrees))] * newDir * abs(ProjectSettings.get_setting("physics/2d/default_gravity"))/2
			pulsorCoeff = newDir
	
	match currentState:
		State.Activated:
			particles.emitting = true
			areaHitbox.disabled = false
		State.NotActivated:
			particles.emitting = false
			areaHitbox.disabled = true
	
	assert(pulsorCoeff in [1, -1])
	if pulsorCoeff == 1:
		particles.color_ramp = blueGrad
	else:
		particles.color_ramp = orangeGrad

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player || body is Clone || body is Cube:
		bodiesInPulsor.append(body)
		body.pulsorCount += 1
		body.pulsorYCoord = global_position.y
		if rotations[str(roundi(rotation_degrees))].y == 0:
			body.velocity.y = 0
		if !body.inPulsor:
			body.gravity = rotations[str(roundi(rotation_degrees))] * pulsorCoeff * abs(ProjectSettings.get_setting("physics/2d/default_gravity"))/2
		else:
			body.gravity += rotations[str(roundi(rotation_degrees))] * pulsorCoeff * abs(ProjectSettings.get_setting("physics/2d/default_gravity"))/2
		body.inPulsor = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player || body is Clone || body is Cube:
		bodiesInPulsor.pop_at(bodiesInPulsor.find(body))
		body.pulsorCount -= 1
		if body.pulsorCount <= 0:
			body.inPulsor = false
			body.gravity = GLOBAL.defaultGravity
		else:
			body.gravity -= rotations[str(roundi(rotation_degrees))] * pulsorCoeff * abs(ProjectSettings.get_setting("physics/2d/default_gravity"))/2
