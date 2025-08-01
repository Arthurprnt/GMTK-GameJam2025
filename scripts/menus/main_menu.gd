extends Control

@onready var spawnPos: Node2D = $LevelBackgound/SpawnPos
@onready var levelBackgound: Node2D = $LevelBackgound
@onready var playButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/PlayButton
@onready var blackFade: ColorRect = $BlackFade

@onready var playerScene: PackedScene = preload("res://scenes/objects/player.tscn")

var codes: Dictionary = {
	"konami": ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a"],
	"all_levels": ["u", "n", "l", "o", "c", "k", "a", "l", "l"]
}
var currentInputs: Dictionary = {
	"konami": [],
	"all_levels": []
}
var usedCode: Dictionary = {
	"konami": false,
	"all_levels": false
}

var exit: bool = false
var exitValue: float = 1.8

func funcToConnect() -> void:
	GLOBAL.sceneManager.changeScene("res://scenes/levels/level_0.tscn", "level")
	GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)

func _ready() -> void:
	playButton.grab_focus()
	GLOBAL.sceneManager.currentScenes["level"] = levelBackgound
	GLOBAL.endLevel.connect(funcToConnect)

func _on_play_button_pressed() -> void:
	GLOBAL.endLevel.disconnect(funcToConnect)
	GLOBAL.sceneManager.changeScene("res://scenes/menus/level_menu.tscn", "control")

func _on_button_pressed() -> void:
	exit = true

func _process(_delta: float) -> void:
	for k in codes.keys():
		for action in InputMap.get_actions():
			if str(action) in ["left", "right", "up", "down", "a", "b", "u", "n", "l", "o", "c", "k", "a"]:
				if Input.is_action_just_pressed(action):
					currentInputs[k].append(str(action))
			elif Input.is_action_just_pressed(action) && !(str(action) in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_text_caret_left", "ui_text_caret_right", "ui_text_caret_up", "ui_text_caret_down", "start_record"]):
					currentInputs[k] = []
		if currentInputs[k] == codes[k] && !usedCode[k]:
			if k == "konami":
				usedCode[k] = true
				var player: CharacterBody2D = playerScene.instantiate()
				player.JUMP_HEIGHT *= 2
				player.get_child(0).queue_free()
				spawnPos.add_child(player)
				GLOBAL.startDropping.emit()
			elif k == "all_levels":
				GLOBAL.unlockAllLevels()
		elif currentInputs[k] != codes[k].duplicate().slice(0, currentInputs[k].size()):
			currentInputs[k] = []

func _physics_process(delta: float) -> void:
	if exit:
		blackFade.modulate = Color(255, 255, 255, move_toward(blackFade.modulate.a, exitValue, 5*delta))
		if blackFade.modulate.a >= exitValue-0.01:
			get_tree().quit()
