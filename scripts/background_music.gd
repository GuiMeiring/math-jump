extends AudioStreamPlayer

func _ready() -> void:
	autoplay = false
	stop()
	MusicManager.play_music(stream)
