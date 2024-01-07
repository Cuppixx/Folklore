extends Node

#General signals (primarily listened to by the main node).
signal quit_game
signal clear_main

#InterfaceRegistry related signals.
signal enable_ui(element:String)

signal is_in_polygon_area(is_in_polygon_area:bool)
signal in_polygon_area(polygon_index:int, display_text:String)
signal in_polygon_area_get_index(polygon_index:int)

#Mouse related signals.
signal default_mouse_mode
signal set_mouse_mode(captured:bool)
signal confined(on:bool)
signal mouse_trail(on:bool)
signal allow_mouse_trail(allow:bool)

#temp ,test and uncategorized signals
signal new_game(tutorial:bool)
signal set_background_dimension(on:bool)
