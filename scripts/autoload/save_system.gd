extends Node

const SAVEFILE_ROOTPATH:String = "user://save/"
const SAVEFILE_EXTENSION:String = ".tres"
const NO_PATH:String = ""

#Returns the complete savefile string: root path + path (if provided) + filename + file extension.
func build_absolute_savefile_path(savefile_name:String, savefile_path:String) -> String:
	return SAVEFILE_ROOTPATH+savefile_path+savefile_name+SAVEFILE_EXTENSION

#Returns the complete path string: root path + path (if provided).
#Similar to build_absolute_savefile_path, but excludes the file itself.
func build_absolute_path(path:String = NO_PATH) -> String:
	return SAVEFILE_ROOTPATH+path

#mkdir-like function that generates the specified path in the filesystem.
func make_absolute_path(path:String) -> void: DirAccess.make_dir_absolute(path)

#Verify the existence of a specified path.
func verify_path(path:String) -> bool:
	if DirAccess.dir_exists_absolute(path) == false: return false
	else: return true

#Verify the existence of a specified file, automatically checking if the associated path exists.
func verify_file(file:String, path:String = NO_PATH) -> bool:
	var absolute_path:String = build_absolute_path(path)
	if verify_path(absolute_path) == true:
		var access := DirAccess.open(absolute_path)
		if access.file_exists(file+SAVEFILE_EXTENSION) == true: return true
	return false

#Write a savefile.
func write_savefile(data:Resource, savefile_name:String, savefile_path:String = NO_PATH, flag:int = 0) -> void:
	var absolute_path:String = build_absolute_path(savefile_path)
	#Before saving data, check if the savefile path exists. If it doesn't, create it.
	if verify_path(absolute_path) == false: make_absolute_path(absolute_path)
	else : pass
	ResourceSaver.save(data, build_absolute_savefile_path(savefile_name, savefile_path), flag)

#Load a savefile.
func load_savefile(savefile_name:String, savefile_path:String = NO_PATH) -> Resource:
	return ResourceLoader.load(build_absolute_savefile_path(savefile_name, savefile_path))
