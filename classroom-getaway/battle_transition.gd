extends CanvasLayer


signal transitioned_to_battle
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	$ColorRect.visible = false
	
func battle_transition():
	$AnimationPlayer.play("fade_in")
	$ColorRect.visible = true
	
	

func battle_scene_out():
	$AnimationPlayer.play("fade_out")







func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		transitioned_to_battle.emit()
		$AnimationPlayer.play("fade_out")
	if anim_name == "fade_out":
		$ColorRect.visible = false
