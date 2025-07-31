extends StaticBody2D

enum State {
	Pressed,
	NotPressed
}
var currentState: State = State.NotPressed

func _physics_process(delta: float) -> void:
	match currentState:
		State.Pressed:
			pass
		State.NotPressed:
			pass

func _on_activation_zone_body_entered(body: Node2D) -> void:
	currentState = State.Pressed

func _on_activation_zone_body_exited(body: Node2D) -> void:
	currentState = State.NotPressed
