extends Node

# player moves the cursor around the match board
signal play_cursor_movement

# whenever a hat piece drops a square
signal play_hat_drop

# whenever a hat piece drops into a bad square
signal play_bad_hat_drop

# whenever the player hits the Undo button
signal play_undo

# a hat is completed
signal play_hat_complete

# abraham lincoln is judging you
signal play_judgy_abe

# a match is made ('cherries', etc.)
signal play_match_made

# UI - button click
signal play_button_click

# Give the music track a little pitch drop to indicate sadness
signal play_sad_pitch

# Time running out!
signal play_fast_pitch
