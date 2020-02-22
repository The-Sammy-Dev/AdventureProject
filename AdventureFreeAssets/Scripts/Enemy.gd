extends KinematicBody2DCore

export(int) var audio_wait_repeat: int = 1 # segundos
export(int) var audio_distance: int = 500 # pixels de distância
export(float) var audio_volume: float = -10.0 # volume dos audios
export(bool) var randomize_audio: bool = true # se é para randomizar o audio após ele tocar
var song: AudioStreamPlayer2D = null
var stopAutoFollow: bool = false

var autoAttack: Timer = Timer.new()

export(float) var velocityFollow: float = 0.2
var autoFollow: PathFollow2D = null
var dirFollow: int = 1

func _ready():
	randomize()
	song = Common.configure_audio($songs, self, audio_distance, audio_volume, true)
	
	# Se o Zombie for filho de um node PathFollow2D, então ele começa a seguir sozinho pelo caminho desenhado
	var testFollow = get_parent()
	if testFollow is PathFollow2D:
		autoFollow = testFollow
	
	autoAttack.wait_time = 1
	autoAttack.autostart = false
	autoAttack.one_shot = false
	autoAttack.connect("timeout", self, "_on_autoAttack_timeout")
	add_child(autoAttack)
	
func _on_audio_finished():
	# Quando o audio terminar, aguarda alguns segundos para repetir
	# Verifica se a referência do audio existe
	if weakref(song).get_ref():
		yield(get_tree().create_timer(audio_wait_repeat), "timeout")
		song.play()
			
	# se após tocar um audio for pra randomizar um novo audio
	if randomize_audio:
		song = Common.rand_audio($songs)

func _process(delta):
	# Se for para o monstro ficar andando sozinho, então ele segue o PathFollow2D
	if dying: return
	
	# Se tem um corpo presente
	if weakref(bodyEntered).get_ref():
		var dir: float = bodyEntered.global_position.x - self.global_position.x
		$sprite.flip_h = dir < 0
		return
	
	if stopAutoFollow: return
	if autoFollow:
		$sprite.flip_h = dirFollow < 0
		autoFollow.unit_offset += (velocityFollow * dirFollow) * delta
		$sprite.play(Common._findState(states.walking, states))

		
		if autoFollow.unit_offset == 0.0:
			dirFollow = 1
		if autoFollow.unit_offset == 1.0:
			dirFollow = -1
	
func _on_area_attack_body_entered(body):
	if dying: return
	if body.is_in_group(Common._findState(types.player, types)):
		stopAutoFollow = true
		bodyEntered = body
		_on_autoAttack_timeout()
		autoAttack.start()

func _on_area_attack_body_exited(body):
	if dying: return
	if body.is_in_group(Common._findState(types.player, types)):
		bodyEntered = null
		stopAutoFollow = false
		autoAttack.stop()
		_stopAudioSfx(Common._findState(states.attack, states))
		$sprite.play(Common._findState(states.idle, states))
		
func _on_autoAttack_timeout():
	if dying: return
	if weakref(bodyEntered).get_ref():
		if bodyEntered.is_in_group(Common._findState(types.player, types)):
			bodyEntered.hit(powerAttack)
			$sprite.play(Common._findState(states.attack, states))
			_playAudioSfx(Common._findState(states.attack, states), false) # Executa o audio
