extends Node2D

func _ready():
	_startGame()
	
func _on_game_over():
	# se tiver algum player vivo limpa da memória
	for p in get_tree().get_nodes_in_group("player"):
		p.queue_free()
	# restart no game**
	_startGame()
	
func _startGame():
	var player = load("res://Scenes/Player.tscn").instance()
	player.global_position = $spawn.position
	player.connect("gameover", self, "_on_game_over")
	self.add_child(player)
