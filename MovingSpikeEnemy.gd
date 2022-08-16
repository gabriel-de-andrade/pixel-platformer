tool
extends Path2D


enum ANIMATION_TYPE {
    LOOP,
    BOUNCE
}

export(ANIMATION_TYPE) var animation_type setget set_animation_type
export(float) var animation_speed: float setget set_animation_speed

onready var animationPlayer = $AnimationPlayer as AnimationPlayer

func _ready() -> void:
    play_updated_animation(animationPlayer)

func set_animation_type(type: int) -> void:
    animation_type = type
    var animation_player := find_node("AnimationPlayer") as AnimationPlayer
    if animation_player:
        play_updated_animation(animation_player)

func set_animation_speed(speed: float) -> void:
    animation_speed = speed
    var animation_player := find_node("AnimationPlayer") as AnimationPlayer
    if animation_player:
        animation_player.playback_speed = animation_speed

func play_updated_animation(animation_player: AnimationPlayer) -> void:
    match animation_type as int:
        ANIMATION_TYPE.LOOP:
            animation_player.play("move_along_path_loop")
        ANIMATION_TYPE.BOUNCE:
            animation_player.play("move_along_path_bounce")
