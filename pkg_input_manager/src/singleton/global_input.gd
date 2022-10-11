extends Node

# GlobalInputManager
# This is designed as an autoload singleton
# Functionality includes:
#	*) automatic export of project input map to disk
#	*) configuration of project input map (at runtime) from .tres on disk
#	*) creation of compound action extensions from inputMap actions
#	*) functionality of compound action extensions (input variance)
#	*) handling of alternate inputs per action and alternate platforms

# for test environment
const TEMP_DATA_PATH = "res://pkg_input_manager/def/input_actions"

# manual load instead of using project autoloader
# temporary remove on framework export
const GLOBAL_DATA_PATH = "res://pkg_input_manager/src/singleton/global_data.gd"
#onready var GlobalData = preload(GLOBAL_DATA_PATH).new()

###############################################################################

# takes the project InputMap and saves each inputEventAction as a .tres
# resource file within the designation definition folder
func _export_project_input_map_to_disk():
	# temporary whilst autloader isn't present
	var GlobalData = preload(GLOBAL_DATA_PATH).new()
	# base file path building variables
	var base_directory_path = TEMP_DATA_PATH
	var directory_path
	var file_path
	var save_path_extension = ".tres"
	# refs for properties of input actions, converted to string for file path
	var action_identifier
	var input_event_action_list
	var event_index
	var event_class
	
	# gets the inputActions
	for input_map_action in InputMap.get_actions():
		# gets the inputEventActions
		action_identifier = str(input_map_action)
		input_event_action_list = InputMap.get_action_list(input_map_action)
		for input_event in input_event_action_list:
			event_class = str(input_event.get_class())
			event_index = str(input_event_action_list.find(input_event))
			# input event resources are stored in a folder named after the
			# corresponding action, located in the base directory
			# file name equals class name and index in the action list array
			directory_path =\
					base_directory_path+"/"+action_identifier+"/"
			file_path =\
					event_index+"_"+event_class+save_path_extension
#					action_identifier+"_"+event_index+save_path_extension
			
			if GlobalData.validate_directory(directory_path, true):
				if ResourceSaver.save(directory_path+file_path, input_event) != OK:
					# if not saved then error print to debug
					print_debug(get_stack())
			else:
				print_debug(get_stack())
		
