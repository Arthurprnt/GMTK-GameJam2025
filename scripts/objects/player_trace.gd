extends Node2D

var startProcess: bool = false

func init(traceColor: Color, pos: Vector2) -> void:
	modulate = traceColor
	global_position = pos
	visible = true
	startProcess = true

func _ready() -> void:
	GLOBAL.killTrace.connect(func(): queue_free())

func _physics_process(delta: float) -> void:
	if startProcess:
		modulate = Color(modulate.r, modulate.g, modulate.b, lerpf(modulate.a, 0, 0.01))
		if modulate.a <= 0.01:
			queue_free()
