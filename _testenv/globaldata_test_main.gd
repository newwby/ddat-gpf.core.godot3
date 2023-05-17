extends Node2D

onready var unit_test_get_dir_paths = $UnitTestGetDirPaths

func _ready():
	unit_test_get_dir_paths.ready_test()
	unit_test_get_dir_paths.start_test()

#	var test_path = "res://def/dev/"
#	var gdrtest_terminating = GlobalData.get_dir_paths(test_path)
#	var gdrtest_recursive = GlobalData.get_dir_paths(test_path, true)
#	GlobalLog.trace(self, "gdrtest_terminating = "+str(gdrtest_terminating))
#	GlobalLog.trace(self, "gdrtest_recursive = "+str(gdrtest_recursive))

