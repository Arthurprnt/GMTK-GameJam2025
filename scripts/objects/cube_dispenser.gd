extends StaticBody2D
class_name CubeDispenser

@export var automaticalyDispense: bool = true
@export var energySources: Array[StaticBody2D] = []

@onready var dropPos: Node2D = $DropPos
@onready var cubeScene: PackedScene = preload("res://scenes/objects/pressure_cube.tscn")

var cubeChild: CharacterBody2D
var droppedSincedLastAct: bool = false

func buttonPressed(btn: Bouton) -> void:
	if btn in energySources && energySources.size() == 1:
		droppedSincedLastAct = false

func createChild() -> void:
	if is_instance_valid(cubeChild):
		cubeChild.queue_free()
	droppedSincedLastAct = true
	var newCube: CharacterBody2D = cubeScene.instantiate()
	newCube.global_position = dropPos.global_position
	cubeChild = newCube
	GLOBAL.sceneManager.currentScenes["level"].add_child.call_deferred(cubeChild)
	
func _ready() -> void:
	GLOBAL.buttonPressed.connect(buttonPressed)
	if automaticalyDispense:
		await GLOBAL.startDropping
		createChild()

func _physics_process(_delta: float) -> void:
	var isActivated: bool = true
	for es in energySources:
		if es.currentState == es.State.NotPressed:
			isActivated = false
	if energySources == []:
		isActivated = false
	
	if !isActivated:
		droppedSincedLastAct = false
	
	if (!is_instance_valid(cubeChild) && automaticalyDispense) || (isActivated && !droppedSincedLastAct):
		createChild()
