extends KinematicBody2D

signal dead

onready var PRE_COIN = preload("res://Scenes/Coin.tscn")

var touchable: = true
export var MaxSoundDist = int(500)

onready var timer_song: = $Timer
onready var shape_damage: = $Damage/CollisionShape2D
onready var damage_area: = $Damage
onready var anim: = $AnimatedSprite
export var life: = 1

var UP: = Vector2(0, -1)
var can_move: = true
var direction: = Vector2(0, 0)

var auto_follow: PathFollow2D = null
var dir_follow: int = 1
export var velocity_follow: float = 0.2
var stopAutoFollow: bool = false
#var coin
var area_entered: Area2D
var instance_coin = false
func _ready():
	randomize()
	
	$Idle_sounds/idle_song1.max_distance = MaxSoundDist
	$Idle_sounds/idle_song2.max_distance = MaxSoundDist
	$Idle_sounds/idle_song3.max_distance = MaxSoundDist
	
	var test_follow = get_parent()
	if test_follow is PathFollow2D :
		auto_follow = test_follow
	
	add_to_group("zombie")
	update()
	
	damage_area.connect("area_exited", self, "_on_area_damage_exit")
	damage_area.connect("area_entered", self, "_on_damage_area_entered")
	
	timer_song.connect("timeout",self, "_on_timer_song_timeout")
	timer_song.start()
	
func _on_area_damage_exit(area):
	if stopAutoFollow : 
		return
	
	if area.is_in_group("player"):
		area_entered = null
		stopAutoFollow = false
	
func _on_damage_area_entered(area):
	
	if stopAutoFollow:
		return
	
	if weakref(area_entered).get_ref():
		var dir: float = area_entered.global_position.x - self.global_position.x
		anim.flip_h = dir < 0
	
	if area.is_in_group("player") :
		stopAutoFollow = true
		anim.play("attack") 
		print("plater")
		area_entered = area
		$SoundsEffects/atk_sound.play()
		var area_entered = area
		
		yield(get_tree().create_timer(1),"timeout")
		stopAutoFollow = false
	
	if area.is_in_group("player_attack"):
		print("playeratk")
		life -= 1
		
		if life > 0:
			damaged(anim)
		
		if life <= 0 :
			$SoundsEffects/dead_song.play()
			dead()
			
func _process(delta: float) -> void:
#	if stopAutoFollow : 
#		return
	if !touchable :
		$Damage/CollisionShape2D.disabled = true
	
func _physics_process(delta: float) -> void:
	if stopAutoFollow : 
		return
	
	if auto_follow:
		anim.flip_h = dir_follow > 0 
		auto_follow.unit_offset += (velocity_follow * dir_follow) * delta
		anim.play("walking")
		
		if auto_follow.unit_offset == 0.0 :
			dir_follow = 1
		if auto_follow.unit_offset == 1.0 :
			dir_follow = -1
		
	if !is_on_floor():
		direction.y = 50
		
	move_and_slide(direction, UP) * delta

func _on_timer_song_timeout() :
	
	if stopAutoFollow:
		return
	
	var Idle_sounds_idle = $Idle_sounds.get_children()
	var song = Idle_sounds_idle[randi() % Idle_sounds_idle.size() ] 
	var rand_generator = RandomNumberGenerator.new()
	rand_generator.randomize()
	
	if weakref(song).get_ref():
		if !song.playing :
			song.play()
	timer_song.start()
	
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

func fade(val):
	modulate = val

func dead():
	
	touchable = false
	Event.emit_signal("dead", global_position)
#	emit_signal("dead", global_position)
	stopAutoFollow = true
	anim.play("dead")
	anim.position.y = -8
	
	yield(anim,"animation_finished")
	var tween = Tween.new()
	add_child(tween)
	
	yield(get_tree().create_timer(3),"timeout")
	
	tween.interpolate_method(self, "fade", Color(1 ,1 ,1 ,1), Color(1, 1, 1, 0), .5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()
	yield(tween, "tween_completed")
	
	queue_free()
	
	#toque algum som TODO1