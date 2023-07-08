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

