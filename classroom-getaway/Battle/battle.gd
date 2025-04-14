extends Control
signal textbox_closed
signal animation_finished
var is_defending = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export  var enemy: Resource = null
var enemy_crit_hit = 0
var enemy_crit_chance = 0
var current_enemy_accuracy = 0
var current_enemy_defense = 0
var current_player_health = 0
var current_enemy_health = 0
var Sc_equation = (State.damage * 2)
func _ready() -> void:
	
	
	randomize()
	
	$"Skill Panel2".hide()
	$"Skill Panel".hide()
	BattleTransition.animation_player.play("fade_out")
	
	$TextBox.hide()
	$PlayerPanel.hide()
	$ActionsPanel.hide()
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	current_enemy_defense = enemy.defense
	current_enemy_accuracy = enemy.accuracy
	enemy_crit_chance = enemy.crit_chance
	enemy_crit_hit = enemy.damage * 2
	display_text(" %s STOPS YOU IN YOUR TRACKS" % enemy.name)
	await textbox_closed
	$PlayerPanel.show()
	$ActionsPanel.show()
	if State.speed < enemy.speed:
		display_text("%s is faster" % enemy.name)
		await textbox_closed
		enemy_turn()
	
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
	
	

	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $TextBox.visible:
		
		$TextBox.hide()
		emit_signal("textbox_closed")
	if Input.is_action_just_pressed("ui_back") and $"Skill Panel".visible and $"Skill Panel2".visible:
		$"Skill Panel2".hide()
		$"Skill Panel".hide()
func display_text(text):
	$TextBox.show()
	$TextBox/Label.text = text
func set_player_controls():
	$ActionsPanel/Actions/ATTACK.disabled
	$ActionsPanel/Actions/DEFEND.disabled
	$ActionsPanel/Actions/Run.disabled
func _on_run_pressed() -> void:
	$"Skill Panel".hide()
	$"Skill Panel2".hide()
	display_text("Got Away Safely")
	await textbox_closed
	
	TransitionScreen.transition()
	await TransitionScreen.transitioned
	
	get_tree().change_scene_to_file("res://Rooms/game_level.tscn")


func enemy_turn():
	$ActionsPanel.hide()
	await get_tree().create_timer(0.5).timeout
	display_text("%s Launches At You!" % enemy.name)
	await textbox_closed
	if is_defending:
		is_defending = false
		animation_player.play("defense_shake")
		await animation_player.animation_finished
		display_text("You Defended His Attack")
		await textbox_closed
	elif randf() < current_enemy_accuracy:
		display_text("%s swung and missed" % enemy.name)
	elif randf() < enemy_crit_chance:
		display_text("%s 's attack crit and hit for %d damage" % [enemy.name,enemy_crit_hit])
		await textbox_closed
		$SFX/Playerhurt.play()
		current_player_health = max(0, current_player_health - enemy_crit_hit)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("screen_shake")
		await animation_player.animation_finished
		display_text("%s did %d damage" % [enemy.name,enemy_crit_hit])
		await textbox_closed
	else:
		$SFX/Playerhurt.play()
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("screen_shake")
		await animation_player.animation_finished
		display_text("%s did %d damage" % [enemy.name,State.damage])
		await textbox_closed
		
	
	if current_player_health == 0:
		display_text("%s has knocked you out" % enemy.name)
		await textbox_closed
		TransitionScreen.transition()
		await TransitionScreen.transitioned
		get_tree().change_scene_to_file("res://diescreen.tscn")
	$ActionsPanel.show()
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
		
	

func _on_defend_pressed() -> void:
	$"Skill Panel".hide()
	$"Skill Panel2".hide()
	is_defending = true
	display_text("You Drive Your Feet Into the Ground")
	await textbox_closed
	timer.start(0.25)
	
	await timer.timeout
	
	enemy_turn()

func _on_sc_pressed() -> void:
	$"Skill Panel".hide()
	$"Skill Panel2".hide()
	display_text("You Charge at %s" % enemy.name)
	await textbox_closed

	var damage = int(Sc_equation / current_enemy_defense)
	current_enemy_health = max(0, current_enemy_health - damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	$AnimationPlayer.play("enemy_damaged")
	$SFX/EnemyHurt.play()
	display_text("You dealt %d damage" % damage)
	await textbox_closed

	if current_enemy_health == 0:
		animation_player.play("music_fade")
		$ActionsPanel.hide()
		$PlayerPanel.hide()
		display_text("%s Has Been Knocked Out" % enemy.name)
		await textbox_closed

		animation_player.play("enemy_die")
		await animation_player.animation_finished

		display_text("You gained %s exp" % enemy.exp_given)
		await textbox_closed

		TransitionScreen.transition()
		await TransitionScreen.transitioned

		get_tree().change_scene_to_file("res://Rooms/game_level.tscn")
	else:
		enemy_turn()
		
		
		
func _on_intimidate_pressed() -> void:
	$"Skill Panel".hide()
	$"Skill Panel2".hide()
	display_text("You Stand face to face with %s" % enemy.name)
	await textbox_closed
	display_text("%s defense fell" % enemy.name)
	await textbox_closed
	await get_tree().create_timer(0.5).timeout
	current_enemy_defense -= 1
	$ActionsPanel.hide()
	enemy_turn()
