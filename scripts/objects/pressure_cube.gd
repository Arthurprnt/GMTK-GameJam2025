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
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") # Get gravity from project settings (synced with RigidBody nodes)

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
			velocity.y += gravity * delta
	
	move_and_slide()
	
	if !wasOnFloor && is_on_floor():
		GLOBAL.playParticles(landingParticles)
		landingSoud.play()
