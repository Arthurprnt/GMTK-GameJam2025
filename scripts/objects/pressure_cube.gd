extends CharacterBody2D
class_name Cube

@onready var hitbox: CollisionShape2D = $Hitbox

@onready var landingParticles: CPUParticles2D = $LandingParticles
@onready var landingSoud: AudioStreamPlayer2D = $LandingSoud

enum State {
	Held,
	NotHeld
}
var currentState: State = State.NotHeld

var helder: CharacterBody2D = null
var inPulsor: bool = false
var gravity: Vector2 = GLOBAL.defaultGravity
var pulsorYCoord: float
var pulsorCount: int = 0

func _physics_process(delta: float) -> void:
	if !is_instance_valid(helder):
		hitbox.disabled = false
		currentState = State.NotHeld
	
	var wasOnFloor: bool = is_on_floor()
	
	match currentState:
		State.Held:
			velocity = Vector2(0, 0)
			global_position = Vector2(helder.global_position.x, helder.global_position.y - 18)
		State.NotHeld:
			velocity.x = gravity.x * 1.5 * delta
			if inPulsor:
				velocity.y += sign(pulsorYCoord - global_position.y) * delta * 5
			velocity.y += gravity.y * delta
	
	move_and_slide()
	
	if !wasOnFloor && is_on_floor():
		GLOBAL.playParticles(landingParticles)
		landingSoud.play()
