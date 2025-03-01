extends Node2D

var isPlaying: bool = true
var events = {}
var bgMusic: FmodEvent
var pitchValue: float = 1.0
var currentPitch: float = 1.0

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
	
	AudioSignalBus.connect("play_sad_pitch", _play_sad_pitch)
	AudioSignalBus.connect("play_fast_pitch", _play_fast_pitch)	

	SignalBus.connect("swap_selected", _play_hat_drop)
	SignalBus.connect("top_hat_made", _play_hat_complete)
	SignalBus.connect("bad_hat_made", play_judgy_abe)
	
	bgMusic = FmodServer.create_event_instance("event:/Music/BackgroundMusic")
	bgMusic.volume = 0.5
	bgMusic.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _play_audio_event(event_key):
	print("audio_event_emitter::_play_audio_event::" + event_key)
	var event = events[event_key]
	event.set_2d_attributes(self.global_transform)
#	event.set_parameter_by_name("RPM", 600)
	event.set_pitch(pitchValue)
	event.volume = 1.2
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
	_play_sad_pitch()

func _play_match_made():
	_play_audio_event("match_made")

func _play_button_click():
	_play_audio_event("button_click")

func _on_h_slider_value_changed(value: float) -> void:
	pitchValue = value;
	bgMusic.set_pitch(value)
	
	
func _play_sad_pitch():	
	var tween = create_tween()
	tween.tween_property(bgMusic, "pitch", 0.1, 1.5)
	tween.tween_property(bgMusic, "pitch", currentPitch, 1.5)
		
func _play_fast_pitch():
	currentPitch = 2
	var tween = create_tween()
	tween.tween_property(bgMusic, "pitch", 2, 1.5)

func _play_normal_pitch():
	currentPitch = 1.0
	var tween = create_tween()
	tween.tween_property(bgMusic, "pitch", 1.0, 1)
	
