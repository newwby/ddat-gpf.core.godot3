extends GameGlobal

#class_name GlobalFunc

##############################################################################

# GlobalFunctions

#//TODO
# need to move to ddat-gpf.core

##############################################################################

signal node_reparented(node)

##############################################################################


# return argument depends on passed 'is_added' argument
# returns true on (is_added==true) if connection was added or already existed
# returns true on (is_added==false) if connection was removed or didn't exist
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
		


##############################################################################

