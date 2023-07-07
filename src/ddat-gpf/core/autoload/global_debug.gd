extends GameGlobal

#class_name GlobalDebug

##############################################################################

# GlobalDebug allows developers to expose game properties during release
# builds, through developer commands and a debugging overlay.

# TODO
#// add optional binds for devCommand signals

##############################################################################

# the debug info overlay is a child scene of GlobalDebug which is hidden
# by default in release builds (and visible by default in debug builds),
# consisting of a vbox column of key/value label node pairs on the side
# of the viewport. This allows the developer to set signals or setters within
# their own code to automatically push changes in important values to somewhere
# visible ingame. This is useful to get feedback in unstable release builds.
signal update_debug_overlay_item(item_key, item_value)

# signals to manage the devActionMenu via globalDebug methods
signal add_new_dev_command(devcmd_id, add_action_button)
# warning-ignore:unused_signal
signal remove_dev_command(devcmd_id)

#//REVIEW - may be adding unnecessary complexity, could just add a check
# that the signal doesn't already exist when trying to add a dev comamnd
#
# all signals passed via add_dev_command prefix themselves with this string
#const DEV_COMMAND_SIGNAL_PREFIX := "dev_"

# as with the constant OVERRIDE_DISABLE_ALL_LOGGING, this variable denies
# all logging calls. It is set and unset as part of the log_test method.
# Many unit tests will purposefully 
var _is_test_running = false

###############################################################################

# virt


func _ready():
	if verbose_logging:
		GlobalLog.elevate_log_permissions(self)


###############################################################################


# method to establish a new dev command (and, potentially, a new action button)
# 1) creates passed string as a signal on GlobalDebug
# 2) once signal exists (or if did already) connects the new signal to caller
# 3) connects tree_exited on caller to remove dev command method
# 4) creates devCommand struct in devActionMenu - if typed/pressed calls signal
# [Usage]
# Call add_dev_command from on_ready() on any node with a method you wish
# to add as a dev_command
# [method params as follows]
##1, signal_id, is the string identifier of the signal created on globalDebug
##2, caller, is the node whom the signal connects to
##3, called_method, is the string name of the method (on caller) connected to
#	by the devCommand. When the command is typed on the devActionMenu, or the
#	corresponding devActionMenu button is pressed, this is the activated method
##4, add_action_button, is passed with the siganl to create a devCommand object
#	on the devActionMenu - if true a button will be created on the menu for
#	ease of activating the command. If false it will be via text input only.
func add_dev_command(
	signal_id: String,
	caller: Node,
	caller_method: String,
	add_action_button: bool = true
):
	# dev commands are designed to connect to a single caller/method but
	# technically nothing prevents them from calling multiple
	# if the new signal already exists on globalDebug, just warn the dev
	if self.has_signal(signal_id):
#		"connecting a secondary caller to a pre-existing dev "+\
#		"command signal, did you mean to do this?")
		GlobalLog.warning(self, "add_dev_command already has signal"+str(signal_id))
	
	# handle error logging with a single string
	var errstring = ""
	
	# normal behaviour, create signal
	self.add_user_signal(signal_id)
	if not self.has_signal(signal_id):
		errstring += "signal {s} not found".format({"s": signal_id})
	else:
		if not caller.has_method(caller_method):
			errstring += "method {cm} not found".format({"cm": caller_method})
		else:
			if self.connect(signal_id, caller, caller_method) != OK:
				errstring += "unable to connect to {c}".format({"c": caller})
			# if everything OK
			else:
				# on exiting tree remove the associated dev command
# warning-ignore:return_value_discarded
				if caller.connect("tree_exiting", self, "delete_dev_command",
					[signal_id, caller, caller_method]) != OK:
						GlobalLog.warning(self,
								"command not added, error {1} {2} {3}".format({
									"1": signal_id,
									"2": caller,
									"3": caller_method,
								}))
				# send signal to create a devCommand struct in devActionMenu
				emit_signal("add_new_dev_command",
						signal_id, add_action_button)
	
	# any addition to err string means an error branch above was encountered
	if errstring != "":
		GlobalLog.error(self, errstring)


# method to prune an unnecessary dev command
# 1) removes signal connection
# 2) looks for and removes signal connection to prune (step 4 above)
# 3) removes relevant devCommand struct from devActionMenu
# 4) removes relevant signal from globalDebug
# [Usage]
# Automatically called when a node linked to a dev command
# [method params as follows]
##1, signal_id_suffix, is
##2, caller, is
##3, called_method, is
#func delete_dev_command(
## warning-ignore:unused_argument
## warning-ignore:unused_argument
## warning-ignore:unused_argument
## warning-ignore:unused_argument
## warning-ignore:unused_argument
#	signal_id_suffix: String,
#	caller: Node,
#	called_method: String
#):
#	pass

# update_debug_info is a method that interfaces with the debug_info_overlay
# child of GlobalDebug (automatically instantiated at runtime)
# arg1 is the key for the debug item.
# this argument should be different when the dev wishes to update the debug
# info overlay for a different debug item, e.g. use a separate key for player
# health, a separate key for player position, etc.
# arg1 shoulod always be a string key
# arg2 can be any type, but it will be converted to string before it is set
# to the text for the value label in the relevant debug info item container
func update_debug_overlay(debug_item_key: String, debug_item_value) -> void:
	# everything works, pass on the message to the canvas info overlay
	# validation step added due to strange method-not-declared bug that
	# ocassionally occurs
	emit_signal("update_debug_overlay_item",
			debug_item_key,
			debug_item_value)


###############################################################################

# BELOW METHODS ARE ALL DEPRECATED
# DO NOT USE

###############################################################################

