extends GameGlobal

#class_name GlobalDebug

##############################################################################

# GlobalDebug allows developers to expose game properties during release
# builds, through developer commands and a debugging overlay.

##############################################################################

# the debug info overlay is a child scene of GlobalDebug which is hidden
# by default in release builds (and visible by default in debug builds),
# consisting of a vbox column of key/value label node pairs on the side
# of the viewport. This allows the developer to set signals or setters within
# their own code to automatically push changes in important values to somewhere
# visible ingame. This is useful to get feedback in unstable release builds.
signal update_debug_overlay_item(item_key, item_value, item_position)


# where on-screen to position a debug_overlay_item
# passed alongside update_debug_overlay_item signal
enum FLAG_OVERLAY_POSITION {
		TOP_LEFT, TOP_MID, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_MID, BOTTOM_RIGHT}

###############################################################################

# virt


func _ready():
	if verbose_logging:
		GlobalLog.elevate_log_permissions(self)


###############################################################################


# updates a value on the debug overlay or creates a new key/value pair if
#	the given overlay_item_key does not exist
# arg_overlay_position sets where on-screen to show the overlay item;
#	if it already exists it will be moved to there
#enum 
func update_debug_overlay(
		arg_overlay_item_key: String,
		arg_overlay_item_value,
		arg_overlay_position: int = FLAG_OVERLAY_POSITION.TOP_RIGHT) -> void:
	emit_signal("update_debug_overlay_item",
			arg_overlay_item_key,
			arg_overlay_item_value,
			arg_overlay_position)


###############################################################################

# private

