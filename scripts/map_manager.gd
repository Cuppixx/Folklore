extends Node

func custom_add_child(resource:Resource,readable:bool,internal:Node.InternalMode) -> void:
	#custom_add_child only works when adding resources to self. If you want to add resources to other nodes from this node (within this script),
	#please refer to the actual add_child method.
	add_child(resource.instantiate(),readable,internal)
