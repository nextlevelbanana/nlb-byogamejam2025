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
