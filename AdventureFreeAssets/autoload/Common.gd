extends Node

func _findState(stateNum:int, states:Dictionary) -> String:
	var idx = 0
	var ret = ""
	for s in states.keys():
		if stateNum == idx:
			ret = s
			break
		idx += 1
	return ret

func configure_audio(node: Node2D, targetScene, audio_distance:int = 50, audio_volume:float = 0.0, autoPlay: bool = true) -> AudioStreamPlayer2D:
	if !weakref(node).get_ref(): return null
	
	# configura a distância padrão de aproximação
	for s in node.get_children():
		if s is AudioStreamPlayer2D:
			s.max_distance = audio_distance
			s.volume_db = audio_volume
			if targetScene != null:
				s.connect("finished", targetScene, "_on_audio_finished")

	# randomiza um primeiro audio
	var song = rand_audio(node)

	# inicia um audio
	if autoPlay:
		if song != null:
			song.volume_db = -40
			song.play()

	return song

func rand_audio(node:Node2D) -> AudioStreamPlayer2D:
	# Se não for informado um node onde tem as músicas, então sai da função
	if !weakref(node).get_ref(): return null

	# pega a lista de possíveis músicas que estão no node informado
	var song_list = node.get_children()
	var song = null
	
	# Verifica se tem pelo menos um node filho
	if song_list.size() >= 1:
		# pega randomicamente um node filho
		song = song_list[randi() % song_list.size()]
	
	# Se não existe mais a referencia então retorna null
	if !weakref(song).get_ref():
		return null
	
	# Se o "song" selecionado não for do tipo AudioStreamPlayer2D
	if !song is AudioStreamPlayer2D:
		return null
	
	# Caso o contrário retorna o node da música
	return song
	
