extends Node

@onready var levelScene: Node2D = $LevelScene
@onready var _2dScene: Node2D = $"2dScene"
@onready var controlScene: Control = $controlScene

@onready var fpsCounter: Label = $Overlay/LabelsContainer/FPSCounter
@onready var totalTimeLabel: Label = $Overlay/LabelsContainer/TotalTime
@onready var currentTimeLabel: Label = $Overlay/LabelsContainer/CurrentTime

var currentSceneType: String = "control"
var currentSceneName: String
var currentScenes: Dictionary = {
	"menu" = null,
	"puzzle" = null,
	"level" = null,
	"3d" = null,
	"2d" = null,
	"control" = null
}

func changeScene(newScenePath: String, newSceneType: String)-> void:
	currentSceneName = newScenePath
	var temp: Node = currentScenes[currentSceneType]
	if newSceneType == "2d":
		var newScene: Node2D = load(newScenePath).instantiate()
		_2dScene.add_child(newScene)
		currentScenes["2d"] = newScene
		for s in get_tree().get_nodes_in_group("scenesNodes"):
			if s != _2dScene:
				s.visible = false
		changeTimerLabelsVisibilityTo(false)
		_2dScene.visible = true
	elif newSceneType == "level":
		var newScene: Node2D = load(newScenePath).instantiate()
		levelScene.add_child(newScene)
		currentScenes["level"] = newScene
		for s in get_tree().get_nodes_in_group("scenesNodes"):
			if s != levelScene:
				s.visible = false
		levelScene.visible = true
		if GLOBAL.showTimers:
			changeTimerLabelsVisibilityTo(true)
	elif newSceneType == "control":
		var newScene: Control = load(newScenePath).instantiate()
		controlScene.add_child(newScene)
		currentScenes["control"] = newScene
		for s in get_tree().get_nodes_in_group("scenesNodes"):
			if s != controlScene:
				s.visible = false
		changeTimerLabelsVisibilityTo(false)
		controlScene.visible = true
	
	if temp != null && !(newSceneType in ["puzzle", "menu"]):
		temp.queue_free()
	if newSceneType != "menu":
		currentSceneType = newSceneType
	#print_tree_pretty()
	GLOBAL.startDropping.emit()

func changeTimerLabelsVisibilityTo(newValue: bool) -> void:
	totalTimeLabel.visible = newValue
	currentTimeLabel.visible = newValue

func _ready() -> void:
	GLOBAL.sceneManager = self
	changeScene("res://scenes/menus/main_menu.tscn", "control")

func _physics_process(delta: float) -> void:
	fpsCounter.text = "FPS: " + str(Engine.get_frames_per_second())
	if levelScene.get_children().size() > 0:
		GLOBAL.totalTimeInLevels += delta
		GLOBAL.timeInCurrentLevel += delta
		totalTimeLabel.text = GLOBAL.msToTimer(GLOBAL.totalTimeInLevels)
		currentTimeLabel.text = GLOBAL.msToTimer(GLOBAL.timeInCurrentLevel)
