extends Area2D

func _ready():
	connect("area_entered", self, "_on_damageplayer_area_entered")
	pass
func _on_damageplayer_area_entered(area):
	Event.emit_signal("player_collide_on_enemy")
