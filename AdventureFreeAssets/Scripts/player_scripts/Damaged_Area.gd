extends Area2D

func _ready():
	connect("area_entered", self, "_on_damageplayer_area_entered")
	pass

func _on_damageplayer_area_entered(area):
	if get_parent().has_method("on_damaged"):
		get_parent().on_damaged(area)
