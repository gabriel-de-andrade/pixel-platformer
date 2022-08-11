extends KinematicBody2D
class_name Player


enum { MOVE, CLIMB }

export(Resource) var movement_data: Resource = load("res://DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity := Vector2.ZERO
var state := MOVE
var double_jump: int = movement_data.DOUBLE_JUMP_COUNT
var buffered_jump := false
var coyote_jump := false

onready var animatedSprite := $AnimatedSprite as AnimatedSprite
onready var ladderCheck := $LadderCheck as RayCast2D
onready var jumpBufferTimer := $JumpBufferTimer as Timer
onready var coyoteJumpTimer := $CoyoteJumpTimer as Timer

func _ready() -> void:
    animatedSprite.frames = preload("res://PlayerGreenSkin.tres") as SpriteFrames

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

    if not horizontal_move(input):
        apply_friction()
        animatedSprite.animation = "idle"
    else:
        apply_acceleration(input.x)
        animatedSprite.animation = "run"
        animatedSprite.flip_h = input.x > 0

    if is_on_floor():
        reset_double_jump()
    else:
        animatedSprite.animation = "jump"

    if can_jump():
        input_jump()
    else:
        input_jump_release()
        input_double_jump()
        buffer_jump()
        fast_fall()

    var was_on_floor := is_on_floor()
    var was_in_air := not is_on_floor()

    velocity = move_and_slide(velocity, Vector2.UP)

    var just_landed := was_in_air and is_on_floor()
    if just_landed:
        animatedSprite.animation = "run"
        animatedSprite.frame = 1

    var just_left_ground := not is_on_floor() and was_on_floor

    if just_left_ground and velocity.y >= 0:
        coyote_jump = true
        coyoteJumpTimer.start()

func climb_state(input: Vector2) -> void:
    if not is_on_ladder(): state = MOVE

    if input.length() != 0:
        animatedSprite.animation = "run"
    else:
        animatedSprite.animation = "idle"

    velocity = input * movement_data.CLIMB_SPEED
    velocity = move_and_slide(velocity, Vector2.UP)

func input_jump() -> void:
    if Input.is_action_pressed("ui_up") or buffered_jump:
        velocity.y = movement_data.JUMP_FORCE
        buffered_jump = false
        coyote_jump = false

func reset_double_jump() -> void:
    double_jump = movement_data.DOUBLE_JUMP_COUNT

func can_jump() -> bool:
    return is_on_floor() or coyote_jump

func horizontal_move(input: Vector2) -> bool:
    return input.x != 0

func input_jump_release() -> void:
    if Input.is_action_just_released("ui_up") and velocity.y < movement_data.JUMP_RELEASE_FORCE:
        velocity.y = movement_data.JUMP_RELEASE_FORCE

func input_double_jump() -> void:
    if Input.is_action_just_pressed("ui_up") and double_jump > 0:
        velocity.y = movement_data.JUMP_FORCE
        double_jump -= 1

func buffer_jump() -> void:
    if Input.is_action_just_pressed("ui_up"):
        buffered_jump = true
        jumpBufferTimer.start()

func fast_fall() -> void:
    if velocity.y > 0:
        velocity.y += movement_data.ADITIONAL_FALL_GRAVITY

func is_on_ladder() -> bool:
    if not ladderCheck.is_colliding(): return false
    if not ladderCheck.get_collider() is Ladder: return false
    return true

func set_fast_player_mode() -> void:
    movement_data = load("res://FastPlayerMovementData.tres") as PlayerMovementData
    print("Fast Player Mode On")

func _on_JumpBufferTimer_timeout() -> void:
    buffered_jump = false

func _on_CoyoteJumpTimer_timeout() -> void:
    coyote_jump = false
