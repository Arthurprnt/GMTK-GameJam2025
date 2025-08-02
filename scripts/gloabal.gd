extends Node

signal endLevel
signal killTrace
signal startDropping

@onready var cloneScene: PackedScene = preload("res://scenes/objects/clone.tscn")

var cctvSeen: Array = []
var cctvNb: int = 5
var clone: CharacterBody2D
var currentLevel: int = 1
var defaultGravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var levelsUnlocked: Array = [1]
var linesColor: Color = Color("#25acf5")
var nbCloneAvailable: int = 1
var nbLevel: int = 9
var player: CharacterBody2D
var sceneManager: Node
var showTimers: bool = true
var totalTimeInLevels: float = 0
var timeInCurrentLevel: float = 0

func createClone(firstRecPos: Vector2, firstRecDir: float, inputsArr: Array, ind: int) -> void:
	var newClone: CharacterBody2D = cloneScene.instantiate()
	GLOBAL.sceneManager.currentScenes["level"].add_child(newClone)
	newClone.init(firstRecPos, firstRecDir, inputsArr.duplicate(), ind)

func msToTimer(timeInSeconds: float) -> String:
	@warning_ignore("integer_division")
	var hours = int(timeInSeconds)/3600
	timeInSeconds -= hours*3600
	@warning_ignore("integer_division")
	var minutes = int(timeInSeconds)/60
	timeInSeconds -= minutes*60
	var seconds = int(timeInSeconds)
	timeInSeconds -= seconds
	var ms = int(timeInSeconds*1000)
	
	var strHours: String = str(hours)
	if hours < 10:
		strHours = "0%s" % strHours
	var strMinutes: String = str(minutes)
	if minutes < 10:
		strMinutes = "0%s" % strMinutes
	var strSeconds: String = str(seconds)
	if seconds < 10:
		strSeconds = "0%s" % strSeconds
	var strMs: String = str(ms)
	if ms < 100:
		strMs = "0%s" % strMs
	if ms < 10:
		strMs = "0%s" % strMs
	
	if hours > 0:
		return "%s:%s:%s.%s" % [strHours, strMinutes, strSeconds, strMs]
	else:
		return "%s:%s.%s" % [strMinutes, strSeconds, strMs]

func playParticles(particles: CPUParticles2D) -> void:
	# Allow to bypass the lifetime wait time before the particles can start to play again
	var newParticles: CPUParticles2D = particles.duplicate()
	newParticles.global_position = particles.global_position
	GLOBAL.sceneManager.currentScenes["level"].add_child(newParticles)
	newParticles.emitting = true
	await get_tree().create_timer(newParticles.lifetime + 1).timeout
	if is_instance_valid(newParticles):
		newParticles.queue_free()

func unlockAllLevels() -> void:
	levelsUnlocked = range(1, nbLevel+1)
