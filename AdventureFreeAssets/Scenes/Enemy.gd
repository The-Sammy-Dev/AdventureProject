extends KinematicBody2D

var touchable: = true

onready var timer_stop: = $Timer_Stop
onready var timer_song: = $Timer
onready var shape_damage: = $Damage/CollisionShape2D
onready var shape_damaged: = $Damaged/CollisionShape2D
onready var damage_area: = $Damage
onready var anim: = $AnimatedSprite
onready var damaged_area: = $Damaged
export var life: = 4

var UP: = Vector2(0, -1)
var _direction: = Vector2(0, 0)
var zombie_dead: = false
var gravity: = 600
var right_move: = true
var can_move: = true
var speed: float = 100.0
var direction: = Vector2(1, 0)

export var lenght: = int(0)
var final_position: = Vector2(int(200),int(0) )
var initial_position: = Vector2(0 ,0)

var auto_follow: PathFollow2D = null
var dir_follow: int = 1
export var velocity_follow: float = 0.2


func _ready():
	
	var test_follow = get_parent()
	
	if test_follow is PathFollow2D :
		auto_follow = test_follow
	
	final_position.x = get_position().x + lenght
	
	randomize()
	
	add_to_group("zombie")
	update()
	
	damaged_area.connect("area_entered", self, "on_area_damaged_entered")
	
	timer_stop.connect("timeout", self,"_on_timer_stop_timeout")
	timer_song.connect("timeout",self, "_on_timer_song_timeout")
	
	timer_song.start()
	timer_stop.start()
	
	initial_position = get_position()
	
func on_area_damaged_entered(area) :
	
	if zombie_dead:
		can_move = false
		return
	
	life -= 1
	
	if life > 0:
		damaged(anim)
	if life <= 0 :
		zombie_dead = true
		dead()
		touchable = false
	
func _on_timer_stop_timeout():
	if zombie_dead:
		timer_stop.stop()
	var rand_generator = RandomNumberGenerator.new()
	rand_generator.randomize()
	timer_stop.wait_time = rand_generator.randi_range(6, 13) 
	can_move = false
	
	yield(get_tree().create_timer(4),"timeout")
	
	timer_stop.start()
	can_move = true
	
func _on_timer_song_timeout() :
	if zombie_dead:
		timer_song.stop()
		return
	
	var songs_idle = $Songs.get_children()
	var song = songs_idle[randi() % songs_idle.size() ] 
	if weakref(song).get_ref():
		song.play()
	timer_song.start()


		
func _physics_process(delta: float) -> void:
	
	if auto_follow:
		auto_follow.unit_offset += (velocity_follow * dir_follow) * delta
		anim.play("walking")
	
		
	
	if auto_follow.unit_offset == 0.0 :
		dir_follow = 1
	if auto_follow.unit_offset == 1.0 :
		dir_follow = -1
	
	
	if !touchable :
		shape_damage.disabled = true
		shape_damaged.disabled = true
		
	if life <= 0:
		dead()
		
	if !is_on_floor():
		direction.y = 50
		
	move_and_slide(direction, UP) * delta
	
	
func h_enemy_move() :
	
	if !zombie_dead:
	
		if can_move :
			if right_move:
				direction.x = 1
				anim.flip_h = false
				anim.play("walking")
				
			else:
				anim.flip_h = true
				anim.play("walking")
				direction.x = -1
			
			if position.x >= final_position.x :
				right_move = false
			
			if position.x <= initial_position.x :
				right_move = true
		else:
			direction.x = 0
			anim.play("idle")
			
	else:
		direction.x = 0
		
func v_enemy_move(): # Se no futuro existir um inimigo voador,
						  # copie a função h_enemy_move() e altere o direction.x por .y
	direction.y = gravity
	
func damaged(node: AnimatedSprite ):
	
	node.modulate = Color(1, 0, 0, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 0, 0, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 0, 0, 1)
	yield(get_tree().create_timer(.1),"timeout")
	node.modulate = Color(1, 1, 1, 1)

func dead():
	dir_follow = 0
	anim.stop()
	anim.play("dead")
	anim.position.y = -8
	can_move = false
	yield(anim,"animation_finished")
	
	var tween = Tween.new()
	add_child(tween)
	
	yield(get_tree().create_timer(5),"timeout")
	
	tween.interpolate_method(self, "fade", Color(1 ,1 ,1 ,1), Color(1, 1, 1, 0), .5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()
	
	#toque algum som TODO1
func fade(val):
	modulate = val

func play_and_wait_song(song: AudioStreamPlayer2D):
	pass
