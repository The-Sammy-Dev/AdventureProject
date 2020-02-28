extends Area2D

var nothing_area = true

onready var no_hit_sound: = $Sounds/NO_HIT
onready var attacking_zombie_song: = $Sounds/ATTACK_ZOMBIE
onready var area_attack: = $CollisionShape2D
onready var timer: = $Timer

func _ready():
	add_to_group("player_attack")
	$CollisionShape2D.add_to_group("player_attack")
	connect("area_entered", self, "_on_area_entered")
	
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()

func _process(delta: float) -> void:
	
	if nothing_area:
		if !no_hit_sound.is_playing():
			no_hit_sound.play()
			
	else:
		no_hit_sound.stop()

func _on_area_entered(area):
	nothing_area = false
	
	if area.get_parent().is_in_group("zombie"):
		attacking_zombie_song.play()
	
func _on_timer_timeout():
	queue_free()
	
