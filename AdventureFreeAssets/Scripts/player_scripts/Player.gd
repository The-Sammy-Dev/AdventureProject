extends KinematicBody2D

export var LIFE: = 6

const UP: = Vector2(0, -1)
const DEAD_ZONE = 0.03

# TODO Fazer animação de ataque_pulo e fazer o attack ficar mais suave, criar animação de dano do personagem, empurrar o zombie quando atacado, anim ataque zombie
 
# Lembre-se de colocar as ações nas config do projeto se não não funcionará
onready var wait_for_attack_timer: = $WaitForAttack
onready var position2d: = $Position2D
onready var anim: = $AnimatedSprite
# Atacking
onready var PRE_ATTACK: = preload("res://Scenes/attack_1.tscn")
var input_attack: = false
var can_attack: = true
# Movement.x and jump
signal input_changed

# TESTE
var run_default_max_vel: = 400


var default_max_velocity: = 200
var acceleration: = 2000
var slowdown: = 1800
var gravity_acceleration: = 4000
var fall_velocity: = 600
var jump_velocity: = -1100
var jump_force_factor: = 4

var jump_input: = false
var input_direction: = Vector2()
var last_input_direction: = Vector2()

var max_current_velocity: = 0.0
var target_velocity: = 0.0

var current_velocity: = Vector2()

var running = false

func _ready() -> void:
	Event.connect("player_collide_on_enemy", self, "_on_player_collide_on_enemy")
	max_current_velocity = default_max_velocity
	input_direction.x == 0
	wait_for_attack_timer.connect("timeout", self, "_on_wait_for_attack_timer_timeout")
	
func _on_player_collide_on_enemy():
	LIFE -= 1
	print(LIFE)
	damaged(anim)
	print(anim.modulate)
	
func _physics_process(delta: float) -> void:
	
	
	if Input.is_action_pressed("input_run"):
		running = true
	else:
		running = false
	
	input_direction.x = ( 
				float(Input.is_action_pressed("input_right") ) 
				- float(Input.is_action_pressed("input_left") )
				)
	
	jump_input = Input.is_action_pressed("input_jump")
	
	if input_direction and input_direction != last_input_direction:
		emit_signal("input_changed")
	
	if Input.is_action_pressed("input_attack") and is_on_floor() and can_attack:
		wait_for_attack_timer.start()
		can_attack = false
		if last_input_direction.x == 1 :
			position2d.position = Vector2(50, 0)
			attacking()
		if last_input_direction.x == -1 :
			position2d.position = Vector2(-50, 0)
			attacking()
	
#	if input_direction.x == 0 :
#		joystick_h_movement(delta) # Eu havia criado uma func para o joystick porem é desnecessauro pois
# 									na aba input_map da pra configurar lá <3
		
	h_movement(delta)
	
	v_movement(delta)
	
	move_and_slide(current_velocity, UP)
	
func attacking() -> void :
	input_attack = true
	anim.play("attack")
	
	yield(get_tree().create_timer(.1), "timeout")
	
	var attack_area = PRE_ATTACK.instance()
	add_child(attack_area)
	attack_area.position = position2d.position
	
	yield(anim, "animation_finished")
	
	input_attack = false

func v_movement(delta) -> void :
	
	if not input_attack:
		if is_on_floor() :
			current_velocity.y = 0
			
			if jump_input :
				current_velocity.y = jump_velocity
		else:
			if last_input_direction.x == 1 :
				anim.flip_h = false
				anim.play("jump")
			if last_input_direction.x == -1 :
				anim.flip_h = true
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

func _on_wait_for_attack_timer_timeout():
	can_attack = true

func damaged(node: AnimatedSprite ):
	if last_input_direction.x >= 0 :
		move_local_x(-150)
	if last_input_direction.x <= 0 :
		move_local_x(150)
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


