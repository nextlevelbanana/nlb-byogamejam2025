extends Node2D


func _on_cursor_button_pressed() -> void:
	print("AudioSystem::_on_cursor_button_pressed")
	AudioSignalBus.play_cursor_movement.emit()

func _on_hat_drop_button_pressed() -> void:
	print("AudioSystem::_on_hat_drop_button_pressed")
	AudioSignalBus.play_hat_drop.emit()

func _on_bad_hat_drop_button_pressed() -> void:
	print("AudioSystem::_on_bad_hat_drop_button_pressed")
	AudioSignalBus.play_bad_hat_drop.emit()

func _on_undo_button_pressed() -> void:
	print("AudioSystem::_on_undo_button_pressed")
	AudioSignalBus.play_undo.emit()

func _on_hat_complete_button_pressed() -> void:
	print("AudioSystem::_on_hat_complete_button_pressed")
	AudioSignalBus.play_hat_complete.emit()

func _on_judgy_abe_button_pressed() -> void:
	print("AudioSystem::_on_judgy_abe_button_pressed")
	AudioSignalBus.play_judgy_abe.emit()

func _on_match_made_button_pressed() -> void:
	print("AudioSystem::_on_match_made_button_pressed")
	AudioSignalBus.play_match_made.emit()

func _on_button_click_button_pressed() -> void:
	print("AudioSystem::_on_button_click_button_pressed")
	AudioSignalBus.play_button_click.emit()
