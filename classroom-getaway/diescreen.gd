extends Control
signal animation_finished
signal textbox_closed
func _ready() -> void:
	$"Death Panel".hide()
	$Label.hide()
	TransitionScreen.transition()
	await TransitionScreen.transitioned
	$AnimationPlayer.play("game_over_text")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(.5).timeout
	$Label.show()
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
	$"Death Panel".show()
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $Label.visible:
		$RichTextLabel.hide()
		$Label.hide()
		emit_signal("textbox_closed")
	
func signal_emit():
	if $AnimationPlayer.play("game_over_text"):
		animation_finished.emit()



func _on_retry_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	TransitionScreen.transition()
	await TransitionScreen.transitioned
	get_tree().change_scene_to_file("res://Rooms/game_level.tscn")
	



func _on_quit_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	TransitionScreen.transition()
	await TransitionScreen.transitioned
	get_tree().quit()
