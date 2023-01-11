extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	var get_test_path = GlobalData.get_dirpath_user()
#	var get_test_path = GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.USER]
	get_test_path += "test/test2/test3/test4/"
	var file_name = "res.tres"
	var return_arg = GlobalData.save_resource(get_test_path, file_name, Resource.new())
	if return_arg != OK:
		print(return_arg)


# paths must begin with user://
# test by sending invalid paths
func _unit_test_save_resource_path_to_user_data() -> bool:
	var get_results = []
	get_results.append(GlobalData.save_resource("test.txt", "", Resource.new()))
	get_results.append(GlobalData.save_resource("get_user", "", Resource.new()))
	get_results.append(GlobalData.save_resource("user:/", "", Resource.new()))
	get_results.append(GlobalData.save_resource("usr://", "", Resource.new()))
	# every result should be invalid
	for result in get_results:
		if result == OK:
			return false
	# if loop through safely, all results were invalid
	return true


#func old2():
#	pass # Replace with function body.
#	GlobalData.save_gdc()
#	var new_res = GlobalData.load_gdc()
#	print(new_res)
#	if "get_class" in new_res:
#		print("get_class"+" = ", new_res.get_class())
#	else:
#		print("get_class", " not found")
#	if "get_property_list" in new_res:
#		print("get_property_list"+" = ", new_res.get_property_list())
#	else:
#		print("get_property_list", " not found")
#	if new_res is Resource:
#		print("new res is resource")
#	else:
#		print("new res not resource")
#	if new_res is GameDataContainer:
#		print("new res is game data cotnainer")
#	else:
#		print("new res is not game data container")
#
#	if "example_int_data" in new_res:
#		print("example_int_data"+" = ", new_res.example_int_data)
#	if "example_float_data" in new_res:
#		print("example_float_data"+" = ", new_res.example_float_data)
#	if "example_bool_data" in new_res:
#		print("example_bool_data"+" = ", new_res.example_bool_data)
	
	
	

#func old():
#	GlobalData.save_to_file()
#	var c = GlobalData.load_from_file()
#	print(c.get_class())
#	print(c.is_class("Node"))
##	print(c.is_class("CustomObject"))
#	print(c is CustomObject)
#	if c is CustomObject:
#		c.say_hello()
#	else:
#		print("inval obj")
#	if c != null:
#		if c.has_method("say_hello"):
#			c.say_hello()
#		if c.has_method("get_property_list"):
#			for prop in c.get_property_list():
#				print(prop)
##			print(c.get_property_list())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
