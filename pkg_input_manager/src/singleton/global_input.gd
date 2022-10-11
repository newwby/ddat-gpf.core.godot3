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
const TEMP_DATA_PATH = "res://pkg_input_manager/def/input_actions/"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# takes the project InputMap and saves each inputEventAction as a .tres
# resource file within the designation definition folder
func _export_project_input_map_to_disk():
	var save_path_extension = ".tres"
	var action_identifier
	var input_event_action_list
	var event_index
	var save_path
	# gets the inputActions
	for input_map_action in InputMap.get_actions():
		# gets the inputEventActions
		action_identifier = str(input_map_action)
		input_event_action_list = InputMap.get_action_list(input_map_action)
		for input_event in input_event_action_list:
			event_index = str(input_event_action_list.find(input_event))
			save_path = action_identifier+"_"+event_index+save_path_extension
			
			if ResourceSaver.save(TEMP_DATA_PATH+save_path, input_event) != OK:
				# if not saved then error print to debug
				print_debug(get_stack())
		
