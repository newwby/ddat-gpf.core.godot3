extends Node2D

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# caution: running unit tests will push a lot of (intentional) errors
	_run_unit_tests(true)
	
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


#// can extend this into a unit test by
# - validating or creating testing directory and files at start
# - turning below logic into a loop
#func _manualtest_datamgr_get_paths():
#	var path = GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.GAME_SAVE]
#
#	var get_files = GlobalData.get_file_paths(path)
#	print("test1", " expected return", get_files)
#	print("#\n")
#
#	get_files = GlobalData.get_file_paths(path, "egg")
#	print("test2", " expected fail", get_files)
#	print("#\n")
#
#	get_files = GlobalData.get_file_paths(path, "sav")
#	print("test3", " expected return", get_files)
#	print("#\n")
#
#	get_files = GlobalData.get_file_paths(path, "", ".res")
#	print("test4", " expected fail", get_files)
#	print("#\n")
#
#	get_files = GlobalData.get_file_paths(path, "", ".tres")
#	print("test5", " expected return", get_files)
#	print("#\n")
#
#	get_files = GlobalData.get_file_paths(path, "", "", "save")
#	print("test6", " expected fail", get_files)
#	print("#\n")
#
#	get_files = GlobalData.get_file_paths(path, "", "", "buttermilk")
#	print("test7", " expected return", get_files)
#	print("#")



##############################################################################


# holder of unit tests in this sample scene
func _run_unit_tests(do_tests: bool = false):
	var run_unit_tests = do_tests
	print("run unit tests = ", run_unit_tests)
	if run_unit_tests:
		# temporarily removed path_to_user_data and resource_path
		# as they push too many errors
		var unit_test_record = {
#			"save_resource_path_to_user_data":
#				_unit_test_save_resource_path_to_user_data(),
#			"load_invalid_resource_path":
#				_unit_test_load_invalid_resource_path(),
			"save_and_load_resource":
				_unit_test_save_and_load_resource(),
			"_unit_test_get_paths_main":
				_unit_test_get_paths_main()
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


# unit test for different inputs to the globalData.get_path method
# this unit test will rewrite the directory/files each time
func _unit_test_get_paths_main():
	# start test by validating (and writing if messing) the test files
	var test_save_path := "user://unit_test/get_paths/"
	var test_file_1 := "file1.tres"
	var test_file_2 := "file2.tres"
	var test_file_3 := "file3.tres"
	
	# make sure this directory and these files exist
	# create directory return error and breaks if directory found, so ignore
	#//UPDATE directory creation removed as is handled by save_resource
#	var _discard = GlobalData.create_directory(test_save_path)

	# validating files is important
	if GlobalData.save_resource(
			test_save_path, test_file_1, Resource.new()) != OK:
		print("test setup error 1")
		return
	if GlobalData.save_resource(
			test_save_path, test_file_2, Resource.new()) != OK:
		print("test setup error 2")
		return
	if GlobalData.save_resource(
			test_save_path, test_file_3, Resource.new()) != OK:
		print("test setup error 3")
		return
	
	var expected_result_full: PoolStringArray = [
		(test_save_path+test_file_1),
		(test_save_path+test_file_2),
		(test_save_path+test_file_3)
	]
	var expected_result_partial1: PoolStringArray = [
		(test_save_path+test_file_1)
	]
#	var expected_result_partial2 := [
#		(test_save_path+test_file_1),
#		(test_save_path+test_file_3)
#	]
	var expected_result_empty: PoolStringArray = []
	
	
	# run unit tests,
	# compare expected result vs actual result as a bool
	# then compare the bool against result so a single false fails the tests
	var unit_result := true
	var end_result := true
	var expected_result: PoolStringArray = []
	var get_file_paths_result: PoolStringArray = []
	var test_id := 0
	print("beginning tests for _unit_test_get_paths_main")
	
	# test get_file_paths works
	get_file_paths_result = GlobalData.get_file_paths(test_save_path)
	expected_result = expected_result_full
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	#// GlobalDebug need a minor logging method
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))

	# test for whether prefix req works (files should start w/'file')
	get_file_paths_result = GlobalData.get_file_paths(test_save_path, "file")
	expected_result = expected_result_full
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))
	
	# test for whether prefix req works (files should not start w/'roar')
	get_file_paths_result = GlobalData.get_file_paths(test_save_path, "roar")
	expected_result = expected_result_empty
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))
	
	# test for whether suffix req works (files should end in .tres)
	get_file_paths_result = GlobalData.get_file_paths(test_save_path, "", ".tres")
	expected_result = expected_result_full
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))
	
	# test for whether suffix req works (files should not end in .save)
	get_file_paths_result = GlobalData.get_file_paths(test_save_path, "", ".save")
	expected_result = expected_result_empty
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))
	
	# test for whether force exclude works (files should not include '2' or '3')
	get_file_paths_result = GlobalData.get_file_paths(test_save_path, "", "", ["2", "3"])
	expected_result = expected_result_partial1
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))
	
	# test for whether force include works (files should include '1')			
	get_file_paths_result = GlobalData.get_file_paths(test_save_path, "", "", [], ["1"])
	expected_result = expected_result_partial1
	unit_result = (expected_result == get_file_paths_result)
	end_result = (end_result and unit_result)
	test_id += 1
	print("test no.{n} = {r}! \nexpected {e}, \noutcome {o}\n".format({
		"n": test_id,
		"r": unit_result,
		"e": expected_result,
		"o": get_file_paths_result
	}))
	
#	print("_unit_test_get_paths_main, final outcome = ", end_result)
	# end unit test
	return end_result



