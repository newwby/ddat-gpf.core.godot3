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

# Key : ActionMenuItem
var dev_action_register := {}

var is_command_line_focused := false
onready var margin_node = $Margin
onready var action_button_container_node = $Margin/PanelMargin/VBox/ActionButtonContainer
onready var command_line_node = $Margin/PanelMargin/VBox/CommandContainer/HBox/CommandLine
onready var default_dev_action_button_node = $DevActionButton

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
	var is_button_join_queued := false
	var is_console_command_allowed := false
	
	func _init(
			arg_key: String = "",
			arg_caller_node_ref: Node = null,
			arg_caller_method_name := "",
			arg_button_node_ref: Button = null):
		if arg_key == null\
		or arg_caller_node_ref == null\
		or arg_caller_method_name == "":
			is_valid = false
		else:
			self.key = arg_key
			self.caller_node_ref = arg_caller_node_ref
			self.caller_method_name = arg_caller_method_name
			self.button_node_ref = arg_button_node_ref
			is_valid = true
	
	
	# when button is set, setup automatic behaviour for button pressing and
	#	disabling call functionality if button exits the tree
	func _set_button_node_ref(arg_value: Button):
		# if button_node_ref is set whilst waiting for an orphaned button
		#	node to join the tree, the previous set attempt is halted
		if is_button_join_queued:
			is_button_join_queued = false
		
		if arg_value != null:
			if arg_value.is_inside_tree() == false:
				# wait for the orphaned button node to join tree
				is_button_join_queued = true
				yield(arg_value, "tree_entered")
				# if a new set was attempted during the wait, don't proceed
				if not is_button_join_queued:
					return
				is_button_join_queued = false
			
			var signal_check: int = OK
			
			if button_node_ref != null:
				# remove previous signals
				signal_check = GlobalFunc.multi_disconnect(button_node_ref, self,
						{"pressed": "_on_button_pressed",
						"tree_entered": "_on_button_enter_or_exit_tree",
						"tree_exited": "_on_button_enter_or_exit_tree"})
			# check signals connected
			if (signal_check) != OK:
				GlobalLog.error(self, "button {0} disconnect invalid, ERR {1}".format([
						button_node_ref, signal_check]))
			
			button_node_ref = arg_value
			
			# proceed with setting up signals
			signal_check = OK
			signal_check = GlobalFunc.multi_connect(button_node_ref, self,
					{"pressed": "_on_button_pressed",
					"tree_entered": "_on_button_enter_or_exit_tree",
					"tree_exited": "_on_button_enter_or_exit_tree"})
			# check signals connected
			if (signal_check) != OK:
				GlobalLog.error(self, "button {0} connect invalid, ERR {1}".format([
						button_node_ref, signal_check]))
			in_tree = button_node_ref.is_inside_tree()
	
	
	# returns whether the call was successful (whether the method does
	#	anything or not)
	# method 'call_dev_action'
	func run_command() -> int:
		if is_valid == false:
			GlobalLog.error(self, "dev action invalid")
			return ERR_UNCONFIGURED
		if caller_node_ref == null:
			GlobalLog.error(self, "dev action node ref null")
			return ERR_INVALID_PARAMETER
		if caller_node_ref.is_inside_tree() == false:
			GlobalLog.error(self, "dev action node ref outside tree")
			return ERR_DOES_NOT_EXIST
		if caller_node_ref.has_method(caller_method_name) == false:
			GlobalLog.error(self, "dev action method not found")
			return ERR_METHOD_NOT_FOUND
		else:
			caller_node_ref.caller_method_name()
			return OK
	
	
	func _on_button_enter_or_exit_tree():
		in_tree = button_node_ref.is_inside_tree()
	
	
	func _on_button_pressed():
		var _discard_return = run_command()


##############################################################################

# virt


func _ready():
#	default_dev_action_button_node.visible = false
#	self.visible = false
	_setup_viewport_responsiveness()
	_on_viewport_resized()
	#
	var signal_setup = GlobalFunc.confirm_connection(
			GlobalDebug, "add_dev_command",
			self, "_on_add_dev_command")
	if signal_setup != OK:
		GlobalLog.error(self, "error setting up devActionMenu GlobalDebug connection")


func _input(event):
	if event.is_action_pressed("ui_accept") and is_command_line_focused:
		_on_send_command_button_pressed()


##############################################################################

# public


#


##############################################################################

# private


func _on_add_dev_command(
		arg_key: String,
		arg_caller: Object,
		arg_caller_method: String,
		arg_add_menu_button: bool = true,
		arg_add_console_command: bool = true):
	var new_action_menu_item: ActionMenuItem = null
	if not arg_add_menu_button:
		new_action_menu_item =\
				ActionMenuItem.new(arg_key, arg_caller, arg_caller_method)
	else:
		var new_action_menu_button = default_dev_action_button_node.duplicate()
		action_button_container_node.call_deferred("add_child", new_action_menu_button)
		yield(new_action_menu_button, "tree_entered")
		new_action_menu_button.visible = true
		new_action_menu_item =\
				ActionMenuItem.new(arg_key, arg_caller, arg_caller_method,
				new_action_menu_button)
	# add dev command
	if new_action_menu_item != null:
		new_action_menu_item.is_console_command_allowed = arg_add_console_command
		dev_action_register[arg_key] = new_action_menu_item



func _on_command_line_focus_entered():
	is_command_line_focused = true


func _on_command_line_focus_exited():
	is_command_line_focused = false


func _on_send_command_button_pressed():
	_parse_dev_command(command_line_node.text)


func _on_viewport_resized():
	margin_node.rect_size = margin_node.get_viewport_rect().size


# arg_command should correspond to the given ActionMenuItem key (which
#	was set in add_dev_command)
func _parse_dev_command(arg_command: String):
	command_line_node.text = ""
	var command_action_menu_item: ActionMenuItem = null
	if not arg_command in dev_action_register.keys():
		GlobalLog.info(self, "command {0} not found".format([arg_command]))
	else:
		command_action_menu_item = dev_action_register[arg_command]
		if command_action_menu_item != null:
			if command_action_menu_item.is_console_command_allowed:
				if command_action_menu_item.run_command() != OK:
					GlobalLog.error(self, "key exists but command invalid")


func _setup_viewport_responsiveness():
	# set up handling for if viewport resizes
	var viewport_root: Viewport = get_viewport()
	if viewport_root != null:
		var signal_outcome = OK
		signal_outcome = viewport_root.connect("size_changed", self, "_on_viewport_resized")
		if signal_outcome != OK:
			GlobalLog.error(self, "DebugOverlay err setup _on_viewport_resized")


