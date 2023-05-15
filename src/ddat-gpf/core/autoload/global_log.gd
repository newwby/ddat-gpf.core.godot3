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
	# you didn't remember
#	error(self, "testing logging please remember to disable this")
#	info(self, "testing logging please remember to disable this")
#	trace(self, "testing logging please remember to disable this")
#	warning(self, "testing logging please remember to disable this")


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

