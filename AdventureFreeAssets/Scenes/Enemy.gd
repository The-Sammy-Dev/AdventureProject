extends KinematicBody2D

#var songs_idle = [get_node("Songs/idle_song1"),
#		 get_node("Songs/idle_song2"),
#		get_node("Songs/idle_song3") ]

onready var timer_song: = $Timer
onready var shape_damage: = $Damage/CollisionShape2D
onready var shape_damaged: = $Damaged/CollisionShape2D

onready var anim: = $AnimatedSprite

export var life: = 4

var UP: = Vector2(0, -1)

var gravity: = 600
var right_move: = true
var can_move: = true
var speed: float = 100.0
var direction: = Vector2(1, 0)

export var final_position: = Vector2(int(200),int(0) )
export var initial_position: = Vector2(0 ,0)

func _ready():
	randomize()
	Event.connect("player_attack", self ,"_on_player_attack")
	timer_song.connect("timeout",self, "_on_timer_song_timeout")
	
	timer_song.start()
	
	initial_position = get_position()
	
func _on_timer_song_timeout() :
	var songs_idle = $Songs.get_children()
	var song = songs_idle[randi() % songs_idle.size() ] 
	if weakref(song).get_ref():
		song.play()
	timer_song.start()

func _on_player_attack():
	life -= 1
	print(life)
	if life > 0:
		damaged(anim)

func _physics_process(delta: float) -> void:
	
	if life <= 0:
		dead(anim)
		
	h_enemy_move()
	v_enemy_move()
	
	move_and_slide(direction * speed, UP) * delta  
	
func h_enemy_move() :
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
		
func v_enemy_move(): # Se no futuro existir um inimigo voador,
						  # copie a função h_enemy_move() e altere o direction.x por .y
	direction.y = gravity
	
func damaged(node: AnimatedSprite ):
	if direction.x >= 0 :
		move_local_x(-150)
	if direction.x <= 0 :
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

func dead(anim):
	anim.play("dead")
	can_move = false
	shape_damage.disabled = true
	shape_damaged.disabled = true
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
