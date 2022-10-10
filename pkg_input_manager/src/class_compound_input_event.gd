extends InputEventAction

class_name CompoundInputEventAction

"""
CompoundInputEventActions allow for advanced button inputs, such as double
press inputs within a recent window, holding a button down for a fixed period
(short or long), or requiring other inputEventActions to fire within a recent
prior window.
"""

#############################################################################

# max system uticks since something happened for it to have happened 'recently'
const ACTION_RECENT: int = 100
# minimum system uticks for an action to be held to constitute a 'short press'
const ACTION_SHORT_HOLD_PRESS: int = 50
# minimum system uticks for an action to be held to constitute a 'long press'
const ACTION_LONG_HOLD_PRESS: int = 200

# system uticks when action was last first pressed or released
# used for calculating recency of action
var _tick_stamp_action_last_pressed: int = 0
var _tick_stamp_action_last_released: int = 0

# is action pressed/released within 'recent' tick window
# used for calculating double taps/double presses
var _is_recently_pressed: bool = false
var _is_recently_released: bool = false

# if action continually pressed, system utick duration it has been pressed for
var _tick_stamp_duration_held: int = 0

# used for calculating combo actions
# prerequisite input events must have happened recently to 
# preqrequisite input events are signalled via the events
var _prerequisite_input_event: Array = []
var _prereq_input_event_tickstamps: Dictionary = {
	"event_name" : 0,
}
# POPULATE PREREQ_INPUT_EVENT_TICKSTAMPS AUTOMATICALLY AT INIT
# ADD FUNC FOR RECIEVING SIGNAL AND STARTING TIMER
# ADD PUBLIC METHODS FOR SETTING PRIVATE PARAMETERS ABOVE

# events with a higher priority are processed first
var _event_priority: int = 1

var is_action_double_pressed: bool = false
var is_action_short_pressed: bool = false
var is_action_long_pressed: bool = false
# if an action is a combo event (it has prerequisite input events) it must have
# the combo of events met recently in order to be valid
var is_action_combo_event: bool = false
var is_action_combo_met: bool = false

#############################################################################

