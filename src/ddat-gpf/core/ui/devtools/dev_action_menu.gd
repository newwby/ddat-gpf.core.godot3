extends Control

#class_name DevActionMenu

##############################################################################

# DevActionMenu

##############################################################################

# OVERVIEW
# DevCommands are added with GlobalDebug.add_dev_command which passes via a
#	signal to the devActionMenu
#	signal passes args (caller_ref, button_name, caller_method)
#	as with debugoverlay, uses the ref as a key and creates a devActionMenu
#	object as value; the object has ref to the button (created on next idle
#	frame, before the devActionMenu object), the caller, and the method
#	when button is clicked it calls the method on the caller

# DevCommands automatically connect to caller tree exit and remove themselves
#		if the caller exits the tree
# Devs should use node-extended scripts in the scene tree storing their
#	devActionMenu scripts (and include this in sample project) but any node
#	can add an action button in this way

#//TODO
# Autoclose on dev action button selection
# Optional close menu button functionality

# Command button (different to overlay, F2 project default) to bring up
# devActionMenu; working send command button and close menu button

# Text Commands with send command button; DevCommands can also be accessed
#	by string and the button does not have to be added

# set up style resource/s for the buttons
# set up font resource for the buttons

# automatically generated button margins and panel sizees

# Margin/PanelMargin/VBox/ActionButtonContainer needs to dynamically determine
#	number of columns based on Margin/PanelMargin/VBox size and button width

##############################################################################

onready var margin_node = $Margin

##############################################################################

# classes


# data container
class ActionMenuItem:
	
	var key := ""
	var button_node_ref: Button = null setget _set_button_node_ref
	var caller_node_ref: Node = null
	var caller_method_name := ""
	var is_valid := false
	var in_tree := false
	var waiting_to_join_tree := false
	
	func _init(
			arg_key: String = "",
			arg_button_node_ref: Button = null,
			arg_caller_node_ref: Node = null,
			arg_caller_method_name := ""):
		if arg_key == null\
		or arg_button_node_ref == null\
		or arg_caller_node_ref == null\
		or arg_caller_method_name == "":
			is_valid = false
		else:
			self.key = arg_key
			self.button_node_ref = arg_button_node_ref
			self.caller_node_ref = arg_caller_node_ref
			self.caller_method_name = arg_caller_method_name
			is_valid = true
	
	
	# when button is set, setup automatic behaviour for button pressing and
	#	disabling call functionality if button exits the tree
	func _set_button_node_ref(arg_value: Button):
		button_node_ref = arg_value
		if button_node_ref != null:
			if button_node_ref.is_inside_tree() == false:
				waiting_to_join_tree = true
				yield(button_node_ref, "tree_entered")
				waiting_to_join_tree = false
			var signal_check_1 = GlobalFunc.confirm_connection(
						button_node_ref, "pressed", self, "_on_button_pressed")
			var signal_check_2 = GlobalFunc.confirm_connection(
						button_node_ref, "tree_entered", self, "_on_button_enter_or_exit_tree")
			var signal_check_3 = GlobalFunc.confirm_connection(
						button_node_ref, "tree_exited", self, "_on_button_enter_or_exit_tree")
			# check signals connected
			if (signal_check_1+signal_check_2+signal_check_3) != OK:
				GlobalLog.error(self, "button {0} setup invalid, ERR {1}-{2}-{3}".format([
						button_node_ref, signal_check_1, signal_check_2, signal_check_3]))
			in_tree = button_node_ref.is_inside_tree()
	
	
	func _on_button_enter_or_exit_tree():
		in_tree = button_node_ref.is_inside_tree()
	
	
	# returns whether the call was successful (whether the method does
	#	anything or not)
	# method 'call_dev_action'
	func _on_button_pressed() -> int:
		if is_valid == false:
			return ERR_UNCONFIGURED
		if caller_node_ref == null:
			return ERR_INVALID_PARAMETER
		if caller_node_ref.is_inside_tree() == false:
			return ERR_DOES_NOT_EXIST
		if caller_node_ref.has_method(caller_method_name) == false:
			return ERR_METHOD_NOT_FOUND
		else:
			caller_node_ref.caller_method_name()
			return OK


##############################################################################


func _ready():
	_setup_viewport_responsiveness()
	_on_viewport_resized()


func _on_viewport_resized():
	margin_node.rect_size = margin_node.get_viewport_rect().size


func _setup_viewport_responsiveness():
	# set up handling for if viewport resizes
	var viewport_root: Viewport = get_viewport()
	if viewport_root != null:
		var signal_outcome = OK
		signal_outcome = viewport_root.connect("size_changed", self, "_on_viewport_resized")
		if signal_outcome != OK:
			GlobalLog.error(self, "DebugOverlay err setup _on_viewport_resized")


##############################################################################


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

