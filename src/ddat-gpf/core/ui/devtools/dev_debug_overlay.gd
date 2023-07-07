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
onready var margin_node = $Margin
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


# Called when the node enters the scene tree for the first time.
func _ready():
	var signal_outcome = GlobalFunc.confirm_connection(GlobalDebug,
			"update_debug_overlay_item", self, "_on_update_debug_overlay_item") 
	if signal_outcome != OK:
		GlobalLog.error(self, "DebugOverlay err setup update_debug_overlay_item")
	# set debug overlay based on current viewport size
	_on_viewport_resized()
	# set up handling for if viewport resizes
	var viewport_root: Viewport = get_viewport()
	if viewport_root != null:
		signal_outcome = OK
		signal_outcome = viewport_root.connect("size_changed", self, "_on_viewport_resized")
		if signal_outcome != OK:
			GlobalLog.error(self, "DebugOverlay err setup _on_viewport_resized")


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

