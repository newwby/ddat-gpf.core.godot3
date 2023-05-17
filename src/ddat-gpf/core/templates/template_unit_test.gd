extends UnitTest

#class_name UnitTestName

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
	var test_outcome := false
	return test_outcome

