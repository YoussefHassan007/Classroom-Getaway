extends CanvasLayer
signal transitioned
func _ready() -> void:
	$ColorRect.visible = false

func transition():
	$AnimationPlayer.play("fade_to_black")
	$ColorRect.visible = true
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		
		transitioned.emit()
		$AnimationPlayer.play("fade_to_scene")
	else:
		$ColorRect.visible = false
