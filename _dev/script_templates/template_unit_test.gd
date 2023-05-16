extends UnitTest

#class_name UnitTestName

##############################################################################

# properties exist in a parent

#export(bool) var is_test_readied := false
#export(bool) var test_unreadied_after_iteration := false
#export(int) var test_iteration_maximum := 1

#var test_iteration_total: int = 0

##############################################################################


func ready_test(property_register: Dictionary) -> void:
	.ready_test(property_register)


# public methods
func start_test() -> bool:
	if not is_test_readied:
		GlobalLog.warning(self, "test could not start")
		return false
	var test_outcome := false
	# console line break before log
	print()
	GlobalLog.trace(self, "test start")
	
	# put test logic here
	
	GlobalLog.trace(self, "final test outcome: {0}".format([test_outcome]))
	is_test_readied = false
	test_iteration_total += 1
	return test_outcome


##############################################################################

# private methods


#func _private_test_method():
#	pass

