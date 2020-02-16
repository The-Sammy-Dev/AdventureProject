extends Area2D

func _ready():
	connect("area_entered", self, "_on_area_entered")

func _on_area_entered(area):
	Event.emit_signal("player_attack")
