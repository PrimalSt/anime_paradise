extends Node

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var current_bgm_track: String = ""

# Pre-cached streams
var _tick_wav_normal: AudioStreamWAV = null
var _tick_wav_gold: AudioStreamWAV = null
var _spin_wav: AudioStreamWAV = null
var _stop_wav: AudioStreamWAV = null
var _near_miss_wav: AudioStreamWAV = null
var _click_wav: AudioStreamWAV = null
var _pull_wav: AudioStreamWAV = null
var _card_flip_wav: AudioStreamWAV = null
var _burst_r_wav: AudioStreamWAV = null
var _fanfare_sr_wav: AudioStreamWAV = null
var _fanfare_ssr_wav: AudioStreamWAV = null
var _fanfare_ur_wav: AudioStreamWAV = null
var _heart_wav: AudioStreamWAV = null
var _coins_wav: AudioStreamWAV = null

# Fixed pool of audio players (avoids dynamic node creation & memory leaks)
var _tick_players: Array[AudioStreamPlayer] = []
var _tick_idx: int = 0

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_idx: int = 0

func _ready() -> void:
	# Create BGM bus
	AudioServer.add_bus()
	var bgm_bus_idx = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bgm_bus_idx, "BGM")
	AudioServer.set_bus_send(bgm_bus_idx, "Master")

	# Create SFX bus
	AudioServer.add_bus()
	var sfx_bus_idx = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(sfx_bus_idx, "SFX")
	AudioServer.set_bus_send(sfx_bus_idx, "Master")

	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM"
	bgm_player.volume_db = -12.0
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	sfx_player.volume_db = -4.0
	add_child(sfx_player)

	# Pre-allocate audio pools
	_init_audio_pools()

	# Pre-generate all static waveforms
	_precache_all_sfx()

	# Start soothing anime ambient soundtrack
	start_ambient_bgm()

func _init_audio_pools() -> void:
	# Dedicated 12-voice tick pool for smooth low-latency roulette ticking
	for i in range(12):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_tick_players.append(p)

	# Dedicated 8-voice general SFX pool
	for i in range(8):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

func _play_pooled_sfx(stream: AudioStream, volume_db: float = -3.0, pitch: float = 1.0) -> void:
	if not stream or _sfx_pool.is_empty():
		return
	var p = _sfx_pool[_sfx_idx]
	_sfx_idx = (_sfx_idx + 1) % _sfx_pool.size()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()

func _precache_all_sfx() -> void:
	# 1. Roulette ticks (with sharp transient clapper attack)
	_tick_wav_normal = _generate_tick_wav(1050.0, false)
	_tick_wav_gold = _generate_tick_wav(1750.0, true)

	# 2. Whoosh / Spin
	_spin_wav = _generate_sweep_wav(180.0, 920.0, 0.55, 0.45, "cosmic")

	# 3. Latch stop (mechanical heavy click + bass thud)
	_stop_wav = _generate_mechanical_stop_wav()

	# 4. Near miss tension riser
	_near_miss_wav = _generate_sweep_wav(480.0, 210.0, 0.45, 0.5, "cosmic")

	# 5. UI Click
	_click_wav = _generate_note_wav(880.0, 0.07, 0.28, "bell")

	# 6. Gacha Pull
	_pull_wav = _generate_sweep_wav(220.0, 880.0, 0.45, 0.35, "cosmic")

	# 7. Card flip
	_card_flip_wav = _generate_sweep_wav(380.0, 720.0, 0.12, 0.25, "soft")

	# 8. Rarity Bursts / Fanfares
	_burst_r_wav = _generate_sweep_wav(350.0, 520.0, 0.22, 0.32, "soft")
	_fanfare_sr_wav = _generate_composite_arpeggio([440.0, 554.37, 659.25, 880.0], 0.09, 0.45, "bell")
	_fanfare_ssr_wav = _generate_composite_arpeggio([659.25, 830.61, 987.77, 1318.51], 0.10, 0.55, "bell")
	_fanfare_ur_wav = _generate_composite_arpeggio([523.25, 659.25, 783.99, 987.77, 1174.66, 1318.51], 0.08, 0.6, "bell")

	# 9. Dating & Currency
	_heart_wav = _generate_composite_arpeggio([523.25, 659.25, 783.99], 0.07, 0.35, "soft")
	_coins_wav = _generate_composite_arpeggio([987.77, 1318.51], 0.06, 0.35, "bell")

func play_sfx_roulette_tick(is_gold: bool = false, pitch: float = 1.0) -> void:
	if _tick_players.is_empty():
		return
	var p = _tick_players[_tick_idx]
	_tick_idx = (_tick_idx + 1) % _tick_players.size()
	p.stream = _tick_wav_gold if is_gold else _tick_wav_normal
	p.pitch_scale = clampf(pitch, 0.75, 1.5)
	p.volume_db = 0.0 if is_gold else -3.5
	p.play()

func play_sfx_roulette_spin() -> void:
	_play_pooled_sfx(_spin_wav, -2.0)

func play_sfx_roulette_stop() -> void:
	_play_pooled_sfx(_stop_wav, 0.0)

func play_sfx_near_miss() -> void:
	_play_pooled_sfx(_near_miss_wav, 1.0)

func play_sfx_click() -> void:
	_play_pooled_sfx(_click_wav, -6.0)

func play_sfx_pull() -> void:
	_play_pooled_sfx(_pull_wav, -3.0)

func play_sfx_card_flip() -> void:
	_play_pooled_sfx(_card_flip_wav, -4.0)

func play_sfx_burst(rarity: String = "R") -> void:
	match rarity:
		"UR":
			play_sfx_ur()
		"SSR":
			play_sfx_ssr()
		"SR":
			_play_pooled_sfx(_fanfare_sr_wav, -1.0)
		_:
			_play_pooled_sfx(_burst_r_wav, -3.0)

func play_sfx_ssr() -> void:
	_play_pooled_sfx(_fanfare_ssr_wav, 0.0)

func play_sfx_ur() -> void:
	_play_pooled_sfx(_fanfare_ur_wav, 1.0)

func play_sfx_heart() -> void:
	_play_pooled_sfx(_heart_wav, -4.0)

func play_sfx_coins() -> void:
	_play_pooled_sfx(_coins_wav, -3.0)

func play_sfx_level_up() -> void:
	play_synth_arpeggio([523.25, 659.25, 783.99, 1046.50, 1318.51], 0.08, 0.5, "bell")

func play_sfx_ascend() -> void:
	play_synth_arpeggio([440.0, 554.37, 659.25, 880.0, 1108.73, 1318.51], 0.09, 0.6, "cosmic")

func play_sfx_blip() -> void:
	play_sfx_roulette_tick(true, 1.3)

# Backward compatibility dynamic helper
func play_synth_note(freq: float, duration: float, volume: float = 0.5, timbre: String = "bell") -> void:
	var wav = _generate_note_wav(freq, duration, volume, timbre)
	_play_pooled_sfx(wav, -3.0)

func play_synth_sweep(start_freq: float, end_freq: float, duration: float, volume: float = 0.5, timbre: String = "soft") -> void:
	var wav = _generate_sweep_wav(start_freq, end_freq, duration, volume, timbre)
	_play_pooled_sfx(wav, -3.0)

func play_synth_arpeggio(freqs: Array, note_duration: float, volume: float = 0.5, timbre: String = "bell") -> void:
	var wav = _generate_composite_arpeggio(freqs, note_duration, volume, timbre)
	_play_pooled_sfx(wav, -2.0)

# Waveform Generators
func _generate_tick_wav(freq: float, is_gold: bool) -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.038
	var num_samples = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var progress = float(i) / num_samples
		var envelope = exp(-progress * (30.0 if is_gold else 60.0))
		
		# Clapper mechanical transient click in first 3ms
		var transient = 0.0
		if i < int(sample_rate * 0.0035):
			transient = (sin(float(i) * 1.7) * 0.7 + (float(i % 5) - 2.0) * 0.15) * exp(-progress * 280.0)

		var sample = 0.0
		if is_gold:
			sample = (sin(t * freq * TAU) * 0.5 + sin(t * freq * 1.5 * TAU) * 0.3 + sin(t * freq * 2.2 * TAU) * 0.2)
		else:
			sample = (sin(t * freq * TAU) * 0.65 + sin(t * freq * 2.6 * TAU) * 0.35)
		
		sample = (sample * 0.7 + transient * 0.6) * envelope * 0.85
		var sample_int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_int)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_mechanical_stop_wav() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.32
	var num_samples = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var progress = float(i) / num_samples
		# Heavy thud (low sine) + metallic clink (higher decay)
		var bass = sin(t * 120.0 * TAU) * exp(-progress * 14.0) * 0.7
		var clink = (sin(t * 540.0 * TAU) * 0.6 + sin(t * 1280.0 * TAU) * 0.4) * exp(-progress * 42.0) * 0.5
		var sample = (bass + clink) * 0.8
		var sample_int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_int)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_note_wav(freq: float, duration: float, volume: float = 0.5, timbre: String = "bell") -> AudioStreamWAV:
	var sample_rate = 22050
	var num_samples = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var progress = float(i) / num_samples
		var envelope = exp(-progress * 6.0)

		var sample = 0.0
		if timbre == "bell":
			sample = sin(t * freq * TAU) * 0.7 + sin(t * freq * 2.0 * TAU) * 0.2 + sin(t * freq * 3.0 * TAU) * 0.1
		elif timbre == "soft":
			sample = sin(t * freq * TAU)
		elif timbre == "cosmic":
			sample = sin(t * freq * TAU) * 0.6 + sin(t * (freq * 1.5) * TAU) * 0.4

		sample *= envelope * volume
		var sample_int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_int)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_sweep_wav(start_freq: float, end_freq: float, duration: float, volume: float = 0.5, _timbre: String = "soft") -> AudioStreamWAV:
	var sample_rate = 22050
	var num_samples = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)

	for i in range(num_samples):
		var progress = float(i) / num_samples
		var current_freq = lerp(start_freq, end_freq, progress)
		var t = float(i) / sample_rate
		var envelope = sin(progress * PI)

		var sample = sin(t * current_freq * TAU) * 0.75 + sin(t * current_freq * 2.0 * TAU) * 0.25
		sample *= envelope * volume
		var sample_int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_int)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_composite_arpeggio(freqs: Array, note_duration: float, volume: float = 0.5, timbre: String = "bell") -> AudioStreamWAV:
	var sample_rate = 22050
	var total_dur = note_duration * float(freqs.size()) + 0.35
	var num_samples = int(sample_rate * total_dur)
	var float_buffer = PackedFloat32Array()
	float_buffer.resize(num_samples)

	for note_idx in range(freqs.size()):
		var freq: float = freqs[note_idx]
		var start_sample = int(note_idx * note_duration * sample_rate)
		var note_length = int(sample_rate * (note_duration * 3.0))
		
		for j in range(note_length):
			var sample_pos = start_sample + j
			if sample_pos >= num_samples:
				break
			var t = float(j) / sample_rate
			var note_prog = float(j) / float(note_length)
			var env = exp(-note_prog * 5.0)

			var s = 0.0
			if timbre == "bell":
				s = sin(t * freq * TAU) * 0.7 + sin(t * freq * 2.0 * TAU) * 0.2 + sin(t * freq * 3.0 * TAU) * 0.1
			else:
				s = sin(t * freq * TAU)
			float_buffer[sample_pos] += s * env * volume

	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)
	for i in range(num_samples):
		var sample_int = int(clamp(float_buffer[i] * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_int)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

# Ambient BGM
func start_ambient_bgm() -> void:
	var sample_rate = 16000
	var total_duration = 12.0
	var num_samples = int(sample_rate * total_duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)

	var chords = [
		[261.63, 329.63, 392.00, 493.88, 587.33], # Cmaj9
		[220.00, 261.63, 329.63, 392.00, 493.88], # Am9
		[174.61, 220.00, 261.63, 329.63, 392.00], # Fmaj9
		[196.00, 261.63, 293.66, 392.00, 523.25]  # Gsus4/add9
	]

	var chord_duration = total_duration / float(chords.size())

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var chord_idx = int(t / chord_duration) % chords.size()
		var chord = chords[chord_idx]
		var local_t = fmod(t, chord_duration)
		var env = sin((local_t / chord_duration) * PI)

		var sample = 0.0
		for f in chord:
			sample += sin(t * f * TAU) * 0.15
			sample += sin(t * f * 2.0 * TAU) * 0.04

		sample *= env * 0.4
		var sample_int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_int)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = num_samples
	wav.data = bytes

	bgm_player.stream = wav
	bgm_player.play()

func set_master_volume(volume_linear: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(max(0.001, volume_linear)))
	AudioServer.set_bus_mute(bus_idx, volume_linear <= 0.0)

func set_bgm_volume(volume_linear: float) -> void:
	var bus_idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(max(0.001, volume_linear)))
	AudioServer.set_bus_mute(bus_idx, volume_linear <= 0.0)

func set_sfx_volume(volume_linear: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(max(0.001, volume_linear)))
	AudioServer.set_bus_mute(bus_idx, volume_linear <= 0.0)

func get_master_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("Master")
	if AudioServer.is_bus_mute(bus_idx): return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

func get_bgm_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("BGM")
	if AudioServer.is_bus_mute(bus_idx): return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

func get_sfx_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if AudioServer.is_bus_mute(bus_idx): return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
