extends Node2D
# Usar esse script para todas as fases (se n for alterar nada grande)
onready var spawn_local: = $Spawn
var preload_player: = preload("res://Scenes/Player.tscn")
var PRE_COIN = preload("res://Scenes/Coin.tscn")
var zombie = false
func _ready():
	$Path2D/PathFollow2D/Zombie.connect("dead", self, "_dead_zombie")
#	for z in get_tree().get_nodes_in_group("zombie"):
	
#	Event.connect("dead", self ,"_on_mob_dead")
	for z in get_tree().get_nodes_in_group("zombie") :
		z.connect("dead", self, "_on_zombie_dead")
#

	var player = preload_player.instance()
	player.global_position = spawn_local.position
	self.add_child(player)
	
	
func _on_game_over():
	pass

#func _on_mob_dead(_position):
#	var coin = PRE_COIN.instance()
#	call_deferred("add_child", coin)
#	coin.global_position = _position
#	print("zombiemorreu")
func _on_zombie_dead(_position):
	print("zombie dieee")
