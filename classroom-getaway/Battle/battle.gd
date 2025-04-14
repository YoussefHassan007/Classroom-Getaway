extends Control
signal textbox_closed
signal animation_finished
var is_defending = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export  var enemy: Resource = null
var current_player_health = 0
var current_enemy_health = 0
func _ready() -> void:
	$"Skill Panel2".hide()
	$"Skill Panel".hide()
	BattleTransition.animation_player.play("fade_out")
	$SFX/AudioStreamPlayer2D.play()
	$TextBox.hide()
	$PlayerPanel.hide()
	$ActionsPanel.hide()
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	
	display_text(" WATSON STOPS YOU IN YOUR TRACKS")
	await textbox_closed
	$PlayerPanel.show()
	$ActionsPanel.show()
	
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
	
	
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $TextBox.visible:
		
		$TextBox.hide()
		emit_signal("textbox_closed")
		
func display_text(text):
	$TextBox.show()
	$TextBox/Label.text = text
func set_player_controls():
	$ActionsPanel/Actions/ATTACK.disabled
	$ActionsPanel/Actions/DEFEND.disabled
	$ActionsPanel/Actions/Run.disabled
func _on_run_pressed() -> void:
	display_text("Got Away Safely")
	await textbox_closed
	
	TransitionScreen.transition()
	await TransitionScreen.transitioned
	
	get_tree().change_scene_to_file("res://Rooms/game_level.tscn")


func enemy_turn():
	set_player_controls()
	display_text("%s Launches At You!" % enemy.name)
	await textbox_closed
	if is_defending:
		is_defending = false
		animation_player.play("defense_shake")
		await animation_player.animation_finished
		display_text("You Defended His Attack")
		await textbox_closed
	else:
		$SFX/Playerhurt.play()
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("screen_shake")
		await animation_player.animation_finished
		display_text("%s did %d damage" % [enemy.name,State.damage])
		await textbox_closed
	
	
func _on_attack_pressed() -> void:
	$"Skill Panel2".show()
	$"Skill Panel".show()
	
	if current_enemy_health == 0:
	
		animation_player.play("music_fade")

		$ActionsPanel.hide()
		$PlayerPanel.hide()
		#animation_player.play("music_fade")
		display_text("%s Has Been Knocked Out" % enemy.name)
		await textbox_closed
		
		animation_player.play("enemy_die")
		await animation_player.animation_finished
		
		display_text("You gained %s exp" % enemy.exp_given)
		await textbox_closed
		
		TransitionScreen.transition()
		await TransitionScreen.transitioned
		
		get_tree().change_scene_to_file("res://Rooms/game_level.tscn")
		
	enemy_turn()

func _on_defend_pressed() -> void:
	is_defending = true
	display_text("You Drive Your Feet Into the Ground")
	await textbox_closed
	timer.start(0.25)
	
	await timer.timeout
	
	enemy_turn()
	
	
