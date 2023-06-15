extends UnitTest

class_name UnitTest_InstanceFromName

##############################################################################

# specific test properties

##############################################################################

# public methods


# add any logic that needs to run before test here
# by default this method is called by start_test() before _do_test()
func ready_test() -> void:
	# at all branch ends make sure is_test_readied is set true or false
	# by default a test will not run if is_test_readied == false
	is_test_readied = true


##############################################################################

# private methods


# add your test logic here, just make sure it returns test outcome as bool
func _do_test() -> bool:
	var test_outcome := true
	
	var expected_resource = GlobalFunc.instance_from_name("Resource")
	var expected_node2d =  GlobalFunc.instance_from_name("Node2D")
	var expected_gamedatacon = GlobalFunc.instance_from_name("GameDataContainer")
	var expected_conditional = GlobalFunc.instance_from_name("Conditional")
	
	GlobalLog.info(self, expected_resource)
	GlobalLog.info(self, expected_node2d)
	GlobalLog.info(self, expected_gamedatacon)
	GlobalLog.info(self, expected_conditional)
	
	test_outcome = test_outcome\
			and (expected_resource is Resource)\
			and (expected_node2d is Node2D)\
			and (expected_gamedatacon is GameDataContainer)\
			and (expected_conditional is Conditional)
	
	if not expected_resource is Resource:
		GlobalLog.error(self, "not expected_resource is Resource")
	if not expected_node2d is Node2D:
		GlobalLog.error(self, "not expected_node2d is Node2D")
	if not expected_gamedatacon is GameDataContainer:
		GlobalLog.error(self, "not expected_gamedatacon is GameDataContainer")
	if not expected_conditional is Conditional:
		GlobalLog.error(self, "not expected_conditional is Conditional")
	
	return test_outcome


#func _private_test_method():
#	pass

