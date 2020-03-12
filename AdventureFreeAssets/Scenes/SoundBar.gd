extends HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("value_changed", self, "_on_value_changed")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	pass # Replace with function body.

func _on_value_changed(value : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
