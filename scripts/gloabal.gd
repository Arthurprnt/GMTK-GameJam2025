extends Node

signal endLevel

var clone: CharacterBody2D
var currentLevel: int = 1
var levelsUnlocked: Array[int] = [1]
var nbLevel: int = 4
var player: CharacterBody2D
var sceneManager: Node
var showTimers: bool = true
var totalTimeInLevels: float = 0
var timeInCurrentLevel: float = 0

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
