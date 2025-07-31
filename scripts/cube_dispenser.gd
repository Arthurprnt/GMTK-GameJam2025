extends StaticBody2D

@export var automaticalyDispense: bool = true
@export var energySources: Array[StaticBody2D] = []

@onready var dropPos: Node2D = $DropPos
@onready var cubeScene: PackedScene = preload("res://scenes/pressure_cube.tscn")

var cubeChild: CharacterBody2D

func createChild() -> void:
	var newCube: CharacterBody2D = cubeScene.instantiate()
	newCube.global_position = dropPos.global_position
	cubeChild = newCube
	get_tree().current_scene.add_child.call_deferred(cubeChild)
	
func _ready() -> void:
	if automaticalyDispense:
		createChild()

func _physics_process(delta: float) -> void:
	var isActivated: bool = true
	for es in energySources:
		if es.currentState == es.State.NotPressed:
			isActivated = false
	
	if !is_instance_valid(cubeChild) && (automaticalyDispense || isActivated):
		createChild()
