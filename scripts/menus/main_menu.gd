extends Control

@onready var spawnPos: Node2D = $LevelBackgound/SpawnPos
@onready var levelBackgound: Node2D = $LevelBackgound
@onready var playButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/PlayButton
@onready var blackFade: ColorRect = $BlackFade

@onready var playerScene: PackedScene = preload("res://scenes/objects/player.tscn")

var code: Array[String] = ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a"]
var currentInputs: Array[String] = []
var usedCode: bool = false

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

func _process(delta: float) -> void:
	for action in InputMap.get_actions():
		if str(action) in ["left", "right", "up", "down", "a", "b"]:
			if Input.is_action_just_pressed(action):
				currentInputs.append(str(action))
		elif Input.is_action_just_pressed(action) && !(str(action) in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_text_caret_left", "ui_text_caret_right", "ui_text_caret_up", "ui_text_caret_down"]):
				currentInputs = []
	if currentInputs == code && !usedCode:
		usedCode = true
		var player: CharacterBody2D = playerScene.instantiate()
		player.JUMP_HEIGHT *= 2
		player.get_child(0).queue_free()
		spawnPos.add_child(player)
		GLOBAL.startDropping.emit()
	elif currentInputs != code.duplicate().slice(0, currentInputs.size()):
		currentInputs = []

func _physics_process(delta: float) -> void:
	if exit:
		blackFade.modulate = Color(255, 255, 255, move_toward(blackFade.modulate.a, exitValue, 5*delta))
		if blackFade.modulate.a >= exitValue-0.01:
			get_tree().quit()
