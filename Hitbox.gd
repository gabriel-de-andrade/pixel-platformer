extends Area2D


func _on_Hitbox_body_entered(body: Node) -> void:
    if body is Player:
        body.die()
