extends KinematicBody2D


export(int) var JUMP_FORCE = -160
export(int) var JUMP_RELEASE_FORCE = -40
export(int) var MAX_SPEED = 75
export(int) var ACCELETATION = 10
export(int) var FRICTION = 15
export(int) var GRAVITY = 5
export(int) var ADITIONAL_FALL_GRAVITY = 2

var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite

func _ready() -> void:
    animatedSprite.frames = load("res://PlayerGreenSkin.tres")

func _physics_process(_delta: float) -> void:
    apply_gravity()

    var input = Vector2.ZERO

    input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

    if input.x == 0:
        apply_friction()
        animatedSprite.animation = "idle"
    else:
        apply_acceleration(input.x)
        animatedSprite.animation = "run"
        if input.x > 0:
            animatedSprite.flip_h = true
        else:
            animatedSprite.flip_h = false

    if is_on_floor():
        if Input.is_action_pressed("ui_up"):
            velocity.y = JUMP_FORCE
    else:
        animatedSprite.animation = "jump"

        if Input.is_action_just_released("ui_up") and velocity.y < JUMP_RELEASE_FORCE:
            velocity.y = JUMP_RELEASE_FORCE

        if velocity.y > 0:
            velocity.y += ADITIONAL_FALL_GRAVITY

    var was_in_air = not is_on_floor()

    velocity = move_and_slide(velocity, Vector2.UP)

    var just_landed = was_in_air and is_on_floor()
    if just_landed:
        animatedSprite.animation = "run"
        animatedSprite.frame = 1

func apply_gravity() -> void:
    velocity.y += GRAVITY
    velocity.y = min(velocity.y, 200)

func apply_friction() -> void:
    velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount: float) -> void:
    velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELETATION)
