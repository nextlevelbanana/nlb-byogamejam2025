extends Node2D

var isPlaying: bool = true
var events = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	events["play_cursor_movement"] = FmodServer.create_event_instance("event:/Controls/Cursor Movement")
	events["hat_drop"] = FmodServer.create_event_instance("event:/Controls/Hat Drop")
	events["bad_hat_drop"] = FmodServer.create_event_instance("event:/Controls/Bad Hat Drop")
	events["undo"] = FmodServer.create_event_instance("event:/Controls/Undo")
	events["hat_complete"] = FmodServer.create_event_instance("event:/Controls/Hat Complete")
	events["judgy_abe"] = FmodServer.create_event_instance("event:/Controls/Judgy Abe")
	events["match_made"] = FmodServer.create_event_instance("event:/Controls/Match Made")
	events["button_click"] = FmodServer.create_event_instance("event:/UI/Button Click")
	AudioSignalBus.connect("play_cursor_movement", _play_cursor_movement)
	AudioSignalBus.connect("play_hat_drop", _play_hat_drop)
	AudioSignalBus.connect("play_bad_hat_drop", _play_bad_hat_drop)
	AudioSignalBus.connect("play_undo", _play_undo)
	AudioSignalBus.connect("play_hat_complete", _play_hat_complete)
	AudioSignalBus.connect("play_judgy_abe", play_judgy_abe)
	AudioSignalBus.connect("play_match_made", _play_match_made)
	AudioSignalBus.connect("play_button_click", _play_button_click)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _play_audio_event(event_key):
	print("audio_event_emitter::_play_audio_event::" + event_key)
	var event = events[event_key]
	event.set_2d_attributes(self.global_transform)
#	event.set_parameter_by_name("RPM", 600)
	event.volume = 1
	event.start()

func _play_cursor_movement():
	print("audio_event_emitter::_play_cursor_movement")
	_play_audio_event("play_cursor_movement")

func _play_hat_drop():
	print("audio_event_emitter::_play_hat_drop")
	_play_audio_event("hat_drop")

func _play_bad_hat_drop():
	_play_audio_event("bad_hat_drop")

func _play_undo():
	_play_audio_event("undo")

func _play_hat_complete():
	_play_audio_event("hat_complete")

func play_judgy_abe():
	_play_audio_event("judgy_abe")

func _play_match_made():
	_play_audio_event("match_made")

func _play_button_click():
	_play_audio_event("button_click")
