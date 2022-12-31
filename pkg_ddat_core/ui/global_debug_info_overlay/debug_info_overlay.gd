extends Control

#
##############################################################################

# DebugInfoOverlay.gd is a script for the scene/node of the same name,
# which manages the presentation of debug information during gameplay.
# 
# HOW TO USE
# Call public method to add or update a debug value
# If the key for the update is found, DebugInfoOverlay will push an update to
# the matching debug item container, changing the value as appropriate.
# If the key is not found, DebugInfoOverlay will create a new debug item
# container and add its value.

# TODO
#// finish test scene/project
#// add an open source font to ddat core, preferably a KenneyNL font
#// add Public Function to update debug values
#// hide default item container on init
#// default show on debugBuild
#// add button to show/hide on press
#// add secondary confirmation on release builds, or toggle to disable (rw style)
#// add support for debug values that hide over time after no updates
#// add support for renaming debug keys
#// add developer support for setting margin
#// add support for text colour

##############################################################################

# for passing to error logging
const SCRIPT_NAME := "debug_info_overlay"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

# for standardising the an item container's key or value label name
# useful for validating and/or fetching the correct node
const NODE_NAME_DEBUG_ITEM_LABEL_KEY := "Key"
const NODE_NAME_DEBUG_ITEM_LABEL_VALUE := "Value"
# for assigning the value label from newly duplicated item containers to a
# group, so that minimum size can be dynamically adjusted with viewport changes
const GROUP_STRING_DEBUG_ITEM_LABEL_VALUE :=\
		"group_ddat_debug_manager_info_overlay_value_labels"

# proportion of the viewport to set item label minimum size to
# if adjusting make sure to set this to a fractional value (default 0.04)
const DEBUG_ITEM_VALUE_MIN_SIZE_FRACTIONAL = 0.04

# this dict stores debug values passed to the info overlay (via globalDebug)
# when the update_debug_info method is called, this dict is updated
# when this dict is updated the setter for this dict calls 
var debug_values = {}

# these are node paths to the major nodes in the debug info overlay scene
onready var debug_edge_margin_node: MarginContainer =\
		$Margin
onready var debug_info_column_node: VBoxContainer =\
		$Margin/InfoColumn
onready var debug_item_container_default_node: HBoxContainer =\
		$Margin/InfoColumn/ItemContainer

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	var _ready_logging = ""
	# set initial size based on current viewport, then prepare for
	# any future occurence of the viewport size changing and moving elements
	_on_viewport_resized_resize_info_overlay()
	if get_viewport().connect("size_changed",
			self, "_on_viewport_resized_resize_info_overlay") != OK:
		# report error on failure to get signal
		GlobalDebug.log_error(SCRIPT_NAME, "_ready", "view.connect")
	else:
		GlobalDebug.log_success(VERBOSE_LOGGING,\
				SCRIPT_NAME, "_ready", "view.connect")
	
	# configure the default/template item container
	if _setup_info_item_container(debug_item_container_default_node) != OK:
		# report error on failure to initially configure debug item container
		GlobalDebug.log_error(SCRIPT_NAME, "_ready", "itemcon.setup")
	else:
		GlobalDebug.log_success(VERBOSE_LOGGING,\
				SCRIPT_NAME, "_ready", "itemcon.setup")
	
	# set the connection to globalDebug so when globalDebug.update_debug_info
	# method is called, it redirects to _update_debug_item_container method
	if GlobalDebug.connect("update_debug_info_overlay",
			self, "_update_debug_item_container") != OK:
		# report error on failure to link debug info voerlay to globalDebug
		GlobalDebug.log_error(SCRIPT_NAME, "_ready", "gdbg.connect")
	else:
		GlobalDebug.log_success(VERBOSE_LOGGING,\
				SCRIPT_NAME, "_ready", "itemcon.setup")


##############################################################################


# if not found duplicate a new item container & call _setup_info_item_container
func _update_debug_item_container(\
		item_container_key: String,
		new_value):
	pass
	# unused vars temporary
	item_container_key = item_container_key
	new_value = new_value
	# todo add container found code
	# todo add container not found code



##############################################################################


# todo add verbose logging checks
func _setup_info_item_container(passed_item_container: HBoxContainer):
	# you can pass any hbox container child of the info column,
	# as long as it has two labels,
	# and the two labels have the correct names
	var label_node_key = passed_item_container.get_node_or_null(\
			NODE_NAME_DEBUG_ITEM_LABEL_KEY)
	var label_node_value = passed_item_container.get_node_or_null(\
			NODE_NAME_DEBUG_ITEM_LABEL_VALUE)
	
	# check if parent is correct
	var validation_check := true
	validation_check =\
			(passed_item_container.get_parent() == debug_info_column_node)\
			and (label_node_key is Label)\
			and (label_node_value is Label)
	if not validation_check:
		GlobalDebug.log_error(SCRIPT_NAME, "_setup_info_item_container", "val")
		return ERR_UNCONFIGURED
	else:
		GlobalDebug.log_success(VERBOSE_LOGGING,\
				SCRIPT_NAME, "_setup_info_item_container", "val")
	
	# assign grouping
	if not label_node_value.is_in_group(GROUP_STRING_DEBUG_ITEM_LABEL_VALUE):
		label_node_value.add_to_group(GROUP_STRING_DEBUG_ITEM_LABEL_VALUE)
	
	# if all is good
	return OK


##############################################################################


# call on ready and whenever viewport size changes
func _on_viewport_resized_resize_info_overlay():
	var new_viewport_size = get_viewport().size
	# set default sizes based on the viweport
	debug_edge_margin_node.rect_size = new_viewport_size
	
	if false:
		# set minimum bounds for item container value labels
		var item_container_value_label_nodes =\
				get_tree().get_nodes_in_group(GROUP_STRING_DEBUG_ITEM_LABEL_VALUE)
		if not item_container_value_label_nodes.empty():
			for value_label_node in item_container_value_label_nodes:
				if value_label_node is Label:
					# value labels for debug item containers have a minimum size
					# set to prevent them from jumping all over the place as the
					# value updates - by default this value is set to a small
					# proportion of the viewport, and changed if viewport resizes
					value_label_node.rect_min_size =\
							new_viewport_size*DEBUG_ITEM_VALUE_MIN_SIZE_FRACTIONAL

