extends Node

##############################################################################
#
# GameGlobal is the base class of all DDAT Globals
# Its purpose is twofold.
#	1) Avoid duplication of code between globals.
#	2) Allow configuration options to be easily set on all globals.
#
##############################################################################
#
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#
#05. signals
#06. enums
#07. constants
#08. exported variables
#09. public variables
#10. private variables
#11. onready variables

##############################################################################


func log_error():
	pass

######################################
##################################
#########################

#const UNIT_TEST_ENTRY_LOG_TO_CONSOLE = false
#
#const PRINT_FULL_STACK_TRACE = true
#
#var is_disk_log_called_this_runtime = false
#
## switchable vars to control how error logging functions
## global scope so can be changed before calling groups that will throw errors
#var debug_build_log_to_console = false #false #tempdisable
#var debug_build_log_to_disk = false
## should always be false so removed
##var release_build_log_to_console = false
#var release_build_log_to_disk = false
#
#var debug_build_log_to_godot_file_logger = true
#var release_build_log_to_godot_file_logger = true
#
#var unit_test_log = []
#
################################################################################
#
## initial debug log statements
#func _ready():
#	if enable_verbose_logging:
#		autoload_on_ready_logging(name, false)
#	var datetime = OS.get_datetime()
#	var date_string = str(datetime["year"])+"/"+str(datetime["month"])+"/"+str(datetime["day"])
#	var timestamp_string = str(datetime["hour"])+":"+str(datetime["minute"])+":"+str(datetime["second"])
#	print("debug log start: "+date_string+" | "+timestamp_string)
#	print("["+OS.get_model_name()+"]")
#	print("["+OS.get_name()+"]")
#	# emptyline
#	print()
#	if enable_verbose_logging:
#		autoload_on_ready_logging(name, true)
#
#
## override of error logging for build 0.2.6
#func log_error(error_string: String = ""):
#	print(error_string)
#	pass
#
## expansion of error logging capabilities
#func log_error_ext(error_string: String = ""):
#	if enable_verbose_logging:
#		print("global_debug calling log_error()")
#	var full_error_string = "| DBGMGR ERROR! |"
#	var full_stack_trace = get_stack()
#	# TODO IDV2 temp removal of DebugBuild stack trace decorator
##	var error_call = full_stack_trace
##	var error_func = "[stack func blank]"
##	var error_node = "[stack node blank]"
##	var error_line = "[stack line blank]"
#	# deprecated due to startup crash
##	if full_stack_trace is Array:
##		error_call = full_stack_trace[1]
##		error_func = error_call["function"]
##		error_node = error_call["source"]
##		error_line = error_call["line"]
##	full_error_string += (" ["+str(error_node))+"]"
##	full_error_string += (" ["+str(error_func)+" line "+str(error_line))+"]"
#	if error_string != "":
#		full_error_string += (" |\n"+"| ERROR CODE: | "+error_string)
#	if PRINT_FULL_STACK_TRACE:
#		full_error_string += (" |\n"+"| FULL STACK TRACE: | "+str(full_stack_trace))
##	print("temp > ", get_stack())
##	print("temp[0] > ", get_stack()[0])
##	print("temp[1] > ", get_stack()[1])
#	_log_error_handler(full_error_string)
#
#
## original error logging
#func _log_error_handler(error_string):
#	if enable_verbose_logging:
#		print("global_debug calling _log_error_handler()")
#	if OS.is_debug_build() and debug_build_log_to_console:
#		_log_error_to_console(error_string)
#
#	if OS.is_debug_build() and debug_build_log_to_disk:
#		_log_error_to_disk(error_string)
#	elif not OS.is_debug_build() and release_build_log_to_disk:
#		_log_error_to_disk(error_string)
#
#	if OS.is_debug_build() and debug_build_log_to_godot_file_logger:
#		print_debug(error_string)
#	elif not OS.is_debug_build() and release_build_log_to_godot_file_logger:
#		print_debug(error_string)
#
#
#func _log_error_to_console(error_string):
#	if enable_verbose_logging:
#		print("global_debug calling _log_error_to_console()")
#	print(error_string)
#
#
## NOTE: this has been superceded by godot's internal logging system,
## which I wasn't aware of when I wrote this
#func _log_error_to_disk(error_string):
#	if enable_verbose_logging:
#		print("global_debug calling _log_error_to_disk()")
#
#	# log cycling
#	var current_file_content
#	if not is_disk_log_called_this_runtime:
#			# move log file 2 to file 3, if file 2 exists
#		if GlobalData.validate_file_path(GlobalRef.ERROR_LOG_USER_2):
#			current_file_content = GlobalData.open_and_return_file_as_string(GlobalRef.ERROR_LOG_USER_2)
#			GlobalData.open_and_overwrite_file_with_string(GlobalRef.ERROR_LOG_USER_3, current_file_content, true)
#
#			# move log file 1 to file 2, if file 1 exists
#		if GlobalData.validate_file_path(GlobalRef.ERROR_LOG_USER_1):
#			current_file_content = GlobalData.open_and_return_file_as_string(GlobalRef.ERROR_LOG_USER_1)
#			GlobalData.open_and_overwrite_file_with_string(GlobalRef.ERROR_LOG_USER_2, current_file_content, true)
#
#		is_disk_log_called_this_runtime = true
#
#	GlobalData.open_and_overwrite_file_with_string(GlobalRef.ERROR_LOG_USER_1, error_string, true)
#
#
#	# on all run write to #1 disk
#	error_string = error_string
#
#
################################################################################
#
#
## deprecating
#func log_unit_test(test_outcome, origin_script, test_purpose):
#	if enable_verbose_logging:
#		print("global_debug calling log_unit_test()")
#	unit_test_log.append(test_outcome)
#	if UNIT_TEST_ENTRY_LOG_TO_CONSOLE:
#		print("outcome: "+str(test_outcome).to_upper()+" | from: "+str(origin_script)+" | purpose: "+str(test_purpose))
#
## deprecating
#func execute_unit_test(optional_identifier_string = null):
#	if enable_verbose_logging:
#		print("global_debug calling execute_unit_test()")
#	var print_string = ""
#
#	for test in unit_test_log:
#		if test == false:
#			print_string = "||| UNIT TEST FAILED |||"
#			if typeof(optional_identifier_string) == TYPE_STRING:
#				print_string = print_string+" | "+optional_identifier_string+" |"
#			unit_test_log.clear()
#			print(print_string)
#			return false
#
#	print_string = "||| UNIT TEST PASSED |||"
#	if typeof(optional_identifier_string) == TYPE_STRING:
#		print_string = print_string+" | "+optional_identifier_string+" |"
#	unit_test_log.clear()
#	print(print_string)
#	return true
#
#
#########
#
#
## public method to test whether a method's actual return value matches the
## expected return value, use for testing simple methods with a return value
## arg 1: self (usually)
## arg 2: an array of values to be tested, at least 2, expected to be equal
#func unit_test_comparison_of_values(\
#caller: Object,\
#comparator_values = []):
#	if enable_verbose_logging:
#		print("global_debug calling unit_test_comparison_of_values()")
#	# check if is a valid test
#	if not comparator_values.size() <= 1:
#		var result = true
#		var last_value = null
#		var first_error_value = null
#		for value in comparator_values:
#			if last_value != null:
#				result = (result)==(value==last_value)
#				if result == false and first_error_value == null:
#					first_error_value = value
#			last_value = value
#
#		# output first line
#		var first_line_log_string = "###"+" UT Comparison of Values"
#		if result == null:
#			print(first_line_log_string + " | no result")
#		elif result == true:
#			print(first_line_log_string +\
#					" | result OUTPUT MATCHES")
#		elif result == false:
#			print(first_line_log_string +\
#					" | result OUTPUT DOES NOT MATCH")
#
#		# output second line
#		if caller.get("name"):
#			print("on object ",	str(caller), " (", str(caller.name), ")")
#		else:
#			print("on object ", str(caller))
#
#		# output third line
#		if comparator_values != null:
#			print(" | Compared Values: ", comparator_values)
#		#
#		# output fourth line
#		if first_error_value != null:
#			print(" | first non matching value: ", first_error_value)
#
#	# fail state no method / called incorrectly, log error
#	else:
#		log_error("unit_test_comparison_of_values attempted with on "\
#				+str(caller)+" but not enough values were passed. ")
#
#
#
## public method to test whether a method's actual return value matches the
## expected return value, use for testing simple methods with a return value
## arg 1: self (usually)
## arg 2: method name to be tested
## arg 3: expected value if any
## arg 4: values to be passed within an array
#func unit_test_expected_output_comparison(\
#caller: Object,\
#method_name: String,\
#method_values: Array = [],\
#expected_return_value = null):
#	if enable_verbose_logging:
#		print("global_debug calling unit_test_expected_output_comparison()")
#	# check if is a valid test
#	if caller.has_method(method_name):
#		var actual_return_value = null
#		var result = null
#		actual_return_value = caller.callv(method_name, method_values)
#		# get if output of the method matches expected output
#		if expected_return_value != null:
#			result = (expected_return_value == actual_return_value)
#
#		# output first line
#		var first_line_log_string = "###"+" UT Expected Output Comparison"
#		if result == null:
#			print(first_line_log_string + " | no result")
#		elif result == true:
#			print(first_line_log_string +\
#					" | result OUTPUT MATCHES")
#		elif result == false:
#			print(first_line_log_string +\
#					" | result OUTPUT DOES NOT MATCH EXPECTED")
#
#		# output second line
#		if caller.get("name"):
#			print("on method ", method_name, " of object ",\
#					str(caller), " (", str(caller.name), ")")
#		else:
#			print("on method ", method_name, " of object ", str(caller))
#		# output third line
#		if expected_return_value != null:
#			print(" | Expected Result: ", expected_return_value)
#		# output third line
#		if actual_return_value != null:
#			print(" | Actual Result: ", actual_return_value)
#		else:
#			print(" | No Output")
#		# step output log
#		print("")
#
#	# fail state no method / called incorrectly, log error
#	else:
#		log_error("unit_test_expected_output_comparison attempted with "\
#				+method_name+" on "\
#				+str(caller)+" but method was not found ")
#
