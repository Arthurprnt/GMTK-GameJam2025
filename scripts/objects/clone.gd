extends CharacterBody2D
class_name Clone

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox

@onready var rotator: Marker2D = $Rotator
@onready var raycast: RayCast2D = $Rotator/Raycast
@onready var releasePoint: Node2D = $Rotator/ReleasePoint
@onready var interactZone: Area2D = $Rotator/InteractZone

@onready var coyoteJumpTimer: Timer = $CoyoteJumpTimer
@onready var jumpBufferTimer: Timer = $JumpBufferTimer

@onready var landingParticles: CPUParticles2D = $Particles/LandingParticles
@onready var jumpingParticles: CPUParticles2D = $Particles/JumpingParticles

@onready var landingSound: AudioStreamPlayer2D = $Sounds/LandingSound
@onready var spawningSound: AudioStreamPlayer2D = $Sounds/SpawningSound

#======================================== PLAYER CONSTANTS =========================================

# CONSTANT
const AIR_BRAKE: int = 1440
const JUMP_HEIGHT: int = 250
const MAX_ACCELERATION: int = 1440
const MAX_AIR_ACCELERATION: int = 2700
const MAX_DECELERATION: int = 1368
const MAX_AIR_DECELERATION: int = 1168
const MAX_TURN_SPEED: int = 1880
const MAX_WALKING_SPEED: int = 150
const WALL_JUMP_SPEED: int = 190

#===================================================================================================

#==================================== STATES RELATED VARIABLES =====================================

enum State {
	Idle,
	Fall,
	Walk,
	Jump,
	Killed,
	Sleeping,
}
var currentState: State = State.Idle
var prevState: State = State.Idle

enum Step {
	Spawning,
	Play,
	Dying
}
var currentStep: Step = Step.Spawning

#===================================================================================================

#======================================== GLOBAL VARIABLES =========================================

# ARRAY
var inputsArraySave: Array = []
var inputsArray: Array = []
var objectsInZone: Array = []

# BOOL
var canMoove: bool = true
var desiredJump: bool = false
var holdingCube: bool = false
var inPulsor: bool = false
var wasJumpEmulated: bool = false
var hitFloor: bool = false
var usedJumpBuffer: bool = false
var wasOnFloor: bool = false

# FLOAT
var acceleration: float
var deceleration: float
var firstRecDir: float
var lastNonNullDir: float = 1
var pulsorYCoord: float
var turnSpeed: float

# INT
var selfInd: int
var pulsorCount: int = 0

# VECTOR
var gravity: Vector2 = GLOBAL.defaultGravity
var firstRecPos: Vector2 = Vector2(0, 0)
var lastVelocity: Vector2 = Vector2(0, 0)

# NODE
var holdedCube: CharacterBody2D

#===================================================================================================

func kill() -> void:
	currentStep = Step.Dying

func getAxis(leftAction: String, rightAction: String, actionsArr: Array) -> int:
	var dir: int = 0
	if isActionEmulated(leftAction, actionsArr):
		dir -= 1
	if isActionEmulated(rightAction, actionsArr):
		dir += 1
	return dir

func isActionEmulated(action: String, actionsArr: Array) -> bool:
	return (action in actionsArr)

func init(initPos: Vector2, initDir: int, newArr: Array, ind: int) -> void:
	selfInd = ind
	sprite.texture = load("res://assets/sprites/clone" + str(ind) + ".png")
	if initDir != 0:
		if initDir == 1:
			rotator.rotation_degrees = 0
		else:
			rotator.rotation_degrees = 180
	global_position = initPos
	inputsArraySave = newArr
	inputsArray = inputsArraySave.duplicate()
	firstRecPos = initPos
	firstRecDir = initDir
	await get_tree().create_timer(0.01).timeout
	visible = true
	spawningSound.play()

func doAJump() -> void:
	desiredJump = false
	if (is_on_floor() || coyoteJumpTimer.time_left > 0):
		GLOBAL.playParticles(jumpingParticles)
		velocity.y = -JUMP_HEIGHT * 1.15
		currentState = State.Jump
	# For the jump buffer
	elif !is_on_floor():
		jumpBufferTimer.start()
		usedJumpBuffer = false

func movePlayer(delta: float, maxSpeed: float, actionsArr: Array) -> Vector2:
	var newVelocity: Vector2 = velocity
	
	var horizontalDirection: float = getAxis("move_left", "move_right", actionsArr) if canMoove else 0.0
	var verticalDirection: float = 1 if isActionEmulated("move_down", actionsArr) && canMoove else 0.0
	if sign(horizontalDirection) == -1*sign(gravity.x) && gravity.x != 0:
		horizontalDirection = 0
	var desiredVelocity: Vector2 = Vector2(horizontalDirection * maxSpeed, verticalDirection)
	var maxSpeedChange: float
	
	if is_on_floor():
		acceleration = MAX_ACCELERATION
		deceleration = MAX_DECELERATION
		turnSpeed = MAX_TURN_SPEED
	else:
		acceleration = MAX_AIR_ACCELERATION
		deceleration = MAX_AIR_DECELERATION
		turnSpeed = AIR_BRAKE
	if horizontalDirection && sign(horizontalDirection) != sign(newVelocity.x):
			maxSpeedChange = turnSpeed * delta
	elif abs(newVelocity.x) < abs(desiredVelocity.x):
			maxSpeedChange = acceleration * delta
	else:
		maxSpeedChange = deceleration * delta
	
	newVelocity.x = move_toward(newVelocity.x, desiredVelocity.x, maxSpeedChange)
	
	if inPulsor:
		newVelocity.y += sign(pulsorYCoord - global_position.y) * delta * 5
	if verticalDirection != 0:
		newVelocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta * 2
	
	newVelocity += gravity * delta
	
	return newVelocity

func _ready() -> void:
	GLOBAL.clone = self

func _process(delta: float) -> void:
	match currentStep:
		Step.Play:
			if inputsArray != []:
				var actions: Array = inputsArray.pop_front()
				wasOnFloor = is_on_floor()
				
				var horizontalDirection: float = getAxis("move_left", "move_right", actions)
				
				if horizontalDirection != 0 && canMoove:
					if horizontalDirection == 1:
						rotator.rotation_degrees = 0
					else:
						rotator.rotation_degrees = 180
					lastNonNullDir = horizontalDirection
				lastVelocity = velocity
				
				if isActionEmulated("interact", actions) && objectsInZone.size() > 0:
					# Find the closest object in detection area
					var object: Node2D = objectsInZone[0]
					var distToObject: float = object.global_position.distance_squared_to(global_position)
					for i in range(1, objectsInZone.size()):
						var tempDist: float = objectsInZone[i].global_position.distance_squared_to(global_position)
						if tempDist < distToObject:
							object = objectsInZone[i]
							distToObject = tempDist
					if object is Cube && !holdingCube:
						holdingCube = true
						holdedCube = object
						holdedCube.helder = self
						holdedCube.currentState = holdedCube.State.Held
						holdedCube.hitbox.disabled = true
					elif object is Bouton:
						object.pressedAudio.play()
						object.currentState = object.State.Pressed
						GLOBAL.buttonPressed.emit(object)
						object.pressedTimer.start()
				elif (isActionEmulated("interact", actions) && holdingCube) || !is_instance_valid(holdedCube):
					holdingCube = false
					if is_instance_valid(holdedCube):
						GLOBAL.cubeReleased.emit(interactZone, holdedCube)
						holdedCube.currentState = holdedCube.State.NotHeld
						holdedCube.global_position = releasePoint.global_position
						holdedCube.helder = null
						holdedCube.hitbox.disabled = false
				if isActionEmulated("jump", actions):
					desiredJump = true
				elif !isActionEmulated("jump", actions) && wasJumpEmulated && currentState == State.Jump:
					velocity.y /= 3.5
				
				match currentState:
					State.Idle:
						velocity = Vector2(0, 0)
						
						if desiredJump:
							doAJump()
						elif horizontalDirection != 0 && is_on_floor() && canMoove:
							currentState = State.Walk
						elif !is_on_floor():
							currentState = State.Fall
					State.Fall:
						velocity = movePlayer(delta, MAX_WALKING_SPEED, actions)
						
						if desiredJump:
							doAJump()
						elif is_on_floor():
							if velocity.x != 0:
								currentState = State.Walk
							else:
								currentState = State.Idle
					State.Walk:
						velocity = movePlayer(delta, MAX_WALKING_SPEED, actions)
						if desiredJump:
							doAJump()
						elif !is_on_floor():
							currentState = State.Fall
						elif velocity.x == 0:
							currentState = State.Idle
					State.Jump:
						velocity = movePlayer(delta, MAX_WALKING_SPEED, actions)
						
						if velocity.y > 0:
							currentState = State.Fall
						
				move_and_slide()
		
				if wasOnFloor && !is_on_floor() && velocity.y >= 0:
					coyoteJumpTimer.start()
				if (!wasOnFloor && is_on_floor()):
					GLOBAL.playParticles(landingParticles)
					landingSound.play()
					if jumpBufferTimer.time_left > 0 && !usedJumpBuffer:
						doAJump()
						usedJumpBuffer = true
				wasJumpEmulated = isActionEmulated("jump", actions)
			else:
				await get_tree().create_timer(0.2).timeout
				kill()
		Step.Spawning:
			wasOnFloor = is_on_floor()
			movePlayer(delta, 0, [])
			move_and_slide()
			
			modulate = Color(1, 1, 1, lerpf(modulate.a, 1, 0.25))
			if modulate.a >= 0.99:
				await get_tree().create_timer(0.2).timeout
				currentStep = Step.Play
		Step.Dying:
			hitbox.disabled = true
			modulate = Color(1, 1, 1, lerpf(modulate.a, 0, 0.25))
			if modulate.a <= 0.01:
				GLOBAL.createClone(firstRecPos, firstRecDir, inputsArraySave, selfInd)
				queue_free()

func _on_death_zone_body_entered(body: Node2D) -> void:
	if body is Cube || body is ActivableDoor:
		kill()

func _on_interact_zone_body_entered(body: Node2D) -> void:
	if body is Cube || body is Bouton:
		objectsInZone.append(body)

func _on_interact_zone_body_exited(body: Node2D) -> void:
	if body is Cube || body is Bouton:
		objectsInZone.pop_at(objectsInZone.find(body))
