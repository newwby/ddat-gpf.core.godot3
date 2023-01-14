extends Node2D

# after running this sample scene check your user data folder for the file
# run this sample scene repeatedly to further edit the file

##############################################################################

# debug arguments
const SCRIPT_NAME := "GlobalData_SampleScene"
const VERBOSE_LOGGING := true

# amount to edit the gameDataContainer object 'example_float_data' property by
var increase: float = 2.70

onready var user_data_folder_label_node: Label =\
		$CenterContainer/VBoxContainer/Label_UDF

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# update label text to display user folder text
	# 'user://' works for file paths, but to display the actual path call OS
	var get_user_data_folder: String = OS.get_user_data_dir()
	user_data_folder_label_node.text = get_user_data_folder
	
	# caution: running unit tests will push a lot of (intentional) errors
	run_unit_tests(true)
	
	# will create a gameDataContainer (test class) object in your user data
	# folder at the fixed path (user://saves/save1.tres), then load it and
	# edit the default value before saving it again.
	run_save_load_edit_example()


##############################################################################


# calling unit tests through an fstring dict
func run_unit_tests(is_valid: bool = false):
	if is_valid:
		print("alert: unit tests push a lot of (intentional) error")
		# run unit tests
		print("test 1 result = {1}"+
				"test 2 result = {2}".format({
				"1": _unit_test_save_resource_path_to_user_data(),
				"2": _unit_test_load_invalid_resource_path()
				}))


func run_save_load_edit_example():
	var directory_path: String = GlobalData.get_dirpath_user()+"saves/"
	var file_path: String = "save1.tres"
	
	# if the file isn't found, create it
	# arg1 path, arg 2override the expected log
	if not GlobalData.validate_path(directory_path+file_path, true):
		# no file found, write a new one
		_test_save(directory_path, file_path, GameDataContainer.new())

	# arg1 pass file path, arg2 pass a type cast test
	var get_save_res = _test_load(directory_path+file_path, GameDataContainer)
	if get_save_res != null:
#		if "get_class" in get_save_res:
#			get_save_res.get_class()
#		print("is save a datacon? ", (get_save_res is GameDataContainer))
#		print(get_save_res)
		if "example_float_data" in get_save_res:
			var get_float_data = get_save_res.example_float_data
#			print(get_float_data)

			# log a line about what is happening
			var increment_print_string =\
				"incrementing example float from {old} by {inc}, "+\
				"value is now {new}".format({
				"old": get_float_data,
				"inc": increase,
				"new": (get_float_data+increase),
			})
			# disable success logging calls by editing VERBOSE LOGGING property
			GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
					"run_save_load_edit_example",
					increment_print_string)
			# now save it to file
			get_save_res.example_float_data = get_float_data+increase
			_test_save(directory_path, file_path, get_save_res)


##############################################################################


# specific to the game_data_container object 'save1.tres'
func _test_save(
		directory_path: String,
		file_path: String,
		player_save: GameDataContainer):
#	var player_save := GameDataContainer.new()
	var _return_arg =\
			GlobalData.save_resource(directory_path, file_path, player_save)


# specific to the game_data_container object 'save1.tres'
func _test_load(file_path: String, type_cast_test = null):
	var save_file = GlobalData.load_resource(
			file_path,
			type_cast_test
	)
	return save_file


# paths must begin with user://
# test by sending invalid paths
# caution: running this unit test will push a lot of (intentional) errors
func _unit_test_save_resource_path_to_user_data() -> bool:
	var get_results = []
	get_results.append(GlobalData.save_resource("test.txt", "", Resource.new()))
	get_results.append(GlobalData.save_resource("get_user", "", Resource.new()))
	get_results.append(GlobalData.save_resource("user:/", "", Resource.new()))
	get_results.append(GlobalData.save_resource("usr://", "", Resource.new()))
	# every result should be invalid
	for result in get_results:
		if result == OK:
			return false
	# if loop through safely, all results were invalid
	return true


# load method should check paths
# test by loading a completely invalid path
func _unit_test_load_invalid_resource_path() -> bool:
	var _end_result := true
	var new_resource
	new_resource = GlobalData.load_resource("fakepath")
	if new_resource == null:
		_end_result = true
	else:
		_end_result = false
	return _end_result


##############################################################################


#func _dev_manual_test():
#	# custom manual testing
#	#
#	var get_test_path = GlobalData.get_dirpath_user()
##	var get_test_path = GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.USER]
#	get_test_path += "test/test2/test3/test4/"
#	var file_name = "res.tres"
#	var return_arg = GlobalData.save_resource(get_test_path, file_name, Resource.new())
#	if return_arg != OK:
#		print("error ", return_arg)
#	else:
#		print("write operation successful")
##		var sample_path = get_test_path+file_name
##		var sample_path = GlobalData.get_dirpath_user()+"res.tres"
#		var sample_path = GlobalData.get_dirpath_user()+"resource_new.tres"
##		var sample_path = GlobalData.get_dirpath_user()+"score.save"
#		var _new_res = GlobalData.load_resource(sample_path)


#func old2():
#	pass # Replace with function body.
#	GlobalData.save_gdc()
#	var new_res = GlobalData.load_gdc()
#	print(new_res)
#	if "get_class" in new_res:
#		print("get_class"+" = ", new_res.get_class())
#	else:
#		print("get_class", " not found")
#	if "get_property_list" in new_res:
#		print("get_property_list"+" = ", new_res.get_property_list())
#	else:
#		print("get_property_list", " not found")
#	if new_res is Resource:
#		print("new res is resource")
#	else:
#		print("new res not resource")
#	if new_res is GameDataContainer:
#		print("new res is game data cotnainer")
#	else:
#		print("new res is not game data container")
#
#	if "example_int_data" in new_res:
#		print("example_int_data"+" = ", new_res.example_int_data)
#	if "example_float_data" in new_res:
#		print("example_float_data"+" = ", new_res.example_float_data)
#	if "example_bool_data" in new_res:
#		print("example_bool_data"+" = ", new_res.example_bool_data)
	
	
	

#func old():
#	GlobalData.save_to_file()
#	var c = GlobalData.load_from_file()
#	print(c.get_class())
#	print(c.is_class("Node"))
##	print(c.is_class("CustomObject"))
#	print(c is CustomObject)
#	if c is CustomObject:
#		c.say_hello()
#	else:
#		print("inval obj")
#	if c != null:
#		if c.has_method("say_hello"):
#			c.say_hello()
#		if c.has_method("get_property_list"):
#			for prop in c.get_property_list():
#				print(prop)
##			print(c.get_property_list())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
