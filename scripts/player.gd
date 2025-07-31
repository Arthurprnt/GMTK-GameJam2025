extends CharacterBody2D

#========================================== IMPORTED NODES =========================================

@onready var camera: Camera2D = $Camera
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var sprite: Sprite2D = $Sprite

@onready var coyoteJumpTimer: Timer = $CoyoteJumpTimer
@onready var jumpBufferTimer: Timer = $JumpBufferTimer

@onready var cloneScene: PackedScene = preload("res://scenes/clone.tscn")

#===================================================================================================

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
var inputsArr: Array = []

# BOOL
var canMoove: bool = true
var desiredJump: bool = false
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

#===================================================================================================

#========================================= CUSTOM FUNCTIONS ========================================

# UTILITY

func createClone() -> void:
	var clone: CharacterBody2D = cloneScene.instantiate()
	get_tree().current_scene.add_child(clone)
	clone.init(firstRecPos, inputsArr.duplicate())

# MOUVEMENTS RELATED

func doAJump() -> void:
	desiredJump = false
	if (is_on_floor() || coyoteJumpTimer.time_left > 0):
		velocity.y = -JUMP_HEIGHT * 1.15
		currentState = State.Jump
	# For the jump buffer
	elif !is_on_floor():
		jumpBufferTimer.start()
		usedJumpBuffer = false

func movePlayer(delta: float, maxSpeed: float) -> Vector2:
	var newVelocity: Vector2 = velocity
	
	var direction: float = Input.get_axis("move_left", "move_right") if canMoove else 0.0
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

#===================================================================================================

#========================================= GODOT FUNCTIONS =========================================

func _process(delta: float) -> void:
	var horizontalDirection: float = Input.get_axis("move_left", "move_right")
	var verticalDirection: float = Input.get_axis("move_up", "move_down")
	
	if canMoove:
		if Input.is_action_just_pressed("start_record"):
			firstRecPos = global_position
			inputsArr = []
		elif Input.is_action_just_pressed("activate_clone"):
			createClone()
		elif Input.is_action_just_pressed("jump"):
			desiredJump = true
		if Input.is_action_just_released("jump") && currentState == State.Jump:
			velocity.y /= 3.5

func _physics_process(delta: float) -> void:
	var currActions = []
	for action in InputMap.get_actions():
		if Input.is_action_pressed(action):
			currActions.append(str(action))
	inputsArr.append(currActions)
	
	var horizontalDirection: float = Input.get_axis("move_left", "move_right")
	var verticalDirection: float = Input.get_axis("move_up", "move_down")
	var wasOnFloor: bool = is_on_floor()
	
	if horizontalDirection != 0 && canMoove:
		lastNonNullDir = horizontalDirection
	lastVelocity = velocity
	
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
			velocity = movePlayer(delta, MAX_WALKING_SPEED)
			
			if desiredJump:
				doAJump()
			elif is_on_floor():
				if velocity.x != 0:
					currentState = State.Walk
				else:
					currentState = State.Idle
		State.Walk:
			velocity = movePlayer(delta, MAX_WALKING_SPEED)
			if desiredJump:
				doAJump()
			elif !is_on_floor():
				currentState = State.Fall
			elif velocity.x == 0:
				currentState = State.Idle
		State.Jump:
			velocity = movePlayer(delta, MAX_WALKING_SPEED)
			
			if velocity.y > 0:
				currentState = State.Fall
	
	move_and_slide()
	
	if wasOnFloor && !is_on_floor() && velocity.y >= 0:
		coyoteJumpTimer.start()
	if (!wasOnFloor && is_on_floor()):
		if jumpBufferTimer.time_left > 0 && !usedJumpBuffer:
			doAJump()
			usedJumpBuffer = true

#===================================================================================================
