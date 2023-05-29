extends UnitTest

class_name UnitTestLogging

##############################################################################

# the following properties exist in a parent

#export(bool) var is_test_readied := false
#export(bool) var test_unreadied_after_iteration := false
#export(bool) var call_ready_on_start := true
#export(int) var test_iteration_maximum := 1

#var test_iteration_total: int = 0

##############################################################################


# shadowed method
# if your test needs properties set or things done beforehand, add them here
func ready_test() -> void:
	# is_test_readied = true
	.ready_test()


##############################################################################

# private methods


# this is where you should add your test logic
# it should always return a bool
func _do_test() -> bool:
	var test_outcome := true
	
	# NOTE: this test pushes to debugger multiple times, this is expected
	
	# these conditions should be true for the test to proceed
	assert(GlobalLog.WARNINGS_PRINT_TO_CONSOLE == true)
	assert(GlobalLog.ERRORS_PRINT_TO_CONSOLE == true)
	
	# test print strings
	var no_push := "output to console"
	var push := "push to debugger or output to console"
	var fail := "should not "
	var block := "test block 1: "
	
	print("\n"+block+" starting now")
	# should push error and output to console
	GlobalLog.error(self, block+push)
	# should push warning and output to console
	GlobalLog.warning(self, block+push)
	# should output to console
	GlobalLog.trace(self, block+no_push)
	GlobalLog.info(self, block+no_push)
	
	block = "test block 2: "
	print("\n"+block+" starting now")
	GlobalLog.change_log_permissions(self, false)
	# should not push error or output to console
	GlobalLog.error(self, block+fail+push)
	# should not push warning or output to console
	GlobalLog.warning(self, block+fail+push)
	# should not output to console
	GlobalLog.trace(self, block+fail+no_push)
	GlobalLog.info(self, block+fail+no_push)
	
	block = "test block 3: "
	print("\n"+block+" starting now")
	GlobalLog.change_log_permissions(self, null)
	# should push error and output to console
	GlobalLog.error(self, block+push)
	# should push warning and output to console
	GlobalLog.warning(self, block+push)
	# should output to console
	GlobalLog.trace(self, block+no_push)
	GlobalLog.info(self, block+no_push)
	
	block = "test block 4: "
	print("\n"+block+" starting now")
	# should not push error or output to console
	GlobalLog.error(self, block+fail+push, true)
	# should not push warning or output to console
	GlobalLog.warning(self, block+fail+push, true)
	# should not output to console
	GlobalLog.trace(self, block+fail+no_push, true)
	GlobalLog.info(self, block+fail+no_push, true)
	
	block = "test block 5: "
	print("\n"+block+" starting now")
	GlobalLog.change_log_permissions(self, true)
	# should push error and output to console
	GlobalLog.error(self, block+push, true)
	# should push warning and output to console
	GlobalLog.warning(self, block+push, true)
	# should output to console
	GlobalLog.trace(self, block+no_push, true)
	GlobalLog.info(self, block+no_push, true)
	
	# this test just performs logging to see if it outputs at all
	# check the console log for presence of above log statements
	GlobalLog.trace(self, "TEST INCONCLUSIVE - MANUALLY CHECK TEST STATE")
	return test_outcome

