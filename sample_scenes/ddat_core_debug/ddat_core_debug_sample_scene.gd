extends Node2D

#
##############################################################################
#
# Sample Scene to demonstrate the functionality of GlobalDebug
# This currently covers:
# [ ] error logging
# [ ] success logging
# [X] the developer debugging overlay
# [ ] the developer action menu
#
##############################################################################

# for passing to error logging
const SCRIPT_NAME := "script_name"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

# which events to monitor (generated from project inputMap)
var monitored_events := []
# record of how many times a monitored event has been pressed
var pressed_event_register := {}

# timer of how many seconds have passed since scene started
var scene_duration_seconds := 0
var scene_duration_minutes := 0
var scene_duration_hours := 0

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# test values
#	GlobalDebug.update_debug_overlay("testlabel2", 45)
#	GlobalDebug.update_debug_overlay("testlabel3", "supercallifragilistic")
#	GlobalDebug.update_debug_overlay("testlabel4", true)
#	GlobalDebug.update_debug_overlay("testlabel5", HBoxContainer)
#	GlobalDebug.update_debug_overlay("testlabel6_with_a_longer_name", self.position)
	#
	for action_string in InputMap.get_actions():
		monitored_events.append(action_string)
	
	# initial scene duration push to overlay
	update_scene_duration_string()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass

func _input(event):
	var increment := 1
	for action_string in monitored_events:
		if event.is_action_pressed(action_string):
			if action_string in pressed_event_register:
				pressed_event_register[action_string] += increment
			else:
				pressed_event_register[action_string] = increment
			# action string key, instances for value
			GlobalDebug.update_debug_overlay(
					action_string,
					pressed_event_register[action_string])
			print(pressed_event_register)


func update_scene_clock_vars():
	if scene_duration_seconds >= 60:
		scene_duration_seconds = 0
		scene_duration_minutes += 1
	if scene_duration_minutes >= 60:
		scene_duration_minutes = 0
		scene_duration_hours += 1


func update_scene_duration_string():
	var duration_string := ""
	var hours_elapsed_as_string := "0"
	var minutes_elapsed_as_string := "00"
	var seconds_elapsed_as_string := "00"
	
	if scene_duration_hours > 0:
		hours_elapsed_as_string = str(scene_duration_hours)
	
	if scene_duration_minutes > 0:
		minutes_elapsed_as_string = str(scene_duration_minutes)
	
	# account for 01 -> 09
	var scene_seconds_elapsed_as_string = str(scene_duration_seconds)
	if scene_seconds_elapsed_as_string.length() == 1:
		scene_seconds_elapsed_as_string =\
				"0"+scene_seconds_elapsed_as_string
		seconds_elapsed_as_string = scene_seconds_elapsed_as_string
	else:
		seconds_elapsed_as_string = str(scene_duration_seconds)
	
	duration_string =\
			hours_elapsed_as_string + ":" +\
			minutes_elapsed_as_string + ":" +\
			seconds_elapsed_as_string
	
	# push to debug overlay
	GlobalDebug.update_debug_overlay(
		"Scene Duration",
		duration_string
	)


func _on_SceneDuration_timeout():
	scene_duration_seconds += 1
	update_scene_clock_vars()
	update_scene_duration_string()
