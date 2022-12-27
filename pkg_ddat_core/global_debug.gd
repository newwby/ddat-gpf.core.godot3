extends GameGlobal

#class_name GlobalDebug

##############################################################################

# DDAT Debug Manager (or, GlobalDebug) is a singleton designed to aid in
# debugging projects, through error logging, faciliating exposure  of game
# parameters to the developer, and allowing the developer to quickly add
# 'god-mode' actions accessible through a simple UI.

##############################################################################

# developer flag, if set then all errors called through the log_error method
# will pause project execution through a false assertion (this functionality
# only applies to project builds with the debugger enabled).
# This flag has no effect on non-debugger/release builds.
const ASSERT_ALL_ERRRORS = false
# developer flag, if set all errors called through log_error will, in any
# build with the debugger enabled, raise the error in the debugger instead of
# as a print statement. No effect on non-debugger/release builds.
const PUSH_ERRORS_TO_DEBUGGER = true
# developer flag, if set the debugger will print a full stack trace (verbose),
# when log_error encounters an error. If unset only a partial/pruned stack
# trace will be included. No effect on non-debugger/release builds.
const PRINT_FULL_STACK_TRACE = true

###############################################################################


# debug manager prints some basic information about the user when ready
# with stdout.verbose_logging
func _ready():
	# get basic information on the user
	var user_datetime = OS.get_datetime()
	var user_model_name = OS.get_model_name()
	var user_name = OS.get_name()
	
	# convert the user datetime into something human-readable
	var user_date_as_string =\
			str(user_datetime["year"])+\
			"/"+str(user_datetime["month"])+\
			"/"+str(user_datetime["day"])
	# seperate into both date and time
	var user_time_as_string =\
			str(user_datetime["hour"])+\
			":"+str(user_datetime["minute"])+\
			":"+str(user_datetime["second"])
	
	print("debug manager readied at: "+\
			user_date_as_string+\
			" | "+\
			user_time_as_string)
	print("[user] {name}\n{model}".format({\
			"name": user_name,\
			"model": user_model_name}))


###############################################################################

# use GlobalDebug.LogError() in methods at points where you do not expect
# the project to reach
# it is best practice to at least call this method with the method name of the
# caller, as release builds (non-debugger enabled builds) cannot pass detailed
# stack information.
# As an optional third argument, you may pass a more detailed string or
# code to help you locate the error.
# in release builds only these arguments will be printed to console/log.
# in debug builds, depending on developer settings, stack traces, error
# warnings, and project pausing can be forced through this method.
static func log_error(\
		calling_script: String = "",\
		calling_method: String = "",\
		error_string: String = "") -> void:
	# build error string through this method then print at end of method
	# open all errors with a new line to keep them noticeable in the log
	var print_string = "\nDBGMGR raised error"
	
	# whether release or debug build, basic information must be logged
	if calling_script != "":
		print_string += " at {script}".format({"script": calling_script})
	
	if calling_method != "":
		print_string += " in {method}".format({"method": calling_method})
		
	if error_string != "":
		print_string += " [error code: {error}]".format({"error": error_string})
	
	# debug builds have additional error logging behaviour
	if OS.is_debug_build():
		# get stack trace, split into something more readable
		var full_stack_trace = get_stack()
		var error_stack_trace = full_stack_trace[1]
		var error_func_id = error_stack_trace["function"]
		var error_node_id = error_stack_trace["source"]
		var error_line_id = error_stack_trace["line"]
		# entire stack trace is verbose, so multi-line for readability
		
		print_string += "\nStack Trace: [{f}] [{s}] [{l}]".format({\
				"f": error_func_id,
				"s": error_node_id,
				"l": error_line_id})
		print_string += "\nFull Stack Trace: "
	
	# close all errors with a new line to keep them noticeable in the log
	print_string += "\n"
	
	# with debugger running, and flag set, push as error rather than log print
	if OS.is_debug_build() and PUSH_ERRORS_TO_DEBUGGER:
		push_error(print_string)
	else:
		print(print_string)
	
	# if the appropriate flag is enabled, pause project on error call
	if OS.is_debug_build() and ASSERT_ALL_ERRRORS:
		assert(false, "fatal error, see last error")


###############################################################################

# TODO

#debug stat tracking panel
# - dev uses signal to update a dict with name (key) and value
# - info panel updates automatically whenever the dict data changes
# - info panel alignment and instantiation (under canvas layer) done as part of global debug
#	- info panel orders itself alphabetically
#	- info panel inits canvas layer scaled to base project resolution but dev can override
# - option(oos) category organisation; default blank enum dev can customise
#	- info panel gets subheadings & dividers, empty category == hide
# - globalDebug adds action under F1 (default) for showing panel (this auto-behaviour can be overriden)
#
#debug action menu
# - dict to add a new method, key is button text and value is method name in file
# - after dev updates dict they add a method to be called when button is pressed
# - buttons without found methods aren't shown when panel is called
# - globalDebug adds action under F2 (default0 for showing debug action panel (auto-behaviour, can be overriden)
#
#debug logger function
# - uses isDebugBuild to read whether to get stack trace
# - otherwise just logs to console with print

# write tests for
# log_error()

##############################################################################

func legacy_methods_below():
	pass


###############################################################################

const UNIT_TEST_ENTRY_LOG_TO_CONSOLE = false

var is_disk_log_called_this_runtime = false

# switchable vars to control how error logging functions
# global scope so can be changed before calling groups that will throw errors
var debug_build_log_to_console = false #false #tempdisable
var debug_build_log_to_disk = false
# should always be false so removed
#var release_build_log_to_console = false
var release_build_log_to_disk = false

var debug_build_log_to_godot_file_logger = true
var release_build_log_to_godot_file_logger = true

var unit_test_log = []


###############################################################################


## override of error logging for build 0.2.6
#func log_error(error_string: String = ""):
#	if not verbose_logging:
#		print("debug manager raised error, enable verbose logging or run in debug mode")
#	pass

# expansion of error logging capabilities
func log_error_ext(error_string: String = ""):
	if verbose_logging:
		print("global_debug calling log_error()")
	var full_error_string = "| DBGMGR ERROR! |"
	var full_stack_trace = get_stack()
	# TODO IDV2 temp removal of DebugBuild stack trace decorator
#	var error_call = full_stack_trace
#	var error_func = "[stack func blank]"
#	var error_node = "[stack node blank]"
#	var error_line = "[stack line blank]"
	# deprecated due to startup crash
#	if full_stack_trace is Array:
#		error_call = full_stack_trace[1]
#		error_func = error_call["function"]
#		error_node = error_call["source"]
#		error_line = error_call["line"]
#	full_error_string += (" ["+str(error_node))+"]"
#	full_error_string += (" ["+str(error_func)+" line "+str(error_line))+"]"
	if error_string != "":
		full_error_string += (" |\n"+"| ERROR CODE: | "+error_string)
	if PRINT_FULL_STACK_TRACE:
		full_error_string += (" |\n"+"| FULL STACK TRACE: | "+str(full_stack_trace))
#	print("temp > ", get_stack())
#	print("temp[0] > ", get_stack()[0])
#	print("temp[1] > ", get_stack()[1])
	_log_error_handler(full_error_string)


# original error logging
func _log_error_handler(error_string):
	if verbose_logging:
		print("global_debug calling _log_error_handler()")
	if OS.is_debug_build() and debug_build_log_to_console:
		_log_error_to_console(error_string)

	if OS.is_debug_build() and debug_build_log_to_disk:
		_log_error_to_disk(error_string)
	elif not OS.is_debug_build() and release_build_log_to_disk:
		_log_error_to_disk(error_string)

	if OS.is_debug_build() and debug_build_log_to_godot_file_logger:
		print_debug(error_string)
	elif not OS.is_debug_build() and release_build_log_to_godot_file_logger:
		print_debug(error_string)


func _log_error_to_console(error_string):
	if verbose_logging:
		print("global_debug calling _log_error_to_console()")
	print(error_string)


# NOTE: this has been superceded by godot's internal logging system,
# which I wasn't aware of when I wrote this
func _log_error_to_disk(error_string):
	if verbose_logging:
		print("global_debug calling _log_error_to_disk()")

	# log cycling
#	var current_file_content
	if not is_disk_log_called_this_runtime:
		# removed due to lack of globalRef
		
			# move log file 2 to file 3, if file 2 exists
#		if GlobalData.validate_file_path(GlobalRef.ERROR_LOG_USER_2):
#			current_file_content = GlobalData.open_and_return_file_as_string(GlobalRef.ERROR_LOG_USER_2)
#			GlobalData.open_and_overwrite_file_with_string(GlobalRef.ERROR_LOG_USER_3, current_file_content, true)

			# move log file 1 to file 2, if file 1 exists
#		if GlobalData.validate_file_path(GlobalRef.ERROR_LOG_USER_1):
#			current_file_content = GlobalData.open_and_return_file_as_string(GlobalRef.ERROR_LOG_USER_1)
#			GlobalData.open_and_overwrite_file_with_string(GlobalRef.ERROR_LOG_USER_2, current_file_content, true)

		is_disk_log_called_this_runtime = true
	
	# removed due to lack of globalRef
#	GlobalData.open_and_overwrite_file_with_string(GlobalRef.ERROR_LOG_USER_1, error_string, true)


	# on all run write to #1 disk
	error_string = error_string


###############################################################################


# deprecating
func log_unit_test(test_outcome, origin_script, test_purpose):
	if verbose_logging:
		print("global_debug calling log_unit_test()")
	unit_test_log.append(test_outcome)
	if UNIT_TEST_ENTRY_LOG_TO_CONSOLE:
		print("outcome: "+str(test_outcome).to_upper()+" | from: "+str(origin_script)+" | purpose: "+str(test_purpose))

# deprecating
func execute_unit_test(optional_identifier_string = null):
	if verbose_logging:
		print("global_debug calling execute_unit_test()")
	var print_string = ""

	for test in unit_test_log:
		if test == false:
			print_string = "||| UNIT TEST FAILED |||"
			if typeof(optional_identifier_string) == TYPE_STRING:
				print_string = print_string+" | "+optional_identifier_string+" |"
			unit_test_log.clear()
			print(print_string)
			return false

	print_string = "||| UNIT TEST PASSED |||"
	if typeof(optional_identifier_string) == TYPE_STRING:
		print_string = print_string+" | "+optional_identifier_string+" |"
	unit_test_log.clear()
	print(print_string)
	return true


########


# public method to test whether a method's actual return value matches the
# expected return value, use for testing simple methods with a return value
# arg 1: self (usually)
# arg 2: an array of values to be tested, at least 2, expected to be equal
func unit_test_comparison_of_values(\
caller: Object,\
comparator_values = []):
	if verbose_logging:
		print("global_debug calling unit_test_comparison_of_values()")
	# check if is a valid test
	if not comparator_values.size() <= 1:
		var result = true
		var last_value = null
		var first_error_value = null
		for value in comparator_values:
			if last_value != null:
				result = (result)==(value==last_value)
				if result == false and first_error_value == null:
					first_error_value = value
			last_value = value

		# output first line
		var first_line_log_string = "###"+" UT Comparison of Values"
		if result == null:
			print(first_line_log_string + " | no result")
		elif result == true:
			print(first_line_log_string +\
					" | result OUTPUT MATCHES")
		elif result == false:
			print(first_line_log_string +\
					" | result OUTPUT DOES NOT MATCH")

		# output second line
		if caller.get("name"):
			print("on object ",	str(caller), " (", str(caller.name), ")")
		else:
			print("on object ", str(caller))

		# output third line
		if comparator_values != null:
			print(" | Compared Values: ", comparator_values)
		#
		# output fourth line
		if first_error_value != null:
			print(" | first non matching value: ", first_error_value)

	# fail state no method / called incorrectly, log error
	else:
		log_error("unit_test_comparison_of_values attempted with on "\
				+str(caller)+" but not enough values were passed. ")



# public method to test whether a method's actual return value matches the
# expected return value, use for testing simple methods with a return value
# arg 1: self (usually)
# arg 2: method name to be tested
# arg 3: expected value if any
# arg 4: values to be passed within an array
func unit_test_expected_output_comparison(\
caller: Object,\
method_name: String,\
method_values: Array = [],\
expected_return_value = null):
	if verbose_logging:
		print("global_debug calling unit_test_expected_output_comparison()")
	# check if is a valid test
	if caller.has_method(method_name):
		var actual_return_value = null
		var result = null
		actual_return_value = caller.callv(method_name, method_values)
		# get if output of the method matches expected output
		if expected_return_value != null:
			result = (expected_return_value == actual_return_value)

		# output first line
		var first_line_log_string = "###"+" UT Expected Output Comparison"
		if result == null:
			print(first_line_log_string + " | no result")
		elif result == true:
			print(first_line_log_string +\
					" | result OUTPUT MATCHES")
		elif result == false:
			print(first_line_log_string +\
					" | result OUTPUT DOES NOT MATCH EXPECTED")

		# output second line
		if caller.get("name"):
			print("on method ", method_name, " of object ",\
					str(caller), " (", str(caller.name), ")")
		else:
			print("on method ", method_name, " of object ", str(caller))
		# output third line
		if expected_return_value != null:
			print(" | Expected Result: ", expected_return_value)
		# output third line
		if actual_return_value != null:
			print(" | Actual Result: ", actual_return_value)
		else:
			print(" | No Output")
		# step output log
		print("")

	# fail state no method / called incorrectly, log error
	else:
		log_error("unit_test_expected_output_comparison attempted with "\
				+method_name+" on "\
				+str(caller)+" but method was not found ")

