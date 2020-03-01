extends KinematicBody2D

export var piece_heart: int = 6

const UP: = Vector2(0, -1)

var hearth_texture = [ 
		"res://Assets/Sprites/hearth/morto.png",
		"res://Assets/Sprites/hearth/meio.png",
		"res://Assets/Sprites/hearth/1.png",
		"res://Assets/Sprites/hearth/150.png",
		"res://Assets/Sprites/hearth/2.png",
		"res://Assets/Sprites/hearth/275.png",
		"res://Assets/Sprites/hearth/3.png",
		]

# Lembre-se de colocar as ações nas config do projeto se não não funcionará
onready var damaged_song: = $sounds/song_damaged
onready var life_sprite: = $CanvasLayer/HearthBar
onready var move_sound: = $sounds/sound_move
onready var position2d: = $Position2D
onready var anim: = $AnimatedSprite
onready var jump_song: = $sounds/jump
# Atacking
onready var PRE_ATTACK: = preload("res://Scenes/attack_1.tscn")
var input_attack: = false
var can_attack: = true
# Movement.x and jump
signal input_changed
# TESTE
var run_default_max_vel: = 400
var jump_attacking = false

var default_max_velocity: = 200
var acceleration: = 2000
var slowdown: = 1800
var gravity_acceleration: = 4000
var fall_velocity: = 600
var jump_velocity: = -1250
var jump_force_factor: = 4

#var jump_input: = false
var input_direction: = Vector2()
var last_input_direction: = Vector2()

var max_current_velocity: = 0.0
var target_velocity: = 0.0
var current_velocity: = Vector2()

var dead: bool = false

var running = false
var touchable: = true

var jumping = false

var coins: = 00

func _ready() -> void:
	randomize()
	
	$Player_Damaged_Area.connect("pick_coin", self, "_on_pick_coin")
	$Player_Damaged_Area.add_to_group("player")
	max_current_velocity = default_max_velocity
	
func _process(delta: float) -> void:
	if !touchable:
		$Player_Damaged_Area.monitorable = false
		$Player_Damaged_Area.monitoring = false
		$Player_Damaged_Area/CollisionShape2D.disabled = true
	else:
		$Player_Damaged_Area/CollisionShape2D.disabled = false
		$Player_Damaged_Area.monitoring = true
		$Player_Damaged_Area.monitorable = true
		
	if dead: return
		
	if Input.is_action_pressed("input_run"):
		running = true
	else:
		running = false
	
	if input_direction and input_direction != last_input_direction:# n sei pq ta aqui
		emit_signal("input_changed")
	
func _physics_process(delta: float) -> void:
	
	if dead:return
	
	input_direction.x = ( 
				float(Input.is_action_pressed("input_right") ) 
				- float(Input.is_action_pressed("input_left") )
				)
	
	attacking()
	
	sound_move()
	
	h_movement(delta)
	v_movement(delta)
	
	move_and_slide(current_velocity, UP)
	
func _on_pick_coin() -> void :
	coins += 01
	$CanvasLayer/Panel/Label.text = coins as String

func _pick_life(ammount: int):
	
	if piece_heart < 6 :
		piece_heart += ammount
		if piece_heart >= 7 :
			piece_heart = 6
		life_sprite.texture = load(hearth_texture[piece_heart])
		update()
		
func attacking() -> void :
	
	if last_input_direction.x == 1 :
		position2d.position = Vector2(50, 0)
	if last_input_direction.x == -1 :
		position2d.position = Vector2(-50, 0)
	
	if Input.is_action_pressed("input_attack") and is_on_floor() and can_attack:
		
		can_attack = false
		input_attack = true
		anim.play("attack")
		yield(get_tree().create_timer(.1), "timeout")
		
		var attack_area = PRE_ATTACK.instance()
		add_child(attack_area)
		attack_area.position = position2d.position
		
		yield(anim, "animation_finished")
		
		input_attack = false
		
		yield(get_tree().create_timer(.5),"timeout")
		
		can_attack = true
	
	if !is_on_floor(): # Jump Attack
		if Input.is_action_pressed("input_attack") and can_attack:
				
				can_attack = false
				jump_attacking = true
				
				anim.stop()
				anim.play("jump_attack")
				
				var attack_area = PRE_ATTACK.instance()
				
				add_child(attack_area)
				
				attack_area.position = position2d.position
				
				yield(anim,"animation_finished")
				
				jump_attacking = false
				
				yield(get_tree().create_timer(1),"timeout")
				
				can_attack = true

func v_movement(delta) -> void :
	
	var jump_input = int(Input.is_action_pressed("input_jump"))
	var jump_pressed = int(Input.is_action_just_pressed("input_jump"))
	var jump_released = int(Input.is_action_just_released("input_jump"))
	var smooth_factor = 0.5
	
	if jump_input:
		jumping = true
	
	if is_on_floor():
		jumping = false
	
	if not input_attack :
		if is_on_floor() :
			current_velocity.y = 0
			if jump_pressed and !jumping :
				jump_song.play()
				current_velocity.y = jump_velocity
			elif jump_released and current_velocity.y < 0 :
				current_velocity.y *= smooth_factor
			
		else:
			
			if last_input_direction.x == 1 :
				anim.flip_h = false
				
				if !jump_attacking:
					anim.play("jump")
				
			if last_input_direction.x == -1 :
				anim.flip_h = true
				
				if !jump_attacking:
					anim.play("jump")
		
	
	if is_on_ceiling():
		current_velocity.y = 0
	
	var variation = gravity_acceleration * delta
	
	if not jump_input and current_velocity.y < 0 :
		variation = gravity_acceleration * delta * jump_force_factor
		
	current_velocity.y = begin(current_velocity.y, fall_velocity, variation )
	
func h_movement(delta) -> void :
	
	if input_attack:
		current_velocity.x = 0
		return
		
	if running :
			
		if input_direction :
			last_input_direction = input_direction

			if target_velocity != run_default_max_vel:
				target_velocity = run_default_max_vel
		else:
			target_velocity = 0

		var variation = slowdown * delta

		if input_direction:
			variation = acceleration * delta

		current_velocity.x = (
					begin(current_velocity.x,
					 target_velocity * 
					input_direction.x,
					 variation )
					)
		if input_direction.x == 0 and not input_attack and is_on_floor() :
			anim.play("idle")
			current_velocity.x = 0
			
		if input_direction.x < 0 and is_on_floor() :
			anim.flip_h = true
			anim.play("run")
			
		elif input_direction.x > 0 and is_on_floor() :
			anim.flip_h = false
			anim.play("run")
			
	else:
		if input_direction.x == 0 and not input_attack and is_on_floor() :
			anim.play("idle")
			current_velocity.x = 0
		
		if input_direction.x < 0 and is_on_floor() :
			anim.flip_h = true
			anim.play("walking")
			
		elif input_direction.x > 0 and is_on_floor() :
			anim.flip_h = false
			anim.play("walking")
		
		if input_direction :
			last_input_direction = input_direction
	
			if target_velocity != max_current_velocity:
				target_velocity = max_current_velocity
		else:
			target_velocity = 0
	
		var variation = slowdown * delta
	
		if input_direction:
			variation = acceleration * delta

		current_velocity.x = (
					begin(current_velocity.x,
					 target_velocity * 
					input_direction.x,
					 variation )
					)
	
func begin(current_val, target_val, variation) -> float :
	var difference = target_val - current_val
	
	if difference > variation :
		return current_val + variation
	
	if difference < -variation :
		return current_val - variation
	
	return target_val

func knockback(area) -> void :
	var knockback_speed = 1000
	var direction = (global_position - area.global_position).normalized()
	current_velocity = direction * knockback_speed
	
func _damaged(node: AnimatedSprite ):
	
	touchable = false
	
	node.modulate = Color(1, 0, 0, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 0)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 0)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 0)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(.3),"timeout")
	touchable = true

func on_damaged(area) -> void :
	damaged_song.play()
	knockback(area)
	_damaged(anim)
	
	piece_heart -= 1
	life_sprite.texture = load(hearth_texture[piece_heart])
	update()
	
	if piece_heart <= 0:
		_died()
	
func sound_move():
	if Input.is_action_pressed("input_left") and Input.is_action_pressed("input_right"): 
		move_sound.stop()
	else:
		if Input.is_action_pressed("input_right") or Input.is_action_pressed("input_left"):
			if running:
				if is_on_floor():
					move_sound.pitch_scale = .9
					move_sound.bus = "run"
					if !move_sound.playing:
						move_sound.play() 
				else:
					move_sound.stop()
			else:
				if is_on_floor():
					move_sound.pitch_scale = .5
					move_sound.bus = "walk"
					if !move_sound.playing:
						move_sound.play() 
				else:
					move_sound.stop()
		else:
			move_sound.stop()
	
func _died():
	$sounds/dead_sound.play()
	if is_in_group("player"):
		remove_from_group("player")
	anim.play("dead")
	dead = true
	if move_sound.playing :
		move_sound.stop()
	#TODO Instanciar um menu
