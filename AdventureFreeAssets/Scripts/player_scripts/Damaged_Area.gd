extends Area2D

signal pick_coin

func _ready():
	connect("area_entered", self, "_on_damageplayer_area_entered")
	pass

func _on_damageplayer_area_entered(area):
	if area.get_parent().is_in_group("zombie") :
		if !get_parent().dead :
			if get_parent().has_method("on_damaged"):
				get_parent().on_damaged(area)
	if area.get_parent().is_in_group("coin") or area.is_in_group("coin"):
		emit_signal("pick_coin")
	
