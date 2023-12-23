extends Node
#Node overview:
#The autoload script provides essential functions for reading, writing, verifying, and modifying Savedata.
#It serves as a core component for scripts that store and retrieve data between sessions.
#The save system is designed to support multiple save formats:
#- Text Resource (.tres) --> Godot text resource format
#- JavaScript Object Notation (.json) 	#TODO Add json implementation
#- initialization (.ini) 				#TODO Add .ini implementation

#region Constants list.
const BLANK:String = ""
const SAVEFILE_ROOTPATH:String = "user://save/"
const SAVEFILE_FORMAT_INI:String  = ".ini"
const SAVEFILE_FORMAT_TRES:String = ".tres"
const SAVEFILE_FORMAT_JSON:String = ".json"
#endregion

#TODO Refactor functions to support the different fileformats
#region Utils functions.
#region Build functions.
#Returns the complete savefile string: root path + path (if provided in Write/Load) + filename + file extension.
func build_absolute_savefile_path(savefile_name:String, savefile_path:String) -> String:
	return SAVEFILE_ROOTPATH+savefile_path+savefile_name+SAVEFILE_FORMAT_TRES

#Returns the complete path string: root path + path (if provided).
#Similar to build_absolute_savefile_path, but excludes the file itself.
func build_absolute_path(path:String) -> String:
	return SAVEFILE_ROOTPATH+path
#endregion

#mkdir-like function that generates the specified path in the filesystem.
func make_path_absolute(path:String) -> void: DirAccess.make_dir_absolute(path)

#region Verify functions.
#Verify the existence of a specified path.
func verify_path(path:String) -> bool:
	if DirAccess.dir_exists_absolute(path) == false: return false
	else: return true

#Verify the existence of a specified file, automatically checking if the associated path exists.
func verify_file(file:String, path:String = BLANK) -> bool:
	var absolute_path:String = build_absolute_path(path)
	if verify_path(absolute_path) == true:
		var access := DirAccess.open(absolute_path)
		if access.file_exists(file+SAVEFILE_FORMAT_TRES) == true: return true
	return false
#endregion
#endregion

#region Save and load functions.
#Write a savefile.
func write_savefile(data:Resource, savefile_name:String, savefile_path:String = BLANK, flag:int = 0) -> void:
	var absolute_path:String = build_absolute_path(savefile_path)
	#Before saving data, check if the savefile path exists. If it doesn't, create it.
	if verify_path(absolute_path) == false: make_path_absolute(absolute_path)
	else : pass
	ResourceSaver.save(data, build_absolute_savefile_path(savefile_name, savefile_path), flag)

#Load a savefile.
func load_savefile(savefile_name:String, savefile_path:String = BLANK) -> Resource:
	return ResourceLoader.load(build_absolute_savefile_path(savefile_name, savefile_path))
#endregion
