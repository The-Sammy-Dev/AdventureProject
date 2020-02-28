extends Node2D
# Usar esse script para todas as fases (se n for alterar nada grande)
onready var spawn_local: = $Spawn
var preload_player: = preload("res://Scenes/Player.tscn")
onready var PRE_COIN = preload("res://Scenes/Coin.tscn")
var zombie = false
func _ready():
	randomize()
	$Path2D/PathFollow2D/Zombie.connect("dead", self, "_dead_zombie")
#	for z in get_tree().get_nodes_in_group("zombie"):
	
#	Event.connect("dead", self ,"_on_mob_dead")
	for z in get_tree().get_nodes_in_group("zombie"):
		z.connect("is_died", self, "_on_zombie_dead")
#

	var player = preload_player.instance()
	player.global_position = spawn_local.position
	self.add_child(player)
	
	# Se quiser dropar as moedas dinamicamente
	for i in range(3):
		var coin = PRE_COIN.instance()
		add_child(coin) # esse precisa ficar antes de setar a posição abaixo
		coin.global_position = spawn_local.global_position + Vector2(300 + (90 * i), -50)
		#coin.apply_impulse(Vector2.ZERO, Vector2(150,-250))
	
	
func _on_game_over():
	pass

#func _on_mob_dead(_position):
#	var coin = PRE_COIN.instance()
#	call_deferred("add_child", coin)
#	coin.global_position = _position
#	print("zombiemorreu")
func _on_zombie_dead(_position, _totalCoin = 1):
	print("zombie dieee", _position)

	# coloquei mais esse parametro, e em cada zombie, você pode configurar quantas
	# moedas ele da,.. desde 0 até quanto vc quiser
	for i in range(_totalCoin):
		var coin = PRE_COIN.instance()
		add_child(coin) # esse precisa ficar antes de setar a posição abaixo
		coin.global_position = _position
		
		# coloquei isso se você quiser dar um empurrão aleatório nas moedas quando elas nascem
		coin.apply_impulse(Vector2.ZERO, Vector2(150 + randi()%200, -250 - randi()%500))
		yield(get_tree().create_timer(randf() / 10), "timeout")

