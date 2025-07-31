extends StaticBody2D

@export var activationSpeed: float = 25

@onready var sprite: Sprite2D = $Sprite

var spriteHeight: int = 2
var notPressedPos: Vector2
var pressedPos: Vector2
var nbEntitiesOnTop: int = 0

enum State {
	Pressed,
	NotPressed
}
var currentState: State = State.NotPressed

func _ready() -> void:
	notPressedPos = global_position
	pressedPos = notPressedPos + Vector2(0, spriteHeight)

func _physics_process(delta: float) -> void:
	match currentState:
		State.Pressed:
			global_position.x = move_toward(global_position.x, pressedPos.x, delta * activationSpeed)
			global_position.y = move_toward(global_position.y, pressedPos.y, delta * activationSpeed)
		State.NotPressed:
			global_position.x = move_toward(global_position.x, notPressedPos.x, delta * activationSpeed)
			global_position.y = move_toward(global_position.y, notPressedPos.y, delta * activationSpeed)

func _on_activation_zone_body_entered(_body: Node2D) -> void:
	nbEntitiesOnTop += 1
	if nbEntitiesOnTop > 0:
		currentState = State.Pressed

func _on_activation_zone_body_exited(_body: Node2D) -> void:
	nbEntitiesOnTop -= 1
	if nbEntitiesOnTop == 0:
		currentState = State.NotPressed
