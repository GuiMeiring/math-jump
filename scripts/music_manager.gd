extends Node

var _player: AudioStreamPlayer
var _current_stream_key := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.finished.connect(_ensure_playing)
	add_child(_player)

func _process(_delta: float) -> void:
	_ensure_playing()

func play_music(music_stream: AudioStream) -> void:
	if music_stream == null:
		return

	var stream_key := _get_stream_key(music_stream)
	if stream_key == _current_stream_key:
		_ensure_playing()
		return

	var looping_stream := music_stream.duplicate() as AudioStream
	if looping_stream == null:
		looping_stream = music_stream

	if looping_stream is AudioStreamOggVorbis:
		(looping_stream as AudioStreamOggVorbis).loop = true

	_current_stream_key = stream_key
	_player.stream = looping_stream
	_player.play()

func _ensure_playing() -> void:
	if _player == null or _player.stream == null or _player.playing:
		return

	_player.play()

func _get_stream_key(music_stream: AudioStream) -> String:
	if not music_stream.resource_path.is_empty():
		return music_stream.resource_path

	return str(music_stream.get_instance_id())
