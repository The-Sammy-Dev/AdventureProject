extends KinematicBody2D
# pause is 7
signal game_pause

export var MAGIC: int = 3
export var LIFE: int = 3
export var piece_heart: int = 6
const UP: = Vector2(0, -1)

var magic_texture = [
		"res://Assets/Sprites/nomagic.png",
		"res://Assets/Sprites/onemagic.png",
		"res://Assets/Sprites/twomagics.png",
		"res://Assets/Sprites/fullmagic.png"
		]
var hearth_texture = [ 
		"res://Assets/Sprites/hearth/morto.png",
		"res://Assets/Sprites/hearth/meio.png",
		"res://Assets/Sprites/hearth/1.png",
		"res://Assets/Sprites/hearth/150.png",
		"res://Assets/Sprites/hearth/2.png",
		"res://Assets/Sprites/hearth/275.png",
		"res://Assets/Sprites/hearth/3.png",
		]

onready var stamina_timer: Timer = $CanvasLayer/StaminaBar/CanRun
onready var stamina_bar: = $CanvasLayer/StaminaBar
onready var fireball_position2d = $position_fireball
onready var magic_sprite: = $CanvasLayer/MagicBar
onready var damaged_song: = $sounds/song_damaged
onready var life_sprite: = $CanvasLayer/HearthBar
onready var move_sound: = $sounds/sound_move
onready var position2d: = $Position2D
onready var anim: = $AnimatedSprite
onready var jump_song: = $sounds/jump

onready var PRE_PAUSE = preload("res://Scenes/PauseMenu.tscn")
# Magic
var _can_magic = true
onready var PRE_FIREBALL = preload("res://Scenes/FireBall.tscn")
onready var magic_timer: = $MagicTimer
# Atacking
onready var PRE_ATTACK: = preload("res://Scenes/attack_1.tscn")
var input_attack: = false
var can_attack: = true
var can_air_attack = true # Verificação Se Pode Atacar No Ar e Verificando Se Está Atacando No Ar
var jump_attacking = false # Verificação Se Está Atacando No Ar
# Movement.x and jump
signal input_changed
var run_default_max_vel: = 520 # Limite De Velocidade Max Quando corre
var default_max_velocity: = 300
var acceleration: = 2000
var slowdown: = 1800
var gravity_acceleration: = 4000
var fall_velocity: = 600
var jump_velocity: = -1250
var jump_force_factor: = 4
var input_direction: = Vector2()
var last_input_direction: = Vector2()
var max_current_velocity: = 0.0
var target_velocity: = 0.0
var current_velocity: = Vector2()
var running = false 
var touchable: = true
var jumping = false
var coins: = 00
var elapse_time
var time_start
var _can_move = true
var _can_input_magic = true
var _can_run = true
var _can_charge = true # Stamina Bar


func _ready() -> void:
	randomize()
	
	stamina_timer.connect("timeout", self, "_on_StaminaTimer_timeout")
	magic_timer.connect("timeout", self, "_on_magic_timer_timeout")
	$Player_Damaged_Area.connect("impulse", self, "_on_area_impulse")
	Event.connect("resume_game", self, "_on_Event_resume_game")
	$Player_Damaged_Area.connect("pick_coin", self, "_on_pick_coin")
	$Player_Damaged_Area.add_to_group("player")
	max_current_velocity = default_max_velocity

func _on_magic_timer_timeout():
	_can_input_magic = true
	
func _input(event: InputEvent) -> void:
	
	_fireball()
		
func _on_area_impulse():
	current_velocity.y = jump_velocity

func _process(delta: float) -> void:
	
	if !touchable:
		$Player_Damaged_Area.monitorable = false
		$Player_Damaged_Area.monitoring = false
		$Player_Damaged_Area/CollisionShape2D.disabled = true
	else:
		$Player_Damaged_Area/CollisionShape2D.disabled = false
		$Player_Damaged_Area.monitoring = true
		$Player_Damaged_Area.monitorable = true
		
	if !_can_move : return
		
	if Input.is_action_pressed("input_run"):
		running = true
	else:
		running = false
	
	if input_direction and input_direction != last_input_direction:# n sei pq ta aqui
		emit_signal("input_changed")
	
func _physics_process(delta: float) -> void:
	
	if !_can_move :return
	
	input_direction.x = ( 
				float(Input.is_action_pressed("input_right") ) 
				- float(Input.is_action_pressed("input_left") )
				)
	
	
	sound_move()
	attacking()
	_stamina_bar()
	
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
	if !_can_move : return
	
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
		if Input.is_action_pressed("input_attack") and can_air_attack:
				
				can_air_attack = false
				
				anim.stop()
				anim.play("jump_attack")
				
				var attack_area = PRE_ATTACK.instance()
				
				add_child(attack_area)
				
				attack_area.position = position2d.position
				
				yield(get_tree().create_timer(.7),"timeout")
				
				can_air_attack = true

func v_movement(delta) -> void :
	if !_can_move : return
	
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
				
			if last_input_direction.x == -1 :
				anim.flip_h = true
				
			if can_air_attack:
				anim.play("jump")

	if is_on_ceiling():
		current_velocity.y = 0
	
	var variation = gravity_acceleration * delta
	
	if not jump_input and current_velocity.y < 0 :
		variation = gravity_acceleration * delta * jump_force_factor
		
	current_velocity.y = begin(current_velocity.y, fall_velocity, variation )
	
func h_movement(delta) -> void :
	if !_can_move : return
	
	if input_attack:
		current_velocity.x = 0
		return
		
	if running and _can_run :
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

func knockback(body) -> void :
	var knockback_speed = 1000
	var direction = (global_position - body.global_position).normalized()
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

func on_damaged(body) -> void :
	damaged_song.play()
	knockback(body)
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
	LIFE -= 1
	$sounds/dead_sound.play()
	if is_in_group("player"):
		remove_from_group("player")
	anim.play("dead")
	_can_move = false
	if move_sound.playing :
		move_sound.stop()
	#TODO Instanciar um menu
	# Emitir um sinal

		
func _on_Event_resume_game():
	pass
	
func _stamina_bar():
	
	if Input.is_action_pressed("input_run"):
		if stamina_bar.value <= 5 :
			stamina_bar.self_modulate = Color(1, 1, 0)
			if stamina_bar.value <= 2 :
				_can_run = false
				_can_charge = false
				stamina_timer.start()
		if _can_run:
			stamina_bar.value -= 1
	else:
		if !_can_charge : return
		stamina_bar.value += .3
		
func _on_StaminaTimer_timeout():
	_can_run = true
	_can_charge = true
#	if _can_charge:
#		stamina_bar.value += .3
#	if stamina_bar.value <= 1 :
#		stamina_bar.value == 0
#		default_max_velocity = 150
#		_can_charge = false
#		_can_run = false
#
#		stamina_bar.modulate = Color(1, 1, 0)
#		yield(get_tree().create_timer(5), "timeout")
#
#		default_max_velocity = 300
#		run_default_max_vel = 520
#		stamina_bar.modulate = Color(1, 1, 1)
#		_can_charge = true
#		_can_run = true
#	if current_velocity.x != 0 and running :
#		if _can_run:
#			print("ṕpode correr")
#			stamina_bar.value -= 1
	
func _fireball():
	if !is_on_floor(): return
	
	if last_input_direction.x == 1 :
		fireball_position2d.position = Vector2(90, 0)
	if last_input_direction.x == -1 :
		fireball_position2d.position = Vector2(-90, 0)
	
	var fireball_medium_scale = 600
	var fireball_max_scale = 900
	
	if !_can_input_magic : return
	
	if MAGIC >= 1 :
		if Input.is_action_pressed("input_magic"):
			anim.play("init_fire_attack")
			_can_move = false
			$Particles2D.emitting = true
			if Input.is_action_just_pressed("input_magic"):
				time_start = OS.get_ticks_msec()
				$Particles2D/PressedTimer.start(.1)
				 
		if Input.is_action_just_released("input_magic") and _can_magic :
			$Particles2D.scale = Vector2(1, 1)
			$Particles2D/PressedTimer.stop()
			$Particles2D.emitting = false
			_can_magic = false
			_can_input_magic = false
			elapse_time = OS.get_ticks_msec() - time_start
			anim.play("end_fire_attack")
	
			yield(get_tree().create_timer(.2),"timeout")
	
			var fireball = PRE_FIREBALL.instance()
			get_parent().add_child(fireball)
			fireball.global_position = fireball_position2d.global_position
			print(elapse_time)
			
			if elapse_time >= fireball_max_scale and MAGIC > 1 :
				fireball.scale.x =+ abs(3.1)
				fireball.scale.y =+ abs(3.1)
				MAGIC -= 2
				_change_texture(MAGIC, magic_sprite, magic_texture)
				print("max")
			
			elif elapse_time > fireball_medium_scale and elapse_time < fireball_max_scale and MAGIC > 1 :
				fireball.scale.x =+ abs(1.7)
				fireball.scale.y =+ abs(1.7)
				MAGIC -= 2
				_change_texture(MAGIC, magic_sprite, magic_texture)
				print("medium")
			
			else :
				fireball.scale.y =+ abs(1)
				fireball.scale.y =+ abs(1)
				MAGIC -= 1
				_change_texture(MAGIC, magic_sprite, magic_texture)
				print("small")
			
				
			yield(anim, "animation_finished")
			
			_can_move = true
	
			yield(get_tree().create_timer(1),"timeout")
			_can_magic = true
			magic_timer.start()

func _change_texture(ammount : int, node_sprite : Sprite, node_texture: Array):
	node_sprite.texture = load(node_texture[ammount])
	
	
