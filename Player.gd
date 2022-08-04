extends KinematicBody2D


export(int) var JUMP_FORCE = -160
export(int) var JUMP_RELEASE_FORCE = -40
export(int) var MAX_SPEED = 75
export(int) var ACCELETATION = 10
export(int) var FRICTION = 15
export(int) var GRAVITY = 5
export(int) var ADITIONAL_FALL_GRAVITY = 2

var velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
    apply_gravity()

    var input = Vector2.ZERO

    input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    if input.x == 0:
        apply_friction()
    else:
        apply_acceleration(input.x)

    if is_on_floor():
        if Input.is_action_pressed("ui_up"):
            velocity.y = JUMP_FORCE
    else:
        if Input.is_action_just_released("ui_up") and velocity.y < JUMP_RELEASE_FORCE:
            velocity.y = JUMP_RELEASE_FORCE

        if velocity.y > 0:
            velocity.y += ADITIONAL_FALL_GRAVITY

    velocity = move_and_slide(velocity, Vector2.UP)

func apply_gravity() -> void:
    velocity.y += GRAVITY

func apply_friction() -> void:
    velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount: float) -> void:
    velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELETATION)
