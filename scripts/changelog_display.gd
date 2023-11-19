extends MarginContainer

@onready var version_label:Label = $VBoxContainer/VersionLabel

@export var version_tag:String = "PreAlpha"
@export var version_number1:int = 0
@export var version_number2:int = 0
@export var version_number3:int = 1

func _ready() -> void:
	version_label.set_text("Folklore -- "+version_tag+" "+str(version_number1)+"."+str(version_number2)+"."+str(version_number3))
