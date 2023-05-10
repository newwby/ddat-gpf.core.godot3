extends GameGlobal

#class_name GlobalLog

##############################################################################

enum LOG_CODES {UNDEFINED, ERROR, WARNING, TRACE, INFO}

# if in debug mode, errors will force a false assertion and stop the project
const DEBUGGER_ASSERTS_ERRORS := false

# if false warnings/errors will be logged in release versions
# if true warnings/errors will be pushed and printed
const WARNINGS_PRINT_TO_CONSOLE := true
const ERRORS_PRINT_TO_CONSOLE := true

onready var coderef = ErrorCodes.new()

##############################################################################

# virtual methods


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


##############################################################################

# public methods


# see _log for parameter explanation
func error(arg_caller: Object, arg_error_code):
	_log(arg_caller, arg_error_code, 1)


# see _log for parameter explanation
func info(arg_caller: Object, arg_error_code):
	_log(arg_caller, arg_error_code, 4)


# see _log for parameter explanation
func trace(arg_caller: Object, arg_error_code):
	_log(arg_caller, arg_error_code, 3)


# see _log for parameter explanation
func warning(arg_caller: Object, arg_error_code):
	_log(arg_caller, arg_error_code, 2)


##############################################################################

# private methods


# main logging method
# prints to console or pushes a warning/error
# [param]
# #1, arg_caller - identifier for method caller, pass as self
#		will return self.name if name can be found
# #2, arg_error_code - ERR message
#		this can be a custom string, a value you want printed, an ERR
#		constant from globalScope or a key from the ErrorCodes class
# #3, arg_log_code - passed from the public logging methods
#		refers to the type of log (i.e. ERROR, WARNINGING, TRACE, or INFO),
#		and influences whether is printed or pushed
func _log(
		arg_caller: Object,
		arg_error_code,
		arg_log_code: int = 0
		):
	var log_message := ""
	
	var caller_id: String = str(arg_caller)
#	if "name" in arg_caller:
#		caller_id += ": "+arg_caller.name
	
	var error_code: String
	if coderef.is_key(arg_error_code):
		error_code = coderef.get_error_string(arg_error_code)
	else:
		error_code = str(arg_error_code)
	
	var log_code_id = arg_log_code if arg_log_code in LOG_CODES.values() else 0
	var log_code_name = LOG_CODES.keys()[log_code_id]
	
	var full_log_string =\
			"[log] "+str(log_code_name)+\
			" @ "+str(caller_id)+\
			" | Error Code: "+str(error_code)
	
	if arg_log_code == LOG_CODES.ERROR:
		push_error(full_log_string)
		# are all errors reason to stop project in debug mode?
		if DEBUGGER_ASSERTS_ERRORS and OS.is_debug_build():
			assert(2 == 3)
		if not ERRORS_PRINT_TO_CONSOLE:
			return
	
	elif arg_log_code == LOG_CODES.WARNING:
		push_warning(full_log_string)
		if not WARNINGS_PRINT_TO_CONSOLE:
			return
	
	# console output
	# only reachable by errors/warnings if print_to_console consts are set
	print(full_log_string)


######################
# OLD CONTENT BELOW
# THIS IS DEPRECATED BUT PRESENT IN GLOBALDEBUG

#############
#
#
#
## [Usage]
## use GlobalDebug.log_error() in methods at points where you do not expect
## the project to reach during normal runtime
## it is best practice to at least call this method with the name of the calling
## script and an identifier for the method, as release builds (non-debugger
## enabled builds) cannot pass detailed stack information.
## As an optional third argument, you may pass a more detailed string or
## code to help you locate the error.
## in release builds only these arguments will be printed to console/log.
## in debug builds, depending on developer settings, stack traces, error
## WARNINGings, and project pausing can be forced through this method.
#func log_error(\
#		calling_script: String = "",\
#		calling_method: String = "",\
#		error_string: String = "") -> void:
#	# if suspending logging, stop immediately
#	if OVERRIDE_DISABLE_ALL_LOGGING\
#	or _is_test_running:
#		return
#
#	# build error string through this method then print at end of method
#	# open all errors with a new line to keep them noticeable in the log
#	var print_string = "\nDBGMGR raised error"
#
#	# whether release or debug build, basic information must be logged
#	if calling_script != "":
#		print_string += " at {script}".format({"script": calling_script})
#
#	if calling_method != "":
#		print_string += " in {method}".format({"method": calling_method})
#
#	if error_string != "":
#		print_string += " [error code: {error}]".format({"error": error_string})
#
#	# debug builds have additional error logging behaviour
#	if OS.is_debug_build():
#		# get stack trace, split into something more readable
#		var full_stack_trace = get_stack()
#		var error_stack_trace = full_stack_trace[1]
#		var error_func_id = error_stack_trace["function"]
#		var error_node_id = error_stack_trace["source"]
#		var error_line_id = error_stack_trace["line"]
#		# entire stack trace is verbose, so multi-line for readability
#
#		print_string += "\nStack Trace: [{f}] [{s}] [{l}]".format({\
#				"f": error_func_id,
#				"s": error_node_id,
#				"l": error_line_id})
#		print_string += "\nFull Stack Trace: "
#
#	# close all errors with a new line to keep them noticeable in the log
#	print_string += "\n"
#
#	# with debugger running, and flag set, push as error rather than log print
#	if OS.is_debug_build() and PUSH_ERRORS_TO_DEBUGGER:
#		push_error(print_string)
#	# print regardless
#	print(print_string)
#
#	# if the appropriate flag is enabled, pause project on error call
#	if OS.is_debug_build() and ASSERT_ALL_ERRRORS:
#		assert(false, "fatal error, see last error")
#
#
## [Usage]
## use GlobalDebug.log_success in methods at points where you expect the
## project to reach during normal runtime
## it is best practice to call this method with at least the script name, and
## the method name, as release builds (non-debugger enabled builds) cannot
## pass detailed stack information.
## unlike with its counterpart log_error, log_success requires the calling
## script's name or id (str(self) will suffice) and calling method to be passed
## as arguments. This is to prevent log_success calls being left in the
## release build without a quick means of identifying where the call was made.
## [Rationale]
## LogSuccess is a replacement for the dev practice of leaving print statements
## in a release-candidate build as a method of debugging. It should be used
## in conjunction with a script-scope bool passed as the first argument. This
## flag can be disabled per script to provide finer debugging control.
## Devs can enable the FORCE_SUCCESS_LOGGING_IN_RELEASE_BUILDS to ignore the
## above behaviour and always print log_success calls to console.
## [Disclaimer]
## LogSuccess is not intended as catch-all solution, it is to be used in
## conjunction with testing, debug builds, and debugging tools such as
## the editor debugger and inspector.
#func log_success(
#		verbose_logging_enabled: bool,\
#		calling_script: String,\
#		calling_method: String,\
#		success_string: String = "") -> void:
#	# if suspending logging, stop immediately
#	if OVERRIDE_DISABLE_ALL_LOGGING\
#	or _is_test_running:
#		return
#
#	# log success is a debugging tool that should always be passed a bool
#	# from the calling script; if the bool arg is false, and the optional
#	# dev flag FORCE_SUCCESS_LOGGING_IN_RELEASE_BUILDS isn't set, this
#	# method will not do anything
#	if not verbose_logging_enabled\
#	and not FORCE_SUCCESS_LOGGING_IN_RELEASE_BUILDS:
#		return
#
#	# build the print string from arguments
#	var print_string = ""
#	print_string += "DBGMGR.log({script}.{method})".format({\
#			"script": calling_script,
#			"method": calling_method,
#			})
#
#	# if an optional argument was included, append it ehre
#	if success_string != "":
#		print_string += " [{success}]".format(\
#				{"success": success_string})
#
#	print(print_string)
#
#
## decorator for running a test function with globalDebug logging disabled
## returns a comparison of expected outcome and the bool result of the unit test
###1, 'unit_test', should be a function that returns a bool
###2, 'expected_outcome', is the bool you expect the func in param1 to return
#func log_test(
#		unit_test: FuncRef,
#		expected_outcome: bool):
#	# for checking whether the funcRef is set up correctly
#	# and whether it returns a bool
#	var is_test_valid: bool
#	var test_outcome: bool
#
#	# first, check the funcRef validity
#	is_test_valid = unit_test.is_valid()
#
#	# if can run the test
#	if is_test_valid:
#		# disable logging then run the function
#		self._is_test_running = true
#		test_outcome = unit_test.call_func()
#		self._is_test_running = false
#		# check return argument was valid
#		if typeof(test_outcome) == TYPE_BOOL:
#			is_test_valid = true
#		else:
#			is_test_valid = false
#
#	# logging statement for test
#	if is_test_valid:
#		var compare_outcomes = (expected_outcome == test_outcome)
#		var log_string =\
#				"SUCCESS - test outcome matches expected outcome."\
#				if compare_outcomes else\
#				"FAILURE - test outcome does not match expected outcome."
#
#		print("DBGMGR.log_test.{x} [{r}]".format({
#			"x": str(unit_test.function),
#			"r": log_string
#		}))
#		return compare_outcomes
#
#	# if either validation test failed
#	if not is_test_valid:
#		GlobalDebug.log_error(SCRIPT_NAME, "log_test",
#				"invalid test, is not valid funcref or does not return bool")
#
