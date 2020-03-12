extends CheckBox

func _ready():
	connect("pressed", self, "_on_FullScreen_button_pressed")
	pass


func _on_FullScreen_button_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
