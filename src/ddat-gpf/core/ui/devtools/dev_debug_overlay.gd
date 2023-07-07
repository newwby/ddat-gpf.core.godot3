extends CanvasLayer

#class_name DevDebugOverlay

##############################################################################

# DevDebugOverlay.gd is a script for the scene/node of the same name,
# which manages the presentation of debug information during gameplay.

# DEPENDENCY: GlobalDebug

# 
# HOW TO USE
# Call public method to add or update a debug value
# If the key for the update is found, DevDebugOverlay will push an update to
# the matching debug item container, changing the value as appropriate.
# If the key is not found, DevDebugOverlay will create a new debug item
# container and add its value.

# TODO
#// add viewport/resolution scaling support
#// align mid container items to center, right container items to right

#// add support for debug values that hide over time after no updates

#// add support for renaming debug keys
#// add developer support for custom adjusting/setting margin
#// add support for text colour
#// add support for multiple info columns

#// add support for autosorting options, e.g. alphabetically by key
#// add Public Function to update debug values
#// add secondary toggle confirm on release builds
#// add perma-disable (via globalDebug) option

#// add support for info column categories (empty category == hide)
#	- option(oos) category organisation; default blank enum dev can customise
#	- subheadings and dividers

# POTENTIAL BUGS
#// what happens if multiple sources try to update a new key? will more than
# one debugItemContainer be created? what happens to the reference of the last?

##############################################################################

# where on-screen to position a debug_overlay_item
enum POSITION {TOP_LEFT, TOP_MID, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_MID, BOTTOM_RIGHT}

# which positional contaner debug_overlay_item nodes default to
var default_overlay_item_position: int = POSITION.TOP_RIGHT

# debug_key : debug_overlay_item object
var debug_overlay_item_register = {}

var show_menu_action := "show_debug_menu"

# duplicated to create debug_overlay_item nodes
onready var default_overlay_item_node = $Margin/OverlayItem
# positional containers for debug_overlay_item nodes
onready var position_container_top_left: VBoxContainer = $Margin/Align/Top/Left
onready var position_container_top_mid: VBoxContainer = $Margin/Align/Top/Mid
onready var position_container_top_right: VBoxContainer = $Margin/Align/Top/Right
onready var position_container_bottom_left: VBoxContainer = $Margin/Align/Bottom/Left
onready var position_container_bottom_mid: VBoxContainer = $Margin/Align/Bottom/Mid
onready var position_container_bottom_right: VBoxContainer = $Margin/Align/Bottom/Right

##############################################################################

# classes


class DebugOverlayItem:
	
	var key_node_ref: Label = null
	var value_node_ref: Label = null
	var key := ""
	var value = null
	var is_valid := false
	
	func _init(
			arg_key_node_ref: Label = null,
			arg_value_node_ref: Label = null,
			arg_key: String = "",
			arg_value = null):
		if arg_key_node_ref == null\
		or arg_value_node_ref == null\
		or arg_key == "":
			is_valid = false
		else:
			self.key_node_ref = arg_key_node_ref
			self.value_node_ref = arg_value_node_ref
			self.key = arg_key
			self.value = arg_value
			is_valid = true


	func update_labels():
		if key_node_ref != null:
			key_node_ref.text = key
		if value_node_ref != null:
			value_node_ref.text = str(value)


##############################################################################

# virt

onready var margin_node = $Margin
onready var dev_debug_overlay_root_node = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	GlobalDebug.connect("update_debug_overlay_item", self, "_on_update_debug_overlay_item")
#	self.visible = false
	_on_viewport_resized()
	var viewport_root: Viewport = get_viewport()
	if viewport_root != null:
		if viewport_root.connect("size_changed", self, "_on_viewport_resized") != OK:
			GlobalLog.error(self, "GlobalDebug err connect _on_viewport_resized")


func _input(event):
	if event.is_action_pressed(show_menu_action):
		self.visible = !self.visible


##############################################################################

# public


# returns the VBoxContainer corresponding to a given POSITION enum value
func get_debug_item_container(arg_position_value: int) -> VBoxContainer:
	if not arg_position_value in POSITION.values():
		return null
	else:
		match arg_position_value:
			POSITION.TOP_LEFT:
				return position_container_top_left
			POSITION.TOP_MID:
				return position_container_top_mid
			POSITION.TOP_RIGHT:
				return position_container_top_right
			POSITION.BOTTOM_LEFT:
				return position_container_bottom_left
			POSITION.BOTTOM_MID:
				return position_container_bottom_mid
			POSITION.BOTTOM_RIGHT:
				return position_container_bottom_right
	# catchall
	return null


##############################################################################

# private


# called from _on_update_debug_overlay_item
# creates both a new DebugOverlayItem object and the companion overlay_item node
# if arg_position_value is negative it will be ignored and
#	default_overlay_item_position will be used instead
func _add_item(
		arg_item_key: String,
		arg_item_value,
		arg_position_value: int = -1) -> void:
	# get area of overlay to add the new item
	var position_container_value = 0
	if arg_position_value < 0:
		position_container_value = default_overlay_item_position
	var overlay_container = get_debug_item_container(position_container_value)
	var new_overlay_node = default_overlay_item_node.duplicate()
	overlay_container.call_deferred("add_child", new_overlay_node)
	yield(new_overlay_node, "tree_entered")
	new_overlay_node.visible = true
	# get the node references, check are valid, remove if not
	print(new_overlay_node.get_children())
	var key_label_node_ref = new_overlay_node.get_node_or_null("Key")
	var value_label_node_ref = new_overlay_node.get_node_or_null("Value")
	if key_label_node_ref == null or value_label_node_ref == null:
		GlobalLog.error(self, "err setup _add_item key/value node == null"+\
				"| key: {0} & value: {1}".format([key_label_node_ref, value_label_node_ref]))
		new_overlay_node.get_parent().call_deferred("remove_child", new_overlay_node)
		return
	# if setup of node was successful, create the reference object to store info
	var new_overlay_object = DebugOverlayItem.new(
		key_label_node_ref, value_label_node_ref, arg_item_key, arg_item_value)
	new_overlay_object.update_labels()
	# record by key
	debug_overlay_item_register[arg_item_key] = new_overlay_object


func _on_viewport_resized():
	margin_node.rect_size = margin_node.get_viewport_rect().size


# called from _on_update_debug_overlay_item
func _update_item(arg_item_key: String, arg_item_value):
	var overlay_object: DebugOverlayItem = null
	if debug_overlay_item_register.has(arg_item_key):
		overlay_object = debug_overlay_item_register[arg_item_key]
		if overlay_object != null:
			overlay_object.value = arg_item_value
			overlay_object.update_labels()


# on GlobalDebug signal update_debug_overlay_item
func _on_update_debug_overlay_item(arg_item_key, arg_item_value):
	if typeof(arg_item_key) == TYPE_STRING:
		if arg_item_key in debug_overlay_item_register.keys():
			_update_item(arg_item_key, arg_item_value)
		else:
			_add_item(arg_item_key, arg_item_value)


##############################################################################

# private


#


##############################################################################


func SEPARATE_OLD_old_sep():
	pass

##############################################################################

# for passing to error logging
const SCRIPT_NAME := "dev_debug_overlay"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

#//TODO - intiialise F1 key as a new action for show/hide debug overlay
# change this string to the project map action you wish to toggle the overlay
const TOGGLE_OVERLAY_ACTION := "ui_select"

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
var debug_item_container_node_refs = {}

# these are node paths to the major nodes in the debug info overlay scene
#onready var debug_edge_margin_node: MarginContainer =\
#		$Margin
onready var debug_info_column_node: VBoxContainer = null# =\
#		$Margin/InfoColumn
onready var debug_item_container_default_node: HBoxContainer = null#=\
#		$Margin/InfoColumn/ItemContainer



func ready_old():
	# any failed success setup step will unset this
	var setup_success_state = true
	
	# set initial size based on current viewport, then prepare for
	# any future occurence of the viewport size changing and moving elements
	#// deprecating, somewhat unnecessary due to godot controls auto-sizing
#	_on_viewport_resized_resize_info_overlay()
#	if get_viewport().connect("size_changed",
#			self, "_on_viewport_resized_resize_info_overlay") != OK:
#		# report error on failure to get signal
#		setup_success_state = false
	
	# configure the default/template item container
	# passed arg is default container (is child, should be readied) node ref
	if _setup_info_item_container(
				debug_item_container_default_node) != OK:
		setup_success_state = false
	
	# before connecting next signal, verify previous setups happened as planned
	if not setup_success_state:
		return
	
	# set the connection to globalDebug so when globalDebug.update_debug_info
	# method is called, it redirects to _update_debug_item_container method
	if GlobalDebug.connect("update_debug_overlay_item",
			self, "_on_update_debug_overlay_item_notify_container") != OK:
		pass
	
	# automatically show on debug builds
	self.visible = (OS.is_debug_build())
	# if default item container was left visible in testing, always hide it
	if debug_item_container_default_node != null:
		debug_item_container_default_node.visible = false
	create_debug_item_container("bleeh", "300")


##############################################################################


# on recieving input to toggle the overlay, flip whether to show/hide it
func _input_old(event):
	if event.is_action_pressed(TOGGLE_OVERLAY_ACTION):
		self.visible = !self.visible


##############################################################################


# called whenever an item container for a specific key can't be found
# this method duplicates the default item container node,
# adds the duplicate as a child to the info column,
# and then calls _update_existing_debug_item_value with the value
func create_debug_item_container(
			debug_item_key: String,
			debug_item_new_value: String) -> HBoxContainer:
	var new_debug_item_container_node: HBoxContainer
	# check valid before duplicating
	if debug_item_container_default_node == null:
		# this should not happen
		GlobalLog.error(self,
				"default_item_container.not_found")
	else:
		# add to scene tree beneath info column node
		# verify there's a valid debug info column then add the new container
		if debug_info_column_node != null:
			# log progress if verbose logging
			GlobalLog.info(self, "newitemcon.setup.step1")
			# we wait to duplicate until we confirm there's a valid parent node
			# else we'll potentially end up with a memory leak
			new_debug_item_container_node =\
					debug_item_container_default_node.duplicate()
			# wait until the info column node has an idle frame
			debug_info_column_node.call_deferred("add_child",
					new_debug_item_container_node)
			# wait until new container is in the scene tree before continuing
			yield(new_debug_item_container_node, "ready")
			
			# after new container is readied, must configure its children
			# this sets up the value label group for viewport resizing calls
			# this also doublechecks the tree structure of the duplicate node
			if _setup_info_item_container(new_debug_item_container_node)!= OK:
				# report error on failure to configure new item container
				GlobalLog.error(self, "newitemcon.setupfailure ")
			else:
				# log progress if verbose logging
				GlobalLog.info(self, "newitemcon.setup.step2")
				# new item container is ready, we can now allow it to update
				# register the new item container in the node ref dictionary
				debug_item_container_node_refs[debug_item_key] =\
						new_debug_item_container_node
				# update the initial key string (done once here)
				update_debug_item_key_label(
					new_debug_item_container_node,
					debug_item_key
				)
				# call the normal update debug item value method
				update_existing_debug_item_value(
						new_debug_item_container_node,
						debug_item_new_value)
				# default item container is set invisible so last step is
				# to render the new (duplicated) item container visible
				new_debug_item_container_node.visible = true
		# if debug item column node was not readied properly (is null)
		# then there's no parent to add the new item container to
		else:
			GlobalLog.warning(self,
				"debug_info_column_node.not_found")
	
	return new_debug_item_container_node


func update_debug_item_key_label(
		passed_item_container: HBoxContainer,
		debug_item_key: String):
	# get label by node path
	var key_label_node = passed_item_container.get_node_or_null(
			NODE_NAME_DEBUG_ITEM_LABEL_KEY)
	if key_label_node is Label:
		key_label_node.text = debug_item_key


func update_existing_debug_item_value(
			passed_item_container: HBoxContainer,
			debug_item_new_value: String):
	# container should be inside tree before attempting to update
	if passed_item_container.is_inside_tree():
		# get label by node path
		var value_label_node = passed_item_container.get_node_or_null(
				NODE_NAME_DEBUG_ITEM_LABEL_VALUE)
		if value_label_node is Label:
			value_label_node.text = debug_item_new_value
		else:
			GlobalLog.warning(self,
					"itemcon_value_is_not_label")
	else:
		GlobalLog.warning(self,
				"passed_item_container.not_in_tree")
		return


##############################################################################


func _setup_info_item_container(passed_item_container: HBoxContainer):
	# you can pass any hbox container child of the info column,
	# as long as it has two labels,
	# and the two labels have the correct names
	var label_node_key = passed_item_container.get_node_or_null(
			NODE_NAME_DEBUG_ITEM_LABEL_KEY)
	var label_node_value = passed_item_container.get_node_or_null(
			NODE_NAME_DEBUG_ITEM_LABEL_VALUE)
	
	# check if parent is correct
	var validation_check := true
	validation_check =\
			(passed_item_container.get_parent() == debug_info_column_node)\
			and (label_node_key is Label)\
			and (label_node_value is Label)
	if not validation_check:
		return ERR_UNCONFIGURED
	
	# assign grouping
	if not label_node_value.is_in_group(GROUP_STRING_DEBUG_ITEM_LABEL_VALUE):
		label_node_value.add_to_group(GROUP_STRING_DEBUG_ITEM_LABEL_VALUE)
	
	# if all is good
	return OK


##############################################################################
#
# signal receipt methods


# if not found duplicate a new item container & call _setup_info_item_container
func _on_update_debug_overlay_item_notify_container(\
		item_container_key: String,
		new_value):
	
	var debug_item_value = str(new_value)
	var get_debug_item_container
	if debug_item_container_node_refs.has(item_container_key):
		get_debug_item_container =\
				debug_item_container_node_refs[item_container_key]
		update_existing_debug_item_value(
				get_debug_item_container,
				debug_item_value)
	else:
		# if container not found, create a new container and assign it
		if get_debug_item_container == null:
			var new_debug_item_container = create_debug_item_container(
						item_container_key,
						debug_item_value
			)
			# if there's a problem with the previous method it will return nil
			if new_debug_item_container != null:
				get_debug_item_container = new_debug_item_container
			else:
				GlobalLog.error(self,
					"new_debug_item_container.not_found")
				return
		else:
			pass


#// deprecating, see note in _ready
# call on ready and whenever viewport size changes
#func _on_viewport_resized_resize_info_overlay():
#	var new_viewport_size = get_viewport().size
#	# set default sizes based on the viweport
#	debug_edge_margin_node.rect_size = new_viewport_size
#
#	if false:
#		# set minimum bounds for item container value labels
#		var item_container_value_label_nodes =\
#				get_tree().get_nodes_in_group(GROUP_STRING_DEBUG_ITEM_LABEL_VALUE)
#		if not item_container_value_label_nodes.empty():
#			for value_label_node in item_container_value_label_nodes:
#				if value_label_node is Label:
#					# value labels for debug item containers have a minimum size
#					# set to prevent them from jumping all over the place as the
#					# value updates - by default this value is set to a small
#					# proportion of the viewport, and changed if viewport resizes
#					value_label_node.rect_min_size =\
#							new_viewport_size*DEBUG_ITEM_VALUE_MIN_SIZE_FRACTIONAL

