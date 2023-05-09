#extends UnitTest

#class_name UnitTestName

##############################################################################

# Unit tests should be extensions of the node class, named for the class and
# class feature they are testing, e.g. if the test were for the Node class
# and 'add_child' method, a good name would be 'test_node_add_child'.

# All tests should have the following methods and properties.

# void ready_test({property_name: property_value, ...})
# bool start_test()

# bool is_test_readied [default: false]
# bool test_unreadied_after_iteration [default: false]
# int test_iteration_maximum [default: 1]
# int test_iteration_total [default: 0]


##############################################################################

# properties exist in a parent

#export(bool) var is_test_readied := false
#export(bool) var test_unreadied_after_iteration := false
#export(int) var test_iteration_maximum := 1

#var test_iteration_total: int = 0

##############################################################################

# public methods


# the ready_test method sets properties on the test according to the
# dictionary argument provided (where keys correspond to property names on
# the test and paired values set the values of the test properties).
# ready_test should be called if the test needs specific properties set
# before the test begins, or if test_unreadied_after_iteration is set and
# the test has previously run
# calling ready_test sets is_test_readied to true
# if is_test_readied is false the test will not run, but it can be set to
# default to true for tests that do not require preset properties
# shadowed method
#func ready_test(_property_register: Dictionary) -> void:
#	.ready_test(_property_register)


# the start_test method is called by the scene running the test (which should
# have the test as a preloaded object)
# if is_test_readied is false, or if test_iteration_total equals/exceeds
# test_iteration_maximum,  nothing will happen
# shadowed method
#func start_test() -> bool:
#	is_test_readied = false
#	return true


##############################################################################

# private methods


#func _private_test_method():
#	pass

