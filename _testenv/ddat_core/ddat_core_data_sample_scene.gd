extends Node2D

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# caution: running unit tests will push a lot of (intentional) errors
	_run_unit_tests(false)
	
	# run manual tests
	var run_manual_tests = false
	if run_manual_tests:
		_manualtest_datamgr_resource()
		_manualtest_datamgr_game_data_container()


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
func _manualtest_datamgr_resource():
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
func _manualtest_datamgr_game_data_container():
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


# holder of unit tests in this sample scene
func _run_unit_tests(do_tests: bool = false):
	var run_unit_tests = do_tests
	print("run unit tests = ", run_unit_tests)
	if run_unit_tests:
		var unit_test_record = {
			"save_resource_path_to_user_data":
				_unit_test_save_resource_path_to_user_data(),
			"load_invalid_resource_path":
				_unit_test_load_invalid_resource_path(),
			"save_and_load_resource":
				_unit_test_save_and_load_resource()
		}
		for test_id in unit_test_record:
			print("running test {x}, result = {r}".format({
				"x": test_id,
				"r": unit_test_record[test_id]
			}))


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


#// TODO - create a resource with a custom value,
#	save it to disk, then attempt to load it
func _unit_test_save_and_load_resource():
	pass
