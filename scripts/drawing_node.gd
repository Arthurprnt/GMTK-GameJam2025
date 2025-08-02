extends Node2D

var lineTemplate: Line2D = Line2D.new()


func drawLine(from: Vector2, to: Vector2, color: Color) -> void:
	var newLine: Line2D = lineTemplate.duplicate()
	newLine.default_color = color
	newLine.add_point(from)
	newLine.add_point(to)
	add_child(newLine)

func _ready() -> void:
	lineTemplate.width = 1
	
func _physics_process(_delta: float) -> void:
	for c in get_children():
		c.queue_free()
	if GLOBAL.sceneManager.currentSceneType == "level" && Input.is_action_pressed("tab"):
		for n in GLOBAL.sceneManager.currentScenes["level"].get_children():
			if n is ActivableDoor || n is CubeDispenser || n is ForceField || n is KillField || n is Pulsor:
				for es in n.energySources:
					drawLine(to_local(n.global_position), to_local(es.global_position), GLOBAL.linesColor)
			if n is Pulsor:
				for es in n.reversingSources:
					drawLine(to_local(n.global_position), to_local(es.global_position), Color("#f58122"))
