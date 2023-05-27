extends Reference

class_name Conditional

##############################################################################

# Complex bools that allow setting multiple bool values without interfering
#	with each other; e.g. allowed_to_move could be set false by an animator
#	and a status effect, but still remain false after the effect clears

# Conditionals default to true but evaluate false if even one false is present

# Any change evaluates whether the output would have changed, and emits
# a signal if it has.

##############################################################################

# signals emitted if the state changes after an add or remove call
signal now_false()
signal now_true()

var _conditions = {}

##############################################################################


# assign new conditional value
func add(arg_key, arg_value: bool) -> void:
	var start_state = is_true()
	_conditions[arg_key] = arg_value
	_check_state_change(start_state, is_true())


# getter
func is_true() -> bool:
	var outcome := true
	for conditional_value in _conditions.values():
		if typeof(conditional_value) == TYPE_BOOL:
			outcome = (conditional_value and outcome)
	return outcome


# Returns true if the given key was present, false otherwise.
func remove(arg_key) -> bool:
	var start_state = is_true()
	var has_changed: bool = _conditions.erase(arg_key)
	_check_state_change(start_state, is_true())
	return has_changed


##############################################################################


# does nothing if output state is still the same
func _check_state_change(arg_previous_state: bool, arg_current_state: bool):
	if arg_previous_state != arg_current_state:
		if arg_current_state == true:
			emit_signal("now_true")
		else:
			emit_signal("now_false")

