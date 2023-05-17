extends Node2D

#onready var unit_test_get_dir_paths = $UnitTestGetDirPaths
#onready var unit_test_save_resource = $UnitTestSaveResource

func _ready():
	var all_tests = get_children()
	var multitest_array = []
	for testobj in all_tests:
		if testobj is UnitTest:
			if testobj.is_test_readied == false:
				testobj.ready_test()
			if testobj.is_test_readied:
				multitest_array.append(testobj)
	var _discard_result = UnitTest.multitest(multitest_array)

#	var test_path = "res://def/dev/"
#	var gdrtest_terminating = GlobalData.get_dir_paths(test_path)
#	var gdrtest_recursive = GlobalData.get_dir_paths(test_path, true)
#	GlobalLog.trace(self, "gdrtest_terminating = "+str(gdrtest_terminating))
#	GlobalLog.trace(self, "gdrtest_recursive = "+str(gdrtest_recursive))

