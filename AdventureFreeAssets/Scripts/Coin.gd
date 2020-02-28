extends RigidBody2D
#Stay faz ela ficar parada
var UP = Vector2(0, -1)
var direction = Vector2(0, 0)
export var _Damp: float = 1.9
export var _bounce: = 100
export var _stay : bool 
export var _GravityScale: = 10
export var _Apply_impulse: Vector2 = Vector2(0, -10)
var touchable: bool = true

onready var _area: = $Area2D
onready var shape_coin: = $CollisionShape2D
onready var area_shape: = $Area2D/CollisionShape2D

var initialPos = Vector2.ZERO

func _ready():
	initialPos = self.global_position
	add_to_group("coin")
	
#	if !_stay:
#		apply_central_impulse(_Apply_impulse)
	#$Area2D.connect("area_entered", self, "_on_area_entered")
	$Area2D.connect("body_entered", self, "_on_area2d_body_entered")
#	if !$fall.playing :
#		$fall.play()
	$Area2D/Anim.play("idle")
	$del.connect("timeout", self, "_on_del_timeout")
	
	
	
	physics_material_override.bounce = _bounce
	linear_damp = _Damp
	gravity_scale = _GravityScale
	
	if _stay:
		sleeping = true
	
func _on_del_timeout() -> void :
	queue_free()

func _process(delta: float) -> void:
	if !touchable:
		pass

# O player é um body e não uma area
#func _on_area_entered(area):
#	if area.is_in_group("player"):
#		if !$pick_up.playing :
#			$pick_up.play()
#		print("player colidiu")
#		$fall.stop()
#		touchable = false
#		$del.start()
#		$Area2D/Anim.visible = false
#	else: 
#		return

func _integrate_forces(state):
	# pra ela parar de rotacionar e ficar sempre no meio, como é um rigidbody
	# se algo bater ela vai saltar pra outro lugar rotacionando
	# toda vez que for alterar a física de um rigidbody precisa ser no _integrate_forces e não no _process ou _physics_process
	state.angular_velocity = 0
	

# o player é um body, então precisa ser nesse sinal de body entered
func _on_area2d_body_entered(body):
	if body.is_in_group("player"):
		if !$pick_up.is_playing():
			$pick_up.play()
		print("player colidiu")
		$fall.stop()
		touchable = false
		$del.start()
		$Area2D/Anim.visible = false
