extends UnitTest

class_name UnitTest_GetInheritedClasses

##############################################################################

# THIS TEST ASSUMES INSTANCE FROM NAME TEST WORKS

# Do not provide this test with low-level inbuilt classes such as Object,
#	Reference, Resource, Node, Node2D, Node3D etc
# Anything with a great deal of inheritors is going to logspam due to
#	'can this object instance' checks

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
	GlobalLog.info(self, "WARNING: This test assumes UnitTest_InstanceFromName works")
	
	var test_outcome := true
	var inheritance_test_outcome := true
	var test_pairs = [
		["GameDataContainer", GameDataContainer],
		["Conditional", Conditional],
		["CanvasItem", CanvasItem],
#		["Node2D", Node2D],
#		["Reference", Reference],
	]
	
	for pair in test_pairs:
		inheritance_test_outcome = _unit_test_inheritance(pair[0], pair[1])
		test_outcome = test_outcome and inheritance_test_outcome
	
	return test_outcome


# if inbuilt class it must be a class that can be instanced
# if not inbuilt class it is valid
func _is_class_valid_for_test(arg_class_name: String):
	if ClassDB.class_exists(arg_class_name):
		return ClassDB.can_instance(arg_class_name)
	else:
		return true


# all objects should pass an 'is x type' test
# first arg should be class name as string, second should just be class
func _unit_test_inheritance(arg_test_name: String, arg_class) -> bool:
	if not _is_class_valid_for_test(arg_test_name):
		GlobalLog.warning(self, arg_test_name+" not valid for test, skipped")
		return true
	var test_object = GlobalFunc.instance_from_name(arg_test_name)
	if test_object == null:
		GlobalLog.error(self, "test_object == null")
		return false
	var all_inherited_classes = GlobalFunc.get_inheritance_from_name(arg_test_name)
	GlobalLog.info(self, arg_test_name+" is base of: "+str(all_inherited_classes))
	var sample_object
	for inherited_class_name in all_inherited_classes:
		if not _is_class_valid_for_test(inherited_class_name):
			GlobalLog.warning(self, inherited_class_name+" not valid for comparison, skipped")
			continue
		sample_object = GlobalFunc.instance_from_name(inherited_class_name)
		if sample_object == null:
			GlobalLog.error(self, "sample_object for class {0} == null".format([
					inherited_class_name]))
			return false
		if not sample_object is arg_class:
			GlobalLog.error(self, "sample_object is not test class".format([
					inherited_class_name]))
			return false
	return true

