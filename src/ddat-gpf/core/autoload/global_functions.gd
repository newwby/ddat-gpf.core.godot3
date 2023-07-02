extends GameGlobal

#class_name GlobalFunc

##############################################################################

# GlobalFunctions

#//TODO
# change to globalfunc.gd not globalfunctions
# confirm connection/disconnection need return -> values

##############################################################################

signal node_reparented(node)

##############################################################################

# public


# ensures a specific signal connection exists between sender and target
# logs warnings if signals are not correct
# returns OK if connection exists or is created
# returns ERR if the connection cannot be found and is not succesfully made
func confirm_connection(
		arg_origin: Object,
		arg_signal_name: String,
		arg_target: Object,
		arg_method_name: String,
		binds: Array = [],
		flags: int = 0
		):
	# validate
	if _confirm_connect_args(arg_origin, arg_signal_name, arg_target, arg_method_name) != OK:
		return ERR_INVALID_PARAMETER
	# run connection, get outcome
	var return_code := ERR_CANT_CONNECT
	if arg_origin.is_connected(arg_signal_name, arg_target, arg_method_name):
		return_code = OK
	else:
		return_code =\
				arg_origin.connect(arg_signal_name, arg_target, arg_method_name, binds, flags)
	
	# return and log
	if return_code != OK:
		GlobalLog.warning(arg_origin,
				"confirm_connection: {0} not connected to {1}.{2}".format(
				[arg_signal_name, arg_target, arg_method_name]))
	return return_code


# ensures a specific signal connection does not exist between sender and target
# logs warnings if signals are not correct
# returns OK if connection exists or is created
# returns ERR if the connection cannot be found and is not succesfully made
func confirm_disconnection(
		arg_origin: Object,
		arg_signal_name: String,
		arg_target: Object,
		arg_method_name: String
		):
	# validate
	if _confirm_connect_args(arg_origin, arg_signal_name, arg_target, arg_method_name) != OK:
		return ERR_INVALID_PARAMETER
	# run disconnection, get outcome
	var return_code:= ERR_ALREADY_EXISTS
	if arg_origin.is_connected(arg_signal_name, arg_target, arg_method_name):
		arg_origin.disconnect(arg_signal_name, arg_target, arg_method_name)
	if (arg_origin.is_connected(arg_signal_name, arg_target, arg_method_name) == false):
		return_code = OK
	else:
		return_code = ERR_CANT_RESOLVE
	
	# return and log
	if return_code != OK:
		GlobalLog.warning(arg_origin,
				"confirm_disconnection: {0} not disconnected from {1}.{2}".format(
				[arg_signal_name, arg_target, arg_method_name]))
	return return_code


# DEPRECATED
# (see https://github.com/newwby/ddat-gpf.core/issues/10)
# Use the methods 'confirm_connection' or 'confirm_disconnection' instead
func confirm_signal(
		is_added: bool,
		sender: Node,
		recipient: Node,
		signal_string: String,
		method_string: String
		) -> bool:
	#
	var signal_return_state := false
	var signal_modify_state := OK
	#
	if is_added:
		# on (is_added == true)
		# if signal connection already exists or was successfully added,
		# return true
		if not sender.is_connected(signal_string, recipient, method_string):
			signal_modify_state =\
					sender.connect(signal_string, recipient, method_string)
			# signal didn't exist so must be connected for return state to be valid
			signal_return_state = (signal_modify_state == OK)
		# if already connected under (is_added == true), is valid
		else:
			signal_return_state = true
	#
	elif not is_added:
		# on (is_added == false)
		# if signal connection does not already exist or was successfully
		# removed, return true
		if sender.is_connected(signal_string, recipient, method_string):
			sender.disconnect(signal_string, recipient, method_string)
			# no err code return on disconnect, so assume successful
			signal_return_state = true
		# if not already connected under (is_added == false), is valid
		else:
			signal_return_state = true
		
	return signal_return_state


# from a given class name finds every class (including custom classes) that
#	directly or indirectly inherits from that class
# will return an empty poolStringArray if nothing is found
func get_inheritance_from_name(
			arg_class_name: String) -> PoolStringArray:
	# find inbuilt classes
	var output: PoolStringArray = []
	if ClassDB.class_exists(arg_class_name):
		output.append_array(ClassDB.get_inheriters_from_class(arg_class_name))
	# find custom classes
#	var class_sample = instance_from_name(arg_class_name)
#	if class_sample != null:
	# custom_classes is an array of dictionaries
	# each dict corresponds to a single class, with keys as follows
	# base:		string name of class it extends
	# class:	name of class (match to arg_class_name)
	# language:	script language class is written in (i.e. GDScript)
	# path:		local (res://) path to script
	var custom_classes: Array =\
			ProjectSettings.get_setting("_global_script_classes")
	var all_inheritors: PoolStringArray = [arg_class_name]
	if not custom_classes.empty():
		var loop_condition := false
		var starting_size = all_inheritors.size()
		# going to loop through the custom class dict-array repeatedly
		#	finding every class that either inherits from the base class
		#	argument, or from a class that inherits from a class that did,
		#	or a descendent of that, etc.
		#	loop breaks when new classes weren't found
		while loop_condition == false:
			starting_size = all_inheritors.size()
			for class_dict in custom_classes:
				assert(class_dict.has("base"))
				if class_dict["base"] in all_inheritors:
					var get_class_name = class_dict["class"]
					assert(typeof(get_class_name) == TYPE_STRING)
					if not get_class_name in all_inheritors:
						all_inheritors.append(get_class_name)
			loop_condition = (starting_size == all_inheritors.size())
	output.append_array(all_inheritors)
	return output


# pass a class name and returns an object of that type
# returns null if can't find object
func instance_from_name(arg_class_name: String) -> Object:
	# first check if is inbuilt class
	# (else check custom classes (see below ClassDB block))
	if ClassDB.class_exists(arg_class_name):
		if ClassDB.can_instance(arg_class_name):
			return ClassDB.instance(arg_class_name)
		else:
			GlobalLog.warning(self, arg_class_name+" is inbuilt but cannot instance")
			return null
	
	# custom_classes is an array of dictionaries
	# each dict corresponds to a single class, with keys as follows
	# base:		string name of class it extends
	# class:	name of class (match to arg_class_name)
	# language:	script language class is written in (i.e. GDScript)
	# path:		local (res://) path to script
	var custom_classes: Array =\
			ProjectSettings.get_setting("_global_script_classes")
	if not custom_classes.empty():
		for class_dict in custom_classes:
			if class_dict["class"] == arg_class_name:
				var script_path = class_dict["path"]
				if GlobalData.validate_file(script_path):
					var class_script = load(script_path)
					if class_script is Script:
						if class_script.has_method("new"):
							var class_object = class_script.new()
							return class_object
	# catchall
	return null


# as confirm_connection but sets and validates multiple connection pairs
# signal_name: method_name
# cannot handle binds or flags, use confirm_connection for that
func multi_connect(
		arg_origin: Object,
		arg_target: Object,
		arg_signal_method_pairs: Dictionary = {}) -> int:
	if arg_signal_method_pairs.empty():
		return ERR_DOES_NOT_EXIST
	# store all outputs
	var output: int = OK
	var end_output: int = OK
	var method_name: String = ""
	for signal_name in arg_signal_method_pairs.keys():
		method_name = arg_signal_method_pairs[signal_name]
		output = confirm_connection(arg_origin, signal_name, arg_target, method_name)
		if output != OK:
			GlobalLog.error(self,
					"[connect] {0} signal: {1} -> {2} method: {3} invalid".format([
					arg_origin, signal_name, arg_target, method_name]))
		end_output = end_output and output
	# if all were OK, this should be OK
	return end_output


# as confirm_disconnection but sets and validates multiple connection pairs
# signal_name: method_name
func multi_disconnect(
		arg_origin: Object,
		arg_target: Object,
		arg_signal_method_pairs: Dictionary = {}):
	if arg_signal_method_pairs.empty():
		return ERR_DOES_NOT_EXIST
	# store all outputs
	var output: int = OK
	var end_output: int = OK
	var method_name: String = ""
	for signal_name in arg_signal_method_pairs.keys():
		method_name = arg_signal_method_pairs[signal_name]
		output = confirm_disconnection(arg_origin, signal_name, arg_target, method_name)
		if output != OK:
			GlobalLog.error(self,
					"[disconnect] {0} signal: {1} -> {2} method: {3} invalid".format([
					arg_origin, signal_name, arg_target, method_name]))
		end_output = end_output and output
	# if all were OK, this should be OK
	return end_output


# allows configuring a target object's properties in a single call
func multiset_properties(arg_target: Object, arg_property_dict: Dictionary):
	if arg_property_dict.empty():
		return
	for property in arg_property_dict.keys():
		if typeof(property) != TYPE_STRING:
			GlobalLog.warning(self, [property, "invalid type"])
		if property in arg_target:
			# If the given value's type doesn't match no warning is logged.
			arg_target.set(property, arg_property_dict[property])
		else:
			GlobalLog.warning(self, [property, " not found"])


# method to move a node from beneath one node to another
# if not already inside tree (parent not found) will skip removing step
# will emit signal with node when finished, does not return as return
#	will be delayed with deferred remove/add steps; return signal will
#	include node as value if succesful, or null if not
# [parameters]
# #1, 'arg_target_node' - the node to be moved to a new parent; this node
#	can already have a parent or not even be in the scene tree
# #2, 'arg_new_parent' - the intended destination node to parent
#	arg_target_node beneath
func reparent_node(arg_target_node: Node, arg_new_parent: Node) -> void:
	var reparent_success := false
	# don't pass invalid parameters
	if arg_target_node == null or arg_new_parent == null:
		return
		# update for non-void return
#		return ERR_INVALID_PARAMETER
	# remove from initial parent, get target node out of SceneTree
	if arg_target_node.is_inside_tree():
		var old_parent_node = arg_target_node.get_parent()
		if old_parent_node != null:
			old_parent_node.call_deferred("remove_child", arg_target_node)
			yield(arg_target_node, "tree_exited")
	# add to new parent
	if not arg_target_node.is_inside_tree():
		if arg_new_parent.is_inside_tree():
			arg_new_parent.call_deferred("add_child", arg_target_node)
			yield(arg_target_node, "tree_entered")
			# confirm
			if arg_target_node.is_inside_tree():
				if arg_target_node.get_parent() == arg_new_parent:
					reparent_success = true
	# if succesful exit condition was reached
	if reparent_success:
		emit_signal("node_reparented", arg_target_node)
	else:
		emit_signal("node_reparented", null)


static func sort_ascending(arg_a, arg_b):
	if arg_a[0] < arg_b[0]:
		return true
	return false


static func sort_descending(arg_a, arg_b):
	if arg_a[0] < arg_b[0]:
		return false
	return true


##############################################################################

# private


# takes the main arguments from confirm_connection or confirm_disconnection
#	and returns whether they are valid
func _confirm_connect_args(
		origin: Object,
		signal_name: String,
		target: Object,
		method_name: String
		) -> int:
	if origin == null:
		GlobalLog.warning(self, "origin invalid")
		return ERR_INVALID_PARAMETER
	if target == null:
		GlobalLog.warning(self, "target invalid")
		return ERR_INVALID_PARAMETER
	if not origin.has_signal(signal_name):
		GlobalLog.warning(self, "origin signal invalid")
		return ERR_INVALID_PARAMETER
	if not target.has_method(method_name):
		GlobalLog.warning(self, "target method invalid")
		return ERR_INVALID_PARAMETER
	# else
	return OK

