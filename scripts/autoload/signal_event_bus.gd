extends Node

#General signals (primarily listened to by the main node).
signal quit_game
signal clear_main

#MainMenu related signals.
signal set_mainmenu(enabled:bool)
signal set_background_dimension(three_dimensional:bool)
signal new_game(tutorial:bool)
signal is_in_polygon_area(is_in_polygon_area:bool)
signal in_polygon_area(polygon_index:int, display_text:String)
signal in_polygon_area_get_index(polygon_index:int)

#Mouse related signals.
signal set_mouse_mode(captured:bool)
signal confined(on:bool)
signal mouse_trail(on:bool)

#Input related signals.

#Reset signals
signal reset_video
signal reset_audio
signal reset_controls
signal reset_gamesettings
