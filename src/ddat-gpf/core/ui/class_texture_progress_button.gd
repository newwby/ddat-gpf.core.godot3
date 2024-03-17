extends TextureButton

class_name TextureProgressButton

##############################################################################

# Combination of TextureProgress and TextureButton, creating a button
#	which does not activate when pressed - only when the overlaid texture
#	progress is filled (the length of the required press can be customised)
# Releasing press will 'unfill' the texture progress overlay (rate customisable)

# This node replicates some features from TextureProgress but notably excludes
#	most texture setting and tinting properties, instead using a single tint
#	for an 'under' texture, and default tint for the current active* texture
# * this is determined by the TextureButton state, i.e. normal or disabled   

# DEV NOTE: do not connect the pressed signal to behaviour you wish to
#	activate on the button filling up. Instead use the signal 'activated'.

##############################################################################

<<<<<<< Updated upstream
=======
#//TODO (TextureProgress properties not implemented
#	nine_patch_stretch
#	stretch_margin_left
#	stretch_margin_top
#	stretch_margin_right
#	stretch_margin_bottom
#	progress_offset
#	center_offset
#	texture_over
#	tint_over

#//TODO
# texture updating when hovered/etc
# debug display value/max value & debug export
# call update texture on setters for texture changes and button state changes
# remove ddat behaviour for public version (see '#//DDAT.GPF behaviour')

##############################################################################

>>>>>>> Stashed changes
signal activated()

# from TextureProgress docs
#	● LEFT_TO_RIGHT = 0
#	The texture_progress fills from left to right.
#	● RIGHT_TO_LEFT = 1
#	The texture_progress fills from right to left.
#	● TOP_TO_BOTTOM = 2
#	The texture_progress fills from top to bottom.
#	● BOTTOM_TO_TOP = 3
#	The texture_progress fills from bottom to top.
#	● CLOCKWISE = 4
#	Turns the node into a radial bar. The texture_progress fills clockwise. See radial_center_offset, radial_initial_angle and radial_fill_degrees to control the way the bar fills up.
#	● COUNTER_CLOCKWISE = 5
#	Turns the node into a radial bar. The texture_progress fills counterclockwise. See radial_center_offset, radial_initial_angle and radial_fill_degrees to control the way the bar fills up.
#	● BILINEAR_LEFT_AND_RIGHT = 6
#	The texture_progress fills from the center, expanding both towards the left and the right.
#	● BILINEAR_TOP_AND_BOTTOM = 7
#	The texture_progress fills from the center, expanding both towards the top and the bottom.
#	● CLOCKWISE_AND_COUNTER_CLOCKWISE = 8
#	Turns the node into a radial bar. The texture_progress fills radially from the center, expanding both clockwise and counterclockwise. See radial_center_offset, radial_initial_angle and radial_fill_degrees to control the way the bar fills up.
enum  FILL_MODE {
	LEFT_TO_RIGHT,
	RIGHT_TO_LEFT,
	TOP_TO_BOTTOM,
	BOTTOM_TO_TOP,
	CLOCKWISE,
	COUNTER_CLOCKWISE,
	BILINEAR_LEFT_AND_RIGHT,
	BILINEAR_TOP_AND_BOTTOM,
	CLOCKWISE_AND_COUNTER_CLOCKWISE
}

enum BUTTON_STATE {PRESSED, FOCUSED, HOVERED, DISABLED}

# to ensure smooth range tracking, the press duration is multiplied by this
#	value to get the actual value (so delta can be applied to the gained
#	value per press without falling beneath the minimum step)
#const MILLISECOND_VALUE_COEFF := 1000.0
# amount added to progress_overlay.value whilst button pressed, per frame
const VALUE_PER_FRAME := 1.0
# the step value of the texture overlay; set low so delta multiplication
#	doesn't prevent progress gain
const OVERLAY_STEP := 0.001

# creates a label to show value if set true
export(bool) var debug_show_value := false setget set_debug_show_value

# seconds the button must be in the pressed state to trigger the 'activated' signal
# if unpressed the button will lose progress at a rate determined by unfill_rate
#	minimum value of 0.0
export(float) var press_duration := 0.5 setget set_press_duration
# this is how much faster you wish a button to reach 0 progress when not
#	pressed. e.g.
#	1.0 will lose progress when unpressed at an equal rate to gain when pressed
#	2.0 will lose progress twice as fast
#	0.0 will never lose progress
#	minimum value of 0.0
export(float, 0.0, 10.0) var unfill_rate := 2.0 setget set_unfill_rate

# seconds that must elapse before button can be pressed again after activation
export(float) var cooldown_duration := 0.25
# button will automatically disable when on cooldown and re-enable when cooldown ends
export(bool) var disable_on_cooldown := true
# if set true then cooldown can never expire (so after first activation
#	cannot activate again)
export(bool) var one_shot := false

# the following properties are directly passed to the progress_overlay node
export(FILL_MODE) var fill_mode := FILL_MODE.LEFT_TO_RIGHT setget set_fill_mode
export(float, 0, 360) var radial_initial_angle := 0.0 setget set_radial_initial_angle
export(float, 0, 360) var radial_fill_degrees := 0.0 setget set_radial_fill_degrees

export(Color) var progress_texture_tint := Color(1.15, 1.15, 1.15, 1.0) setget set_progress_texture_tint
export(Color) var under_texture_tint := Color(0.85, 0.85, 0.85, 1.0) setget set_under_texture_tint

# DDAT behaviour would have to be removed for a public version
# preferred behaviour but can be disabled
export(bool) var grab_focus_on_hovered := true

var button_state := {
	BUTTON_STATE.DISABLED: false,
	BUTTON_STATE.PRESSED: false,
	BUTTON_STATE.FOCUSED: false,
	BUTTON_STATE.HOVERED: false,
}

# passed to the value property of the progres_overlay
# gained when button is pressed, at a rate of delta*1.0*MILLISECOND_VALUE_COEFF
# when equal to max_value, activation occurs
var press_accumulation := 0.0
# if on cooldown this value will tick down until nil (at which point pressing
#	the button will count toward activation again)
var cooldown_remaining := 0.0

var progress_overlay := TextureProgress.new()
var debug_label: Label = null

##############################################################################

# setters/getters

func set_debug_show_value(arg_value: bool):
	debug_show_value = arg_value
	if debug_show_value:
		if debug_label == null:
			debug_label = Label.new()
		if is_instance_valid(debug_label):
			if debug_label.is_inside_tree() == false:
				self.call_deferred("add_child", debug_label)
				debug_label.mouse_filter = MOUSE_FILTER_IGNORE
				debug_label.rect_position = Vector2(-30.0, -30.0)


func set_disabled(arg_value: bool) -> void:
	var old_value = disabled
	disabled = arg_value
	if old_value == false and disabled == true:
		_on_disabled()
	elif old_value == true and disabled == false:
		_on_enabled()


func set_disabled_texture(arg_value: Texture) -> void:
	texture_disabled = arg_value
	_update_overlay_texture()


func set_fill_mode(arg_value: int) -> void:
	fill_mode = arg_value
	if not arg_value in FILL_MODE.values():
		GlobalLog.warning(self, "fill_mode set to invalid value ({0})".format([arg_value]))
	if is_instance_valid(progress_overlay):
		progress_overlay.fill_mode = fill_mode


func set_focused_texture(arg_value: Texture) -> void:
	texture_focused = arg_value
	_update_overlay_texture()


func set_hover_texture(arg_value: Texture) -> void:
	texture_hover = arg_value
	_update_overlay_texture()


func set_normal_texture(arg_value: Texture) -> void:
	texture_normal = arg_value
	_update_overlay_texture()


func set_pressed_texture(arg_value: Texture) -> void:
	texture_pressed = arg_value
	_update_overlay_texture()


func set_progress_texture_tint(arg_value: Color):
	progress_texture_tint = arg_value
	if is_instance_valid(progress_overlay):
		progress_overlay.tint_progress = progress_texture_tint


func set_radial_fill_degrees(arg_value: float) -> void:
	radial_fill_degrees = arg_value
	if is_instance_valid(progress_overlay):
		progress_overlay.radial_fill_degrees = radial_fill_degrees


func set_radial_initial_angle(arg_value: float) -> void:
	radial_initial_angle = arg_value
	if is_instance_valid(progress_overlay):
		progress_overlay.radial_initial_angle = radial_initial_angle


func set_press_duration(arg_value: float) -> void:
	press_duration = arg_value
	if press_duration < 0.0:
		press_duration = 0.0
	_update_range_values()


func set_under_texture_tint(arg_value: Color):
	under_texture_tint = arg_value
	if is_instance_valid(progress_overlay):
		progress_overlay.tint_under = under_texture_tint


func set_unfill_rate(arg_value: float) -> void:
	unfill_rate = arg_value
	if unfill_rate < 0.0:
		unfill_rate = 0.0


##############################################################################

# virt


# Called when the node enters the scene tree for the first time.
func _ready():
	_ready_overlay()
	_ready_signals()
	# debugging, disable button
	self.self_modulate.a = 0.0
#	progress_overlay.self_modulate.a = 0.0
#	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# skip if disabled
	if cooldown_remaining > 0.0:
		cooldown_remaining -= (delta*VALUE_PER_FRAME)
		if cooldown_remaining <= 0.0:
			end_cooldown()
	# cooldown not active and button not disabled, handle clicks
	elif is_instance_valid(progress_overlay) and (self.disabled == false):
		# filling/unfilling
		if self.pressed:
			progress_overlay.value += (delta*VALUE_PER_FRAME)
		elif self.pressed == false and progress_overlay.value > 0.0:
			progress_overlay.value -= (delta*VALUE_PER_FRAME*unfill_rate)
		# activation handling
		if progress_overlay.value >= progress_overlay.max_value:
			start_cooldown()
#			progress_overlay.value = 0 # _clear_progress()
#			_update_debug_label()
			activate()
	# debug handling
	_update_debug_label()


##############################################################################

# public


func activate() -> void:
	emit_signal("activated")


func end_cooldown() -> void:
	if disable_on_cooldown and self.disabled:
		self.disabled = false
	self.cooldown_remaining = 0.0
	progress_overlay.value = 0


func start_cooldown() -> void:
	if disable_on_cooldown and not self.disabled:
		self.disabled = true
	self.cooldown_remaining = cooldown_duration


##############################################################################

# private


# change the flag in the button_state dict then update the overlay texture
# first argument must be a key from BUTTON_STATE, second a bool
func _adjust_button_state(arg_button_state_key: int, arg_new_state: bool):
	if arg_button_state_key in button_state.keys():
		button_state[arg_button_state_key] = arg_new_state
		_update_overlay_texture()
	else:
		GlobalLog.error(self, "cannot find button state on {0}".format([arg_button_state_key]))


func _on_button_down() -> void:
	_adjust_button_state(BUTTON_STATE.PRESSED, true)


func _on_button_up() -> void:
	_adjust_button_state(BUTTON_STATE.PRESSED, false)


func _on_disabled() -> void:
	_adjust_button_state(BUTTON_STATE.DISABLED, true)


func _on_enabled() -> void:
	_adjust_button_state(BUTTON_STATE.DISABLED, false)


func _on_focus_entered() -> void:
	_adjust_button_state(BUTTON_STATE.FOCUSED, true)


func _on_focus_exited() -> void:
	_adjust_button_state(BUTTON_STATE.FOCUSED, false)


func _on_mouse_entered() -> void:
	_adjust_button_state(BUTTON_STATE.HOVERED, true)
	if grab_focus_on_hovered:
		self.grab_focus()


func _on_mouse_exited() -> void:
	_adjust_button_state(BUTTON_STATE.HOVERED, false)


func _ready_overlay() -> void:
	if is_instance_valid(progress_overlay):
		self.call_deferred("add_child", progress_overlay)
		# set properties
		# overlay tracks very small increments
		progress_overlay.step = OVERLAY_STEP
		# assert default behaviour
		progress_overlay.mouse_filter = MOUSE_FILTER_IGNORE
		progress_overlay.min_value = 0
		progress_overlay.exp_edit = false
		progress_overlay.rounded = false
		# progress values cannot exceed the range
		progress_overlay.allow_greater = false
		progress_overlay.allow_lesser = false
		# pass fill and tint properties
		progress_overlay.fill_mode = fill_mode
		progress_overlay.tint_under = under_texture_tint
		# set initial texture and max value
		_update_overlay_texture()
		_update_range_values()
	else:
<<<<<<< Updated upstream
		print(self, "unable to find progress_overlay, setup failed")


func _ready_signals() -> void:
	var signals_are_valid := true
	signals_are_valid = signals_are_valid and (self.connect("mouse_entered", self, "_on_mouse_entered") == OK)
	signals_are_valid = signals_are_valid and (self.connect("focus_entered", self, "_on_focus_entered") == OK)
	signals_are_valid = signals_are_valid and (self.connect("focus_exited", self, "_on_focus_exited") == OK)
	signals_are_valid = signals_are_valid and (self.connect("button_down", self, "_on_button_down") == OK)
	signals_are_valid = signals_are_valid and (self.connect("button_up", self, "_on_button_up") == OK)
=======
		#//DDAT.GPF behaviour
		GlobalLog.error(self, "unable to find progress_overlay, setup failed")


func _ready_signals() -> void:
	#//DDAT.GPF behaviour
	GlobalFunc.confirm_connection(self, "mouse_entered", self, "_on_mouse_entered")
	GlobalFunc.confirm_connection(self, "mouse_exited", self, "_on_mouse_exited")
	GlobalFunc.confirm_connection(self, "focus_entered", self, "_on_focus_entered")
	GlobalFunc.confirm_connection(self, "focus_exited", self, "_on_focus_exited")
	GlobalFunc.confirm_connection(self, "button_down", self, "_on_button_down")
	GlobalFunc.confirm_connection(self, "button_up", self, "_on_button_up")
>>>>>>> Stashed changes


func _update_debug_label() -> void:
	if debug_show_value and is_instance_valid(debug_label):
		var text_string_1 := "progress: {0}/{1}".format([str(stepify(progress_overlay.value, 0.01)), str(stepify(progress_overlay.max_value, 0.01))])
		var text_string_2 := "cooldown: {0}/{1}".format([str(stepify(cooldown_remaining, 0.01)), str(stepify(cooldown_duration, 0.01))])
		debug_label.text = text_string_1+"\n"+text_string_2


# caller by the setter for press_duration
func _update_range_values() -> void:
	if is_instance_valid(progress_overlay):
		progress_overlay.max_value = press_duration


# set the texture of the progress_overlay node based on the state of the
#	button (priority in order of disabled -> pressed -> focused -> hover -> normal.
func _update_overlay_texture() -> void:
	if is_instance_valid(progress_overlay) == false:
		GlobalLog.debug_error(self, "cannot adjust overlay texture as progress_overlay not found")
		return
	var active_texture: Texture = null
	
	# determine texture
	if (button_state[BUTTON_STATE.DISABLED] == true) and texture_disabled != null:
		active_texture = texture_disabled
	elif (button_state[BUTTON_STATE.PRESSED] == true) and texture_pressed != null:
		active_texture = texture_pressed
	elif (button_state[BUTTON_STATE.FOCUSED] == true) and texture_focused != null:
		active_texture = texture_focused
	elif (button_state[BUTTON_STATE.HOVERED] == true) and texture_hover != null:
		active_texture = texture_hover
	else:
		active_texture = texture_normal
	
	# apply texture to progress_overlay
	if active_texture == null:
		return
	else:
		progress_overlay.texture_under = active_texture
		progress_overlay.texture_progress = active_texture

