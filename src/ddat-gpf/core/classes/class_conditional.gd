extends Reference

class_name Conditional

##############################################################################

# Complex bools that allow setting multiple bool values without interfering
#	with each other; e.g. allowed_to_move could be set false by an animator
#	and a status effect, but still remain false after the effect clears

# Conditionals default to true but evaluate false if even one false is present

##############################################################################

var _conditions = {}

##############################################################################


# assign new conditional value
func add(arg_key, arg_value: bool) -> void:
	_conditions[arg_key] = arg_value


# getter
func is_true() -> bool:
	var outcome := true
	for conditional_value in _conditions.values():
		if typeof(conditional_value) == TYPE_BOOL:
			outcome = (conditional_value and outcome)
	return outcome


# Returns true if the given key was present, false otherwise.
func remove(arg_key) -> bool:
	return _conditions.erase(arg_key)

