extends RigidBody2D

onready var anim : AnimatedSprite = $Anim
onready var _area: Area2D = $Area2D

var auto_follow: PathFollow2D = null
var dir_follow: int = 1
var stopAutoFollow

export var velocity_follow: float = 0.4
export var life = 1

func _ready():
	_area.connect("area_entered", self, "_on_area_entered")
	_area.connect("body_entered", self, "_on_body_entered")
	add_to_group("monster")
	
	var test_follow = get_parent()
	if test_follow is PathFollow2D :
		auto_follow = test_follow

func _on_body_entered(body):
	if body.is_in_group("player"):
		death()
		
func _on_area_entered(area):
	if area.is_in_group("player_attack"):
		death()
	
func _physics_process(delta: float) -> void:
	if stopAutoFollow : 
		return
	
	if auto_follow:
		anim.flip_h = dir_follow < 0 
		auto_follow.unit_offset += (velocity_follow * dir_follow) * delta
		anim.play("fly")
		
		if auto_follow.unit_offset == 0.0 :
			dir_follow = 1
		if auto_follow.unit_offset == 1.0 :
			dir_follow = -1
	
func death():
	queue_free()
