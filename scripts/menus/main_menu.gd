extends Control

@onready var spawnPos: Node2D = $LevelBackgound/SpawnPos
@onready var levelBackgound: Node2D = $LevelBackgound
@onready var playButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/PlayButton
@onready var optionsButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var quitButton: Button = $VBoxContainer/MarginContainer/VBoxContainer/QuitButton
@onready var blackFade: ColorRect = $BlackFade

@onready var playerScene: PackedScene = preload("res://scenes/objects/player.tscn")
@onready var hardTheme: Theme = preload("res://themes/hard_level_button.tres")

@onready var credit: Label = $Credit

var codes: Dictionary = {
	"konami": ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a"],
	"all_levels": ["u", "n", "l", "o", "c", "k", "a", "l", "l"],
	"help": ["l", "e", "t", "m", "e", "o", "u", "t"]
}
var currentInputs: Dictionary = {
	"konami": [],
	"all_levels": [],
	"help": []
}
var usedCode: Dictionary = {
	"konami": false,
	"all_levels": false,
	"help": false
}

var spaceEvent = InputMap.action_get_events("ui_accept")[2]
var exit: bool = false
var exitValue: float = 1.8

func funcToConnect() -> void:
	GLOBAL.sceneManager.ost.stop()
	InputMap.action_add_event("ui_accept", spaceEvent)
	GLOBAL.sceneManager.changeScene("res://scenes/levels/level_0.tscn", "level")
	GLOBAL.currentLevel = 0
	GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)

func _ready() -> void:
	playButton.grab_focus()
	GLOBAL.sceneManager.currentScenes["level"] = levelBackgound
	GLOBAL.endLevel.connect(funcToConnect)

func _on_play_button_pressed() -> void:
	GLOBAL.endLevel.disconnect(funcToConnect)
	if !usedCode["help"]:
		GLOBAL.sceneManager.changeScene("res://scenes/menus/level_menu.tscn", "control")
	else:
		GLOBAL.sceneManager.changeScene("res://scenes/levels/level_-1.tscn", "level")
		GLOBAL.currentLevel = -1
		GLOBAL.sceneManager.changeTimerLabelsVisibilityTo(false)
		GLOBAL.sceneManager.ost.stop()

func _on_options_button_pressed() -> void:
	if !usedCode["help"]:
		GLOBAL.sceneManager.changeScene("res://scenes/menus/options_menu.tscn", "control")
	else:
		credit.text = "Don't try to escape"

func _on_quit_button_pressed() -> void:
	if !usedCode["help"]:
		blackFade.visible = true
		exit = true
	else:
		credit.text = "There are no ways out"

func _process(_delta: float) -> void:
	for k in codes.keys():
		for action in InputMap.get_actions():
			if str(action) in ["left", "right", "up", "down", "a", "b", "u", "n", "l", "o", "c", "k", "a", "e", "t", "m"]:
				if Input.is_action_just_pressed(action):
					currentInputs[k].append(str(action))
			elif Input.is_action_just_pressed(action) && !(str(action) in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_text_caret_left", "ui_text_caret_right", "ui_text_caret_up", "ui_text_caret_down", "start_record", "interact"]):
					currentInputs[k] = []
		if currentInputs[k] == codes[k] && !usedCode[k]:
			usedCode[k] = true
			if k == "konami":
				InputMap.action_erase_event("ui_accept", spaceEvent)
				var player: CharacterBody2D = playerScene.instantiate()
				player.JUMP_HEIGHT *= 2
				player.get_child(0).queue_free()
				spawnPos.add_child(player)
				GLOBAL.startDropping.emit()
			elif k == "all_levels":
				GLOBAL.unlockAllLevels()
			elif k == "help":
				GLOBAL.sceneManager.ost.stop()
				playButton.theme = hardTheme
				optionsButton.theme = hardTheme
				quitButton.theme = hardTheme
		elif currentInputs[k] != codes[k].duplicate().slice(0, currentInputs[k].size()):
			currentInputs[k] = []

func _physics_process(delta: float) -> void:
	if exit:
		blackFade.modulate = Color(255, 255, 255, move_toward(blackFade.modulate.a, exitValue, 5*delta))
		if blackFade.modulate.a >= exitValue-0.01:
			get_tree().quit()
