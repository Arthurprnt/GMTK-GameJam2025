extends Area2D

@export var height: float = 32

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox

func _ready() -> void:
	sprite.scale.y = height/32
	hitbox.shape.size = Vector2(3, height)

func _on_body_entered(body: Node2D) -> void:
	if body is Cube:
		body.queue_free()
	elif body is CharacterBody2D:
		if body.holdingCube:
			body.holdedCube.queue_free()
