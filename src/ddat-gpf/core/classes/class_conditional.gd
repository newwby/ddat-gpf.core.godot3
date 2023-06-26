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
signal outcome_changed(new_outcome)
signal outcome_checked()
signal outcome_is_now_false()
signal outcome_is_now_true()

const DEFAULT_OUTCOME := true

var _conditions := {}

# the outcome of the conditional - is only recalculated when a key is
# added, removed, or changed
# defaults to true
var _current_outcome := DEFAULT_OUTCOME

##############################################################################


# assign new conditional value or overwrite an existing one
func add(arg_key, arg_value: bool) -> void:
	_conditions[arg_key] = arg_value
	_update_current_outcome()


func get_condition(arg_key):
	if _conditions.has(arg_key):
		return _conditions[arg_key]
	else:
		return null


func has_condition(arg_key) -> bool:
	return _conditions.has(arg_key)


# getter
func is_true() -> bool:
	return _current_outcome


# Returns true if the given key was present, false otherwise.
func remove(arg_key) -> bool:
	var has_changed: bool = _conditions.erase(arg_key)
	_update_current_outcome()
	return has_changed


##############################################################################


# does nothing if output state is still the same
func _check_state_change(
		arg_previous_state: bool,
		arg_current_state: bool) -> void:
	emit_signal("outcome_checked")
	if arg_previous_state != arg_current_state:
		if arg_current_state == true:
			emit_signal("outcome_is_now_true")
			emit_signal("outcome_changed", true)
		else:
			emit_signal("outcome_is_now_false")
			emit_signal("outcome_changed", false)


# checks the conditional state and emits conditional state changed signals
func _update_current_outcome() -> void:
	var start_state = is_true()
	var outcome := DEFAULT_OUTCOME
	for conditional_value in _conditions.values():
		if typeof(conditional_value) == TYPE_BOOL:
			outcome = (conditional_value and outcome)
	_current_outcome = outcome
	_check_state_change(start_state, is_true())

