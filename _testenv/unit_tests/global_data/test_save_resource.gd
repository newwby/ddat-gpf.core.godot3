extends UnitTest

#class_name UnitTestSaveResource

##############################################################################

var ext_save_attempt_file_paths = [
	"user://unit_test/save_resource/testsave1.tres",
	"user://unit_test/save_resource/testsave2.tres",
	"user://unit_test/save_resource/testsave3.tres"
]

##############################################################################


# shadowed method
# if your test needs properties set or things done beforehand, add them here
func ready_test() -> void:
	var test_setup_checks := true
	for file_path in ext_save_attempt_file_paths:
		if GlobalData.validate_file(file_path):
			var dir_accessor = Directory.new()
			dir_accessor.remove(file_path)
			if GlobalData.validate_file(file_path):
				test_setup_checks = false
	is_test_readied = test_setup_checks
	GlobalLog.info(self, "is test readied? {0}".format([is_test_readied]))


##############################################################################

# private methods


# this is where you should add your test logic
# it should always return a bool
func _do_test() -> bool:
	var test_outcome := false
	var are_invalid_paths_allowed := _invalid_ext_save_attempt_tests()
	var is_save_resource_working := _valid_ext_save_attempt_tests()
	GlobalLog.info(self, "test {name} = {result}".format({
		"name": "are_invalid_paths_allowed",
		"result": are_invalid_paths_allowed
	}))
	GlobalLog.info(self, "test {name} = {result}".format({
		"name": "is_save_resource_working",
		"result": is_save_resource_working
	}))
	test_outcome =\
			(true and are_invalid_paths_allowed and is_save_resource_working)
	return test_outcome


# check can't pass invalid or incomplete arguments to save_resource
func _invalid_ext_save_attempt_tests() -> bool:
	# block logging before starting error logspam, revert after
	var gdata_can_log: bool = GlobalLog.get_log_permissions(GlobalData)
	GlobalLog.change_log_permissions(GlobalData, false)
	var get_results = []
	get_results.append(GlobalData.save_resource("test.txt", Resource.new()))
	get_results.append(GlobalData.save_resource("get_user", Resource.new()))
	get_results.append(GlobalData.save_resource("user:/", Resource.new()))
	get_results.append(GlobalData.save_resource("usr://", Resource.new()))
	# revert permission
	GlobalLog.change_log_permissions(GlobalData, gdata_can_log)
	# every result should be invalid
	for result in get_results:
		if result == OK:
			return false
	# if loop through safely, all results were invalid
	return true


func _valid_ext_save_attempt_tests() -> bool:
	var test_state := true
	for file_path in ext_save_attempt_file_paths:
		GlobalData.save_resource(file_path, GameDataContainer.new())
		if not GlobalData.validate_file(file_path):
			test_state = false
	return test_state

