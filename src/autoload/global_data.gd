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
#// add optional arg for making write_directory recursive (currently default)
#// add file path .tres extension validation
#// reintroduce load_json and save_json methods (dict validation)
#// add a save/load method pair for config ini file
#// add a save/load method pair for store_var/any node
#// add a get_files_recursively method
#// add file backups optional arg (push_backup on save, try_backup on load);
#		file backups are '-backup1.tres', '-backup2.tres', etc.
#		backups are tried sequentially if error on loading resource
#		add customisable variable for how many backups to keep
#// add error logging for failed move_to_trash on save_resource
#// update error logging for save resource temp_file writing

##############################################################################

#05. signals
#06. enums

# for use with const DATA_PATHS and calling the 'build_path' method
enum DATA_PATH_PREFIXES {USER, LOCAL, GAME_SAVE}

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
	# path for the runtime framework
	DATA_PATH_PREFIXES.GAME_SAVE : "user://saves/",
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


# method to create a directory, required to save resources to directories
# that have yet to be referenced. If the path to the directory consists of
# multiple directories that have yet to be created, this method will create
# every directory specified in the path.
# Does nothing if the path already exists.
# [method params as follows]
##1, absolute_path, is the full path to the directory
func create_directory(
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


# this method loads and returns (if valid) a resource from disk
# returns either a loaded resource, or a null value if it is invalid
# [method params as follows]
##1, file_path, is the path to the resource to be loaded.
##2, type_cast, should be comparison type or object of a class to be compared
# to the resource once it is loaded. If the comparison returns untrue, the
# loaded resource will not be returned. The default argument for this parameter
# is null, which will result in this comparison behvaiour being ignored.
# Developers can use this to ensure the resource they're loading will return
# a resource of the class they desire.
# [warning!] Devs, if using a var referencing an object as a comparison class
# class, be careful not to use an object that shares a common parent but isn't
# the same end point class (example would be HBoxContainer and VBoxContainer
# both sharing many of the same parents), as this may return false postiives.
func load_resource(
		file_path: String,
		type_cast = null
		):
	# check path is valid before loading resource
	# error logging redundant as validate_path method includes logging
	var is_path_valid = validate_path(file_path)
	if not is_path_valid:
		return null
	
		# attempt to load resource
	var new_resource: Resource = ResourceLoader.load(file_path)
	
	# then validate it was loaded and is corrected type
	
	# if resource wasn't succesfully loaded (check before type validation)
	if new_resource == null:
		GlobalDebug.log_error(SCRIPT_NAME, "load_resource",
				"resource not loaded successfully, is null")
		return null
	
	# ignore type_casting behaviour if set to null
	# otherwise loaded resource must be the same type
	if not (type_cast == null):
		if not (new_resource is type_cast):
			# discard value to ensure reference count update
			new_resource = null
			GlobalDebug.log_error(SCRIPT_NAME, "load_resource",
					"resource not loaded succesfully, invalid type")
			return null
	
	# if everything is okay, return the loaded resource
	GlobalDebug.log_success(verbose_logging, SCRIPT_NAME, "load_resource",
			"resource {res} validated and returned".format({
				"res": new_resource
			}))
	return new_resource


# method to save any resource or resource-extended custom class to disk.
# call this method with 'if save_resource(*args) == OK' to validate
#
# [method params as follows]
##1, directory_path, is the path to the file location sans the file_name
#	e.g. 'user://saves/player1.tres' should be passed as 'user://saves/'
# (Always leave a trailing slash on the end of directory paths.)
#
##2, file_name, is the name of the file
#	e.g. 'user://saves/player1.tres' should be passed as 'player1.tres'
#	(note: resource extensions should always be .tres for a resource)
# the first two arguments are combined to get the full file path; they exist
# as separate arguments so directories can be validated independent of files.
#
##3, saveable_res, is the resource object to save
#
##4, force_write_file, specifies whether to allow overwriting an existing
# file; if it is set false then the resource will not be saved if it finds a
# file (whether the file is a valid resource or not) at the file path argument.
# You can use this to save default versions of user-customisable files like
# data containers for game saves, player progression, or scores.
#
##5, force_write_directory, specifies whether to allow creating directories
# during the save operation; if set false will require save operations to take
# place in an existing directory, returning with an error argument if the
# directory doesn't exist. if arg5 is set true it will create directories when
# the save operation is called.
#	(calling with a force_write arg will override 'path not found' error
#	logging for the file or directory validation methods respectively,
#	see 'is_write_operation_directory_valid' & '_is_write_operation_path_vaild')
func save_resource(
		directory_path: String,
		file_name: String,
		saveable_res: Resource,
		force_write_file: bool = true,
		force_write_directory: bool = true
		) -> int:
	# combine paths
	var full_data_path: String = directory_path+file_name
	# error code (or OK) for returning
	var return_code: int
	
	# next up are methods to validate the write operation. For each;
	# if OK (0), continue function. If an error code (1+), return the error.
	# We're using error codes rather than bool for more informative debugging.
	
	# validate directory path
	return_code = _is_write_operation_directory_valid(
			directory_path,
			force_write_directory
			)
	if return_code != OK:
		return return_code
	
	# validate file path
	return_code = _is_write_operation_path_valid(
			full_data_path,
			force_write_file
			)
	if return_code != OK:
		return return_code
	
	# move on to the write operation
	# if file is new, just attempt a write (override logging)
	if not validate_path(full_data_path, true):
		return_code = ResourceSaver.save(full_data_path, saveable_res)
	# if file already existed, need to safely write to prevent corruption
	# i.e. write to a temporary file, remove the older, make temp the new file
	else:
		# attempt the write operation
		var temp_data_path = directory_path+"temp_"+file_name
		return_code = ResourceSaver.save(temp_data_path, saveable_res)
		# if we wrote the file successfully, time to remove the old file
		# i.e. move previous file to recycle bin/trash
		
		if return_code == OK:
			# re: issue 67137, OS.move_to_trash will cause a project crash
			# but on this branch the full_data_path should be validated
			assert(validate_path(full_data_path, true))
			# Note: If the user has disabled trash on their system,
			# the file will be permanently deleted instead.
			var get_global_path =\
					ProjectSettings.globalize_path(full_data_path)
			return_code = OS.move_to_trash(get_global_path)
			# if file was moved to trash, the path should now be invalid
			if return_code == OK:
				assert(not validate_path(full_data_path, true))
				# rename the temp file to be the new file
				var path_manager = Directory.new()
				return_code = path_manager.rename(\
						temp_data_path, full_data_path)
		# if the temporary file wasn't written successfully
		else:
			return return_code
	
	
	# if all is well and the function didn't exit prior to this point
	# successful exit points will be
	# 1) path didn't exist and file was written, or
	# 2) path exists, temp file written, first file trashed, temp file renamed
	# return code should be 'OK' (int 0)
	return return_code


# validate either a directory or file path, depending on the path passed.
#
# [method params as follows]
##1, path, is the path to validate
#
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
				"file or directory [{p}] not found".format({"p": path}))
	return _is_valid


##############################################################################

# private methods


# validation method for public 'save' methods
func _is_write_operation_directory_valid(
		directory_path: String,
		force_write_directory: bool
		) -> int:
	# resources can only be saved to paths within the user data folder.
	# user data path is "user://"
	if directory_path.substr(0, 7) != DATA_PATHS[DATA_PATH_PREFIXES.USER]:
		GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
				"{p} is not user_data path".format({"p": directory_path}))
		return ERR_FILE_BAD_PATH
	
	# check if the directory already exists
	# don't log error not finding path if called with force_write
	if not validate_path(directory_path, force_write_directory):
		# if not force writing, and directory doesn't exist, return invalid
		if not force_write_directory:
			GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
					"directory at {p} does not exist".format({
						"p": directory_path}))
			return ERR_FILE_BAD_PATH
		# if force writing and directory doesn't exist, create it
		elif force_write_directory:
			var attempt_write_dir = create_directory(directory_path)
			if attempt_write_dir != OK:
				GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
						"failed attempt to write directory at {p}".format({
							"p": directory_path
						}))
				return attempt_write_dir
	# if all was successful,
	# and no directory needed to be created
	return OK


# validation method for public 'save' methods
# this method assumes the directory already exists, call create_directory()
# beforehand on the directory if you are unsure
func _is_write_operation_path_valid(
		file_path: String,
		force_write_file: bool
		) -> int:
	# check the full path is valid
	var _is_path_valid := false
	# don't log error not finding path if called with force_write
	_is_path_valid = validate_path(file_path, force_write_file)
	
	# if file exists and we don't have permission to overwrite
	if (not force_write_file and _is_path_valid):
		GlobalDebug.log_error(SCRIPT_NAME, "save_resource",
				"file at {p} already exists".format({
					"p": file_path}))
		return ERR_FILE_NO_PERMISSION
	# if all was successful,
	return OK


##############################################################################

#// ATTENTION DEV
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

