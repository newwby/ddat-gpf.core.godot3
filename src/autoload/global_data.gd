extends GameGlobal

#class_name GlobalData

##############################################################################
#
# DDAT Data Manager provides robust and simplified interpretations of the core
# Godot data management methods, and a structure for future DDAT packages.
#
# DEPENDENCIES
# Set as an autoload *AFTER* DDAT_Core.GlobalDebug

#//TODO
#// finish load_resource
#// add optional arg for making write_directory recursive

##############################################################################
#
# Declare member variables here. Examples:

#05. signals
#06. enums

# for use with const DATA_PATHS and calling the 'build_path' method
enum DATA_PATH_PREFIXES {USER, LOCAL}

#07. constants
# for passing to error logging
const SCRIPT_NAME := "GlobalData"
#// superceded by 'verbose_logging' property of parent class
# for developer use, enable if making changes
#const VERBOSE_LOGGING := true

# fixed record of data paths
# developers can extend this to their needs
const DATA_PATHS := {
	# default path to start save_resource paths with
	DATA_PATH_PREFIXES.USER : "user://",
	# path to use if getting from the local project
	DATA_PATH_PREFIXES.LOCAL : "res://",
}


##############################################################################

# public methods


# method allows building paths from the DATA_PATHS (dict) database; a record
# which can be extended by the developer to add their own specific nested
# directory paths. This allows for consistent directory referencing.
# this method can be passed a file name argument or directory path to extend
# the fixed data path stored in DATA_PATHS
# [method params as follows]
##1, data_path_key, is a key from DATA_PATH_PREFIXES for DATA_PATHS
##2, file_name, is an extension for the data path, applied last
##3, directory_path, is an extension for the data path, applied first
func build_path(
		data_path_key,
		file_name: String="",
		directory_path: String=""
		) -> String:
	# get the initial data path from the directory
	var full_data_path: String = ""
	var get_fixed_data_path: String
	if data_path_key in DATA_PATHS.keys():
		if typeof(DATA_PATHS[data_path_key]) == TYPE_STRING:
			get_fixed_data_path = DATA_PATHS[data_path_key]# as String
			# build the path
			full_data_path = full_data_path + get_fixed_data_path
	else:
		# returns empty on invalid data_path_key
		GlobalDebug.log_error(SCRIPT_NAME, "build_path",
				"data_path_key {k} not found".format({"k": data_path_key}))
		return ""
	
	# if dirpath not empty, append to the data path
	if directory_path != "":
		# build the path
		full_data_path = full_data_path + directory_path
	
	# if file name not empty, append to the data path
	if file_name != "":
		# build the path
		full_data_path = full_data_path + file_name
	
	# return the path
	return full_data_path


# this method returns the string value of the DATA_PATHS (dict) database,
# the path to the local directory (res://)
# this is shorter and less prone to user error than the dev writing;
#	GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.LOCAL]
# developers are encouraged to create their own variants of this method if
# they add their own prefixes to the DATA_PATH dict/db.
func get_dirpath_local() -> String:
	return DATA_PATHS[DATA_PATH_PREFIXES.LOCAL]


# this method returns the string value of the DATA_PATHS (dict) database,
# the path to the user directory (user://)
# this is shorter and less prone to user error than the dev writing;
#	GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.USER]
# developers are encouraged to create their own variants of this method if
# they add their own prefixes to the DATA_PATH dict/db.
func get_dirpath_user() -> String:
	return DATA_PATHS[DATA_PATH_PREFIXES.USER]


#// TODO UNFINISHED load_resource method
#func load_resource(
#		file_path: String,
#		is_class_cast = null
#		):
#	pass
##func load_gdc():
##	var new_resource = ResourceLoader.load(resource_path)
##	return new_resource


# method to save any resource or resource-extended custom class to disk.
# call this method with 'if save_resource(*args) == OK' to validate
# [method params as follows]
##1, directory_path, is the path to the file location sans the file_name
#	e.g. 'user://saves/player1.sav' should be passed as 'user://saves/'
# (Always leave a trailing slash on the end of directory paths.)
##2, file_name, is the name of the file
#	e.g. 'user://saves/player1.sav' should be passed as 'player1.sav'
# the first two arguments are combined to get the full file path; they exist
# as separate arguments so directories can be validated independent of files.
##3, saveable_res, is the resource object to save
##4, force_write_file, specifies whether to allow overwriting an existing
# file; if it is set false then the resource will not be saved if it finds a
# file (whether the file is a valid resource or not) at the file path argument.
# You can use this to save default versions of user-customisable files like
# data containers for game saves, player progression, or scores.
##5, force_write_directory, specifies whether to allow creating directories
# during the save operation; if set false will require save operations to take
# place in an existing directory, returning with an error argument if the
# directory doesn't exist. if arg5 is set true it will create directories when
# the save operation is called.
func save_resource(
		directory_path: String,
		file_name: String,
		saveable_res: Resource,
		force_write_file: bool = true,
		force_write_directory: bool = true
		) -> int:
	# combine paths
	var full_data_path: String = directory_path+file_name
	# resources can only be saved to paths within the user data folder.
	# user data path is "user://"
	if directory_path.substr(0, 7) != DATA_PATHS[DATA_PATH_PREFIXES.USER]:
		GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
				"{p} is not user_data path".format({"p": directory_path}))
		return ERR_FILE_BAD_PATH
	
	# check if the directory already exists
	if not validate_path(directory_path):
		# if not force writing, and directory doesn't exist, return invalid
		if not force_write_directory:
			GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
					"directory at {p} does not exist".format({
					"p": directory_path}))
			return ERR_FILE_BAD_PATH
		# if force writing and directory doesn't exist, create it
		elif force_write_directory:
			var attempt_write_dir = write_directory(directory_path)
			if attempt_write_dir != OK:
				GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
						"failed attempt to write directory at {p}".format({
							"p": directory_path
						}))
				return attempt_write_dir
	
	# check the full path is valid
	var _is_path_valid := false
	_is_path_valid = validate_path(full_data_path)
	# if we aren't overwriting the file, no file must exist at the path.
	if not force_write_file\
	and _is_path_valid:
			GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
					"file at {p} already exists".format({
					"p": full_data_path}))
			return ERR_FILE_NO_PERMISSION

	# default return arg at this point is a pass
	var _return_arg = OK
	# path must be valid
#	if _is_path_valid:
	# everything okay, save the resource
	_return_arg = ResourceSaver.save(full_data_path, saveable_res)
#	_return_arg = ERR_FILE_BAD_PATH
	# if all is well and the function didn't exit prior to this point
	return _return_arg


# validate either a directory or file path, depending on the path passed.
# [method params as follows]
##1, path, is the path to validate
##2, override_logging, disables calls to globalDebug. This method is called by
# many other methods in GlobalDebug in scenarios where it may, or even is
# expected to, fail; overriding error logging makes for a cleaner experience.
func validate_path(
		path: String,
		override_logging: bool = false
		) -> bool:
	var _path_check = Directory.new()
	var _is_valid = false
	#// add logic for stripping usr/res path mistakenly passed by dev?
	# for method to return true only needs to be a valid directory OR file
	if _path_check.dir_exists(path)\
	or _path_check.file_exists(path):
		_is_valid = true
	# error logging
	if not _is_valid\
	and not override_logging:
		GlobalDebug.log_error(SCRIPT_NAME, "_validate_path",
				"file or directory [{p}] not found".format({"p": _path_check}))
	return _is_valid


# method to create a directory, required to save resources to directories
# that have yet to be referenced. If the path to the directory consists of
# multiple directories that have yet to be created, this method will create
# every directory specified in the path.
# Does nothing if the path already exists.
# [method params as follows]
##1, absolute_path, is the full path to the directory
func write_directory(
		absolute_path: String
		) -> int:
	# object to get directory class methods
	var dir_accessor = Directory.new()
	# do nothing if path exists (expected to fail so overridden error logging)
	if validate_path(absolute_path, true) == false:
		# directories all the way down
		#// TODO add optional arg for making recursive
		dir_accessor.make_dir_recursive(absolute_path)
		return OK
	else:
		return ERR_CANT_CREATE


##############################################################################

# private methods


## if arg force_validate is set will create the directory if it doesn't find it
#func validate_directory(directory_path: String, force_validate:= false):
#	var directory_certifier = Directory.new()
#	if directory_certifier.dir_exists(directory_path):
#		return true
#	else:
#		if directory_certifier.make_dir_recursive(directory_path) == OK\
#		and force_validate:
#			return true
#		else:
#			return false


##############################################################################

# Further documentation and advice on saving to/loading from disk,
# managing loading etc, can be found at:
#	
#	https://docs.godotengine.org/en/latest/classes/class_configfile.html
#	https://docs.godotengine.org/en/stable/classes/class_resourcesaver.html
#	https://docs.godotengine.org/en/stable/classes/class_resourceloader.html
#	https://docs.godotengine.org/en/stable/classes/class_directory.html
#	https://docs.godotengine.org/en/stable/classes/class_file.html
#	https://github.com/khairul169/gdsqlite
#	https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
#	http://kidscancode.org/godot_recipes/4.x/basics/file_io/
#	https://godotengine.org/qa/21370/what-are-various-ways-that-i-can-store-data

# https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html

# https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
# [on self-contained mode]
# Self-contained mode is not supported in exported projects yet. To read and
# write files relative to the executable path, use OS.get_executable_path().
# Note that writing files in the executable path only works if the executable
# is placed in a writable location (i.e. not Program Files or another directory
# that is read-only for regular users).

##############################################################################

