extends Node2D

##############################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	# caution: running unit tests will push a lot of (intentional) errors
	var run_unit_tests = false
	if run_unit_tests:
		# run unit tests
		print("test 1 = {1}"+"test 2 = {2}".format({
				"1": _unit_test_save_resource_path_to_user_data(),
				"2": _unit_test_load_invalid_resource_path()
				}))
	_global_data_test_resource()
	_global_data_test_game_data_container()


##############################################################################


func test_save(player_save, datacon_dir: String, datacon_file: String):
#	var player_save := GameDataContainer.new()
	var _return_arg =\
			GlobalData.save_resource(datacon_dir, datacon_file, player_save)


func test_load(datacon_dir: String, datacon_file: String, type_cast = null):
	var save_file = GlobalData.load_resource(
			datacon_dir+datacon_file,
			type_cast
	)
	return save_file


##############################################################################


# custom manual testing part 1
func _global_data_test_resource():
	var get_test_path = GlobalData.get_dirpath_user()
#	var get_test_path = GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.USER]
	get_test_path += "test/test2/test3/test4/"
	var file_name = "res.tres"
	var return_arg = GlobalData.save_resource(get_test_path, file_name, Resource.new())
	if return_arg != OK:
		print("error ", return_arg)
	else:
		print("write operation successful")
#		var sample_path = get_test_path+file_name
#		var sample_path = GlobalData.get_dirpath_user()+"res.tres"
		var sample_path = GlobalData.get_dirpath_user()+"resource_new.tres"
#		var sample_path = GlobalData.get_dirpath_user()+"score.save"
		var _new_res
		if GlobalData.validate_file(sample_path) == false:
			_new_res = GlobalData.save_resource(
				GlobalData.get_dirpath_user(),
				"resource_new.tres",
				Resource.new()
			)
		else:
			_new_res = GlobalData.load_resource(sample_path)


# custom manual testing part 2
# save file 'gameDataContainer' testing
func _global_data_test_game_data_container():
	var datacon_dir: String = GlobalData.get_dirpath_user()+"saves/"
	var datacon_file := "save1.tres"
	if not GlobalData.validate_file(datacon_dir+datacon_file):
		test_save(GameDataContainer.new(), datacon_dir, datacon_file)
	var get_save_res = test_load(datacon_dir, datacon_file, GameDataContainer)
	if get_save_res != null:
		if "get_class" in get_save_res:
			get_save_res.get_class()
		print("is save a datacon? ", (get_save_res is GameDataContainer))
		print(get_save_res)
		if "example_float_data" in get_save_res:
			var get_float_data = get_save_res.example_float_data
			print(get_float_data)
			var increase: float = 2.70
			print("incrementing float by {inc}, ({old}+{inc}={new})".format({
				"old": get_float_data,
				"inc": increase,
				"new": (get_float_data+increase),
			}))
			# now save it to file
			get_save_res.example_float_data = get_float_data+increase
			test_save(get_save_res, datacon_dir, datacon_file)


##############################################################################


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

