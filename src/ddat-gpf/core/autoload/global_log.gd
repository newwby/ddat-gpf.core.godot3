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

# if you wish to globally disable a log type you can do so here
const ALLOW_ERROR := true
const ALLOW_INFO := true
const ALLOW_TRACE := true
const ALLOW_WARNING := true

# if set true, all logs will be saved and remembered during the run session
# if set false logs will not be remembered (though they will still be
# output to console and consequently the user log files)
# logs made whilst this is set false cannot be recovered
var record_logs := true

# record of who logged what and when
# nothing is recorded if record_logs is set to false
var log_register = {}

onready var coderef = ErrorCodes.new()

##############################################################################


class LogRecord:
	var owner: Object
	var timestamp: int
	var log_code_id: int
	var log_code_name: String
	var log_message: String
	var full_log_string: String
	
	func _init(
			arg_owner: Object,
			arg_log_timestamp: int,
			arg_log_code_id: int,
			arg_log_code_name: String,
			arg_log_message: String,
			arg_log_string: String
			):
		self.owner = arg_owner
		self.timestamp = arg_log_timestamp
		self.log_code_id = arg_log_code_id
		self.log_code_name = arg_log_code_name
		self.log_message = arg_log_message
		self.full_log_string = arg_log_string


##############################################################################

# virtual methods


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	error(self, "testing logging please remember to disable this")
	info(self, "testing logging please remember to disable this")
	trace(self, "testing logging please remember to disable this")
	warning(self, "testing logging please remember to disable this")


##############################################################################

# public methods


# see _log for parameter explanation
func error(arg_caller: Object, arg_error_message):
	_log(arg_caller, arg_error_message, 1)


# see _log for parameter explanation
func info(arg_caller: Object, arg_error_message):
	_log(arg_caller, arg_error_message, 4)


# see _log for parameter explanation
func trace(arg_caller: Object, arg_error_message):
	_log(arg_caller, arg_error_message, 3)


# see _log for parameter explanation
func warning(arg_caller: Object, arg_error_message):
	_log(arg_caller, arg_error_message, 2)


##############################################################################

# private methods

# method to check log is allowed (by ALLOW_ consts) before it goes ahead
# if passed an invalid log code (i.e. not in the enum), will return false
# if passed 'LOG_CODES.UNDEFINED' will return true
func _can_log(arg_log_code: int = 0) -> bool:
	match arg_log_code:
		LOG_CODES.UNDEFINED:
			return true
		LOG_CODES.ERROR:
			return ALLOW_ERROR
		LOG_CODES.INFO:
			return ALLOW_INFO
		LOG_CODES.TRACE:
			return ALLOW_TRACE
		LOG_CODES.WARNING:
			return ALLOW_WARNING
	# anything not in LOG_CODES enum will reach here
	return false


# main logging method
# prints to console or pushes a warning/error
# [param]
# #1, arg_caller - identifier for method caller, pass as self
#		will return self.name if name can be found
# #2, arg_error_message - ERR message
#		this can be a custom string, a value you want printed, an ERR
#		constant from globalScope or a key from the ErrorCodes class
# #3, arg_log_code - passed from the public logging methods
#		refers to the type of log (i.e. ERROR, WARNINGING, TRACE, or INFO),
#		and influences whether is printed or pushed
func _log(
		arg_caller: Object,
		arg_error_message,
		arg_log_code: int = 0
		):
	# check the log type is valid (see ALLOW_ consts/_can_log method)
	if not _can_log(arg_log_code):
		return
	
	var caller_id: String = str(arg_caller)
#	if "name" in arg_caller:
#		caller_id += ": "+arg_caller.name
	
	var full_error_message: String
	if coderef.is_key(arg_error_message):
		full_error_message = coderef.get_error_string(arg_error_message)
	else:
		full_error_message = str(arg_error_message)
	
	var log_code_id: int =\
			arg_log_code if arg_log_code in LOG_CODES.values() else 0
	var log_code_name: String = str(LOG_CODES.keys()[log_code_id])
	
	var log_timestamp = Time.get_ticks_msec()
	
	var full_log_string =\
			"[t{time}] {caller}\t[{type}] | {message}".format({
				"type": log_code_name,
				"time": log_timestamp,
				"caller": str(caller_id),
				"message": str(full_error_message)
				})
	
	# if recording all logs, create an object to remember it
	if record_logs:
		_update_log_register(
			arg_caller,
			LogRecord.new(arg_caller, log_timestamp, log_code_id,
					log_code_name, full_error_message, full_log_string)
			)
	
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


func _update_log_register(arg_caller: Object, arg_log_record: LogRecord):
	var caller_record
	if arg_caller in log_register.keys():
		caller_record = log_register[arg_caller]
		if typeof(caller_record) == TYPE_ARRAY:
			caller_record.append(arg_log_record)
		else:
			warning(self, "log_register entry for {e} != array".format({
					"e": arg_caller}))
	else:
		log_register[arg_caller] = [arg_log_record]


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
