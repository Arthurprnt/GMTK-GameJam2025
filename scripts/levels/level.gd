extends Node2D

@export var cloneNumber: int = 1
@onready var endMenuScene: PackedScene = preload("res://scenes/menus/finished_level_menu.tscn")

func showEndMenu() -> void:
	GLOBAL.player.canMoove = false
	GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)
	add_child(endMenuScene.instantiate())

func _ready() -> void:
	GLOBAL.endLevel.connect(showEndMenu)
	await get_tree().create_timer(0.1).timeout
	GLOBAL.player.maxCloneNumber = cloneNumber

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		GLOBAL.sceneManager.changeScene("res://scenes/levels/level_" + str(GLOBAL.currentLevel) +".tscn", "level")
