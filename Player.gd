extends KinematicBody2D
class_name Player


export(Resource) var movement_data: Resource = load("res://DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity := Vector2.ZERO

onready var animatedSprite := $AnimatedSprite as AnimatedSprite

func _ready() -> void:
    animatedSprite.frames = load("res://PlayerGreenSkin.tres") as SpriteFrames

func _physics_process(_delta: float) -> void:
    apply_gravity()

    var input := Vector2.ZERO

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
            velocity.y = movement_data.JUMP_FORCE
    else:
        animatedSprite.animation = "jump"

        if Input.is_action_just_released("ui_up") and velocity.y < movement_data.JUMP_RELEASE_FORCE:
            velocity.y = movement_data.JUMP_RELEASE_FORCE

        if velocity.y > 0:
            velocity.y += movement_data.ADITIONAL_FALL_GRAVITY

    var was_in_air := not is_on_floor()

    velocity = move_and_slide(velocity, Vector2.UP)

    var just_landed := was_in_air and is_on_floor()
    if just_landed:
        animatedSprite.animation = "run"
        animatedSprite.frame = 1

func _input(event: InputEvent) -> void:
    if Input.is_key_pressed(KEY_F):
        set_fast_player_mode()

func apply_gravity() -> void:
    velocity.y += movement_data.GRAVITY
    velocity.y = min(velocity.y, 200)

func apply_friction() -> void:
    velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION)

func apply_acceleration(amount: float) -> void:
    velocity.x = move_toward(velocity.x, movement_data.MAX_SPEED * amount, movement_data.ACCELETATION)

func set_fast_player_mode() -> void:
    movement_data = load("res://FastPlayerMovementData.tres") as PlayerMovementData
    print("Fast Player Mode On")
