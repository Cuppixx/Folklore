extends Node

#General signals (primarily listened to by the main node).
signal quit_game
signal clear_main

#MainMenu related signals.
signal set_mainmenu(enabled:bool)
signal set_background_dimension(three_dimensional:bool)
signal new_game(tutorial:bool)

#Mouse related signals.
signal set_mouse_mode(captured:bool)
signal confined(on:bool)

#Input related signals.

#Reset signals
signal reset_video
signal reset_audio
signal reset_controls
signal reset_gamesettings
