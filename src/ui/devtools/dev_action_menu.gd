extends Control

#class_name DevActionMenu

##############################################################################

# DevActionMenu

##############################################################################
#
# DevActionMenu is
#
# DEPENDENCY: GlobalDebug
#
##############################################################################

#//TODO DEV_ACTION_MENU
# Mouse filter review
# Dev action button scene - auto connects to owner, calls method with export str name
# Autoclose on dev action button selection
# Command button (different to overlay) to bring up devActionMenu
# working send command button and close menu button
# set up style resource/s for the buttons
# set up font resource for the buttons
# set up action button container item/button margins

#//TODO GLOBAL_DEBUG
# method: add_dev_command
# method: remove_dev_command

#//TODO DEV_DEBUG_OVERLAY
# also add folder for dev_debug_overlay
# rename devtools_item_container font resources for consistency

#//TODO DEV_TOOLS
# add a dev console for viewing globalDebug logging in-game
# devTools -> add dev menu buttons at top of screen
#	(show DevActionMenu, show DevDebugOverlay, show DevConsole)

#//TODO SAMPLE_SCENE
# sample scene with sample button
# sample devCommand

#
# PLANNED STRUCTURE BELOW
#

#//PROPERTIES
#
# action buttons are just buttons linked to specific DevCommand structs via signal
# devCommand is a struct w/str arg for signal name, under devActionMenu or globalDebug
# devCommands store their caller_self and method and validate before calling
# devCommands also validate the signal exists on globalDebug before calling
# devCommands are stored in a register/dict

#//METHODS
#
# method to establish a new dev command (and, potentially, a new action button)
# 1) creates a signal of 'dev_'+signal_id_suffix on GlobalDebug
# 2) once signal exists (or if did already) connects the new signal to caller
# 3) creates devCommand struct in devActionMenu - if typed/pressed calls signal
# 4) connects tree_exited on caller to remove dev command method
#
# GlobalDebug.add_dev_command(
#		signal_id_suffix: String,
#		caller_self: Node,
#		called_method: String,
#		add_action_button: bool = true)

# method to prune an unnecessary dev command
# 1) removes signal connection
# 2) looks for and removes signal connection to prune (step 4 above)
# 3) removes relevant devCommand struct from devActionMenu
# 4) removes relevant signal from globalDebug
#
# GlobalDebug.remove_dev_command(
#		signal_id_suffix: String,
#		caller_self: Node,
#		called_method: String)

##############################################################################
#
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#
#05. signals
#06. enums

#07. constants
# for passing to error logging
const SCRIPT_NAME := "DevActionMenu"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

#08. exported variables
#09. public variables
#10. private variables
#11. onready variables
#
##############################################################################
#
#12. optional built-in virtual _init method
#13. built-in virtual _ready method
#14. remaining built-in virtual methods
#15. public methods
#16. private methods

##############################################################################


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

