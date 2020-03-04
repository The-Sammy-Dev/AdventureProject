extends HSlider


func _ready() -> void:
	connect("value_changed", self, "_on_value_changed")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("walk"), value)
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("zombie_song"), value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("run"), value)

func _on_value_changed(value : float):
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("zombie_song"), value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("walk"), value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("run"), value)
	
		
