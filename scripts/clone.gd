extends CharacterBody2D

@onready var rotator: Marker2D = $Rotator
@onready var raycast: RayCast2D = $Rotator/Raycast
@onready var releasePoint: Node2D = $Rotator/ReleasePoint

@onready var coyoteJumpTimer: Timer = $CoyoteJumpTimer
@onready var jumpBufferTimer: Timer = $JumpBufferTimer

#======================================== PLAYER CONSTANTS =========================================

# CONSTANT
const AIR_BRAKE: int = 1440
const JUMP_HEIGHT: int = 308
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

#===================================================================================================

#======================================== GLOBAL VARIABLES =========================================

# ARRAY
var inputsArray: Array = []

# BOOL
var canMoove: bool = true
var canStart: bool = false
var desiredJump: bool = false
var holdingCube: bool = false
var wasJumpEmulated: bool = false
var hitFloor: bool = false
var usedJumpBuffer: bool = false

# FLOAT
var acceleration: float
var deceleration: float
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") # Get gravity from project settings (synced with RigidBody nodes)
var turnSpeed: float

# INT
var lastNonNullDir: float = 1

# VECTOR
var firstRecPos: Vector2 = Vector2(0, 0)
var lastVelocity: Vector2 = Vector2(0, 0)

# NODE
var holdedCube: CharacterBody2D

#===================================================================================================

func getAxis(leftAction: String, rightAction: String, actionsArr: Array) -> int:
	var dir: int = 0
	if isActionEmulated(leftAction, actionsArr):
		dir -= 1
	if isActionEmulated(rightAction, actionsArr):
		dir += 1
	return dir

func isActionEmulated(action: String, actionsArr: Array) -> bool:
	return (action in actionsArr)

func init(initPos: Vector2, initDir: int, newArr: Array) -> void:
	if initDir != 0:
		if initDir == 1:
			rotator.rotation_degrees = 0
		else:
			rotator.rotation_degrees = 180
	global_position = initPos
	inputsArray = newArr
	await get_tree().create_timer(0.01).timeout
	visible = true
	canStart = true

func doAJump() -> void:
	desiredJump = false
	if (is_on_floor() || coyoteJumpTimer.time_left > 0):
		velocity.y = -JUMP_HEIGHT * 1.15
		currentState = State.Jump
	# For the jump buffer
	elif !is_on_floor():
		jumpBufferTimer.start()
		usedJumpBuffer = false

func movePlayer(delta: float, maxSpeed: float, actionsArr: Array) -> Vector2:
	var newVelocity: Vector2 = velocity
	
	var direction: float = getAxis("move_left", "move_right", actionsArr)
	var desiredVelocity: float = direction * maxSpeed
	var maxSpeedChange: float
	
	if is_on_floor():
		acceleration = MAX_ACCELERATION
		deceleration = MAX_DECELERATION
		turnSpeed = MAX_TURN_SPEED
	else:
		acceleration = MAX_AIR_ACCELERATION
		deceleration = MAX_AIR_DECELERATION
		turnSpeed = AIR_BRAKE
		newVelocity.y += gravity * delta
	if direction && sign(direction) != sign(newVelocity.x):
			maxSpeedChange = turnSpeed * delta
	elif abs(newVelocity.x) < abs(desiredVelocity):
			maxSpeedChange = acceleration * delta
	else:
		maxSpeedChange = deceleration * delta
	
	newVelocity.x = move_toward(newVelocity.x, desiredVelocity, maxSpeedChange)
	return newVelocity

func _physics_process(delta: float) -> void:
	
	if canStart:
		if inputsArray != []:
			var actions: Array = inputsArray.pop_front()
			var wasOnFloor: bool = is_on_floor()
			
			var horizontalDirection: float = getAxis("move_left", "move_right", actions)
			
			if horizontalDirection != 0 && canMoove:
				if horizontalDirection == 1:
					rotator.rotation_degrees = 0
				else:
					rotator.rotation_degrees = 180
				lastNonNullDir = horizontalDirection
			lastVelocity = velocity
			
			if isActionEmulated("interact", actions) && raycast.is_colliding():
				var object: Node2D = raycast.get_collider()
				if object is Cube && !holdingCube:
					holdingCube = true
					holdedCube = object
					holdedCube.helder = self
					holdedCube.currentState = holdedCube.State.Held
				elif object is Bouton:
					object.currentState = object.State.Pressed
					object.pressedTimer.start()
			elif (isActionEmulated("interact", actions) && holdingCube) || !is_instance_valid(holdedCube):
				holdingCube = false
				if is_instance_valid(holdedCube):
					holdedCube.currentState = holdedCube.State.NotHeld
					holdedCube.global_position = releasePoint.global_position
					holdedCube.helder = null
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
				if jumpBufferTimer.time_left > 0 && !usedJumpBuffer:
					doAJump()
					usedJumpBuffer = true
			wasJumpEmulated = isActionEmulated("jump", actions)
		else:
			queue_free()

func _on_death_zone_body_entered(body: Node2D) -> void:
	if body is Cube:
		queue_free()
