extends Node2D

onready var spawn_local: = $Spawn
var preload_player: = preload("res://Scenes/Player.tscn")


func _ready():
	var player = preload_player.instance()
	player.global_position = spawn_local.position
	self.add_child(player)
	
	pass
	
	
func _on_game_over():
	pass
