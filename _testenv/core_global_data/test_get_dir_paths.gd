extends UnitTest

class_name UnitTestGetDirPaths

##############################################################################
	
var toplevel_test_path = "user://unit_test/get_dir_paths"

var top_subdirectory_paths := [
	toplevel_test_path+"/getdirpath_testdir_1",
	toplevel_test_path+"/getdirpath_testdir_2",
	toplevel_test_path+"/getdirpath_testdir_3",
	]
	
var other_subdirectory_paths := [
	toplevel_test_path+"/getdirpath_testdir_1/subdir1a",
	toplevel_test_path+"/getdirpath_testdir_1/subdir1b",
	toplevel_test_path+"/getdirpath_testdir_2/subdir2a",
	]

onready var all_test_dir_paths :=\
		top_subdirectory_paths+other_subdirectory_paths

##############################################################################


func ready_test(_property_register: Dictionary) -> void:
	is_test_readied = _validate_test_directories()


# public methods
func start_test() -> bool:
	if not is_test_readied:
		GlobalLog.warning(self, "test could not start")
		return false
	var test_outcome := true
	# console line break before log
	print()
	GlobalLog.trace(self, "test start")
	
	var is_terminating_test_valid := _return_test(false)
	var is_recursive_test_valid := _return_test(true)
	
	GlobalLog.info(self, "test {0} outcome = {1}".format([
		"is_terminating_test_valid", is_terminating_test_valid]))
	GlobalLog.info(self, "test {0} outcome = {1}".format([
		"is_recursive_test_valid", is_recursive_test_valid]))
	
	GlobalLog.trace(self, "final test outcome: {0}".format([test_outcome]))
	is_test_readied = false
	test_iteration_total += 1
	return test_outcome


##############################################################################

# private methods


func _validate_test_directories() -> bool:
	var full_path = ""
	var dir_access = Directory.new()
	var ready_state = true
	for path in all_test_dir_paths:
#		GlobalLog.info(self, path)
		full_path = path
		if not dir_access.dir_exists(full_path):
			dir_access.make_dir_recursive(full_path)
		if not dir_access.dir_exists(full_path):
			ready_state = false
	return ready_state


func _return_test(arg_is_recursive: bool) -> bool:
	GlobalLog.info(self, "start test, is_recursive: "+str(arg_is_recursive))
	var dirpaths = GlobalData.get_dir_paths(
			toplevel_test_path, arg_is_recursive)
	var path_comparison = true
	var paths_to_compare =\
			all_test_dir_paths if arg_is_recursive else top_subdirectory_paths
	GlobalLog.info(self, "comparison paths = \n"+str(paths_to_compare))
	for path in paths_to_compare:
		if not path in dirpaths:
			GlobalLog.info(self, str(path)+" not found in comparison paths")
			path_comparison = false
		else:
			GlobalLog.info(self, str(path)+" found")
	
	return path_comparison
