extends CharacterBody2D
@export var speed : int = 100
@onready var area_2d: Area2D = $Area2D

var steps_taken = 0
var encounter_chance = 0.08
var tilesize = 32
var distance_moved = 0



#var move_input : Vector2 = Vector2
@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
func _ready() -> void:
	update_animation_parameters(starting_direction)
	randomize()

func _physics_process(delta: float) -> void:
	var direction = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
	Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	
	update_animation_parameters(direction)
	
	
	velocity = direction * speed
	if direction.length() > 0:
		direction = direction.normalized()
		
		
	if direction.length() == 0:
		velocity = velocity.move_toward( Vector2.ZERO , speed)
		
	
	
	
	
	move_and_slide()
	var moved_distance = velocity.length() * delta
	distance_moved += moved_distance
	
	if distance_moved >= tilesize:
		distance_moved -= tilesize
		steps_taken += 1
		
		print("Step: ", steps_taken)
		check_for_encounter()
	switch_states()
	
	
func check_for_encounter():
	if randf() < encounter_chance and steps_taken > 8:
		trigger_encounter()
		
func trigger_encounter():
	speed = 0
	BattleTransition.battle_transition()
	
	await BattleTransition.transitioned_to_battle
	
	get_tree().change_scene_to_file("res://Battle/battle.tscn")
	
	
func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		
		
		
func switch_states():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
