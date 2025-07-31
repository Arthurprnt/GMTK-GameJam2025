extends Node2D

@onready var endMenuScene: PackedScene = preload("res://scenes/menus/finished_level_menu.tscn")

func showEndMenu() -> void:
	GLOBAL.player.canMoove = false
	GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)
	add_child(endMenuScene.instantiate())

func _ready() -> void:
	GLOBAL.endLevel.connect(showEndMenu)
