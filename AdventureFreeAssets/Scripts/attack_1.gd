extends Area2D

signal attacked

onready var area_attack: = $CollisionShape2D
onready var timer: = $Timer

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	
func _on_timer_timeout():
	queue_free()


