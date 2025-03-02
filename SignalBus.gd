extends Node

# player selects "exit" or "resume game" or similar from the settings menu
signal settings_exited

# player selects "start game" from title scene
signal game_started

# the second valid cell has been chosen, time to start movin!
signal swap_selected

signal game_over (score)

signal top_hat_made

signal bad_hat_made

signal game_over_timer

signal all_hats

signal close_credits

signal on_score_changed

signal on_restart_game

signal increase_score_multiplier (amount: float)

signal match_made (length: int)

signal scoring_events_finished
