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


# ensures a specific signal connection exists between sender and target
# returns OK if connection exists or is created
# returns ERR if the connection cannot be found and is not succesfully made
func confirm_connection(
		origin: Object,
		signal_name: String,
		target: Object,
		method_name: String,
		binds: Array = [],
		flags: int = 0
		):
	if (origin == null) or (target == null):
		return ERR_INVALID_PARAMETER
	var return_code := ERR_CANT_CONNECT
	if origin.is_connected(signal_name, target, method_name):
		return_code = OK
	else:
		return_code =\
				origin.connect(signal_name, target, method_name, binds, flags)
	return return_code


# ensures a specific signal connection does not exist between sender and target
# returns OK if connection exists or is created
# returns ERR if the connection cannot be found and is not succesfully made
func confirm_disconnection(
		origin: Object,
		signal_name: String,
		target: Object,
		method_name: String
		):
	if (origin == null) or (target == null):
		return ERR_INVALID_PARAMETER
	if origin.is_connected(signal_name, target, method_name):
		origin.disconnect(signal_name, target, method_name)
	if (origin.is_connected(signal_name, target, method_name) == false):
		return OK
	else:
		return ERR_CANT_RESOLVE


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

