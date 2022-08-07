extends KinematicBody2D


var direction := Vector2.RIGHT
var velocity := Vector2.ZERO

onready var animatedSprite := $AnimatedSprite as AnimatedSprite
onready var ledgeCheck := $LedgeCheck as RayCast2D

func _physics_process(_delta: float) -> void:
    var found_wall := is_on_wall()
    var found_ledge := not ledgeCheck.is_colliding()

    if found_wall or found_ledge:
        direction *= -1
        animatedSprite.scale.x *= -1
        ledgeCheck.position.x *= -1

    velocity = direction * 25
    velocity = move_and_slide(velocity, Vector2.UP)
