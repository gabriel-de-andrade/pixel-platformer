extends KinematicBody2D
class_name Player


enum { MOVE, CLIMB }

export(Resource) var movement_data: Resource = load("res://DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity := Vector2.ZERO
var state := MOVE

onready var animatedSprite := $AnimatedSprite as AnimatedSprite
onready var ladderCheck := $LadderCheck as RayCast2D

func _ready() -> void:
    animatedSprite.frames = load("res://PlayerGreenSkin.tres") as SpriteFrames

func _physics_process(_delta: float) -> void:
    var input := Vector2.ZERO
    input.x = Input.get_axis("ui_left", "ui_right")
    input.y = Input.get_axis("ui_up", "ui_down")

    match state:
        MOVE: move_state(input)
        CLIMB: climb_state(input)

func _input(_event: InputEvent) -> void:
    if Input.is_key_pressed(KEY_F):
        set_fast_player_mode()

func apply_gravity() -> void:
    velocity.y += movement_data.GRAVITY
    velocity.y = min(velocity.y, 200)

func apply_friction() -> void:
    velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION)

func apply_acceleration(amount: float) -> void:
    velocity.x = move_toward(velocity.x, movement_data.MAX_SPEED * amount, movement_data.ACCELETATION)

func move_state(input: Vector2) -> void:
    if is_on_ladder() and Input.is_action_pressed("ui_up"):
        state = CLIMB

    apply_gravity()

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

func climb_state(input: Vector2) -> void:
    if not is_on_ladder(): state = MOVE

    if input.length() != 0:
        animatedSprite.animation = "run"
    else:
        animatedSprite.animation = "idle"

    velocity = input * 50
    velocity = move_and_slide(velocity, Vector2.UP)

func is_on_ladder() -> bool:
    if not ladderCheck.is_colliding(): return false
    if not ladderCheck.get_collider() is Ladder: return false
    return true

func set_fast_player_mode() -> void:
    movement_data = load("res://FastPlayerMovementData.tres") as PlayerMovementData
    print("Fast Player Mode On")
