extends Node2D

# placeholder_autoload_input
const GLOBAL_INPUT_PATH = "res://pkg_input_manager/src/singleton/global_input.gd"
onready var GlobalInput = preload(GLOBAL_INPUT_PATH).new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	GlobalInput._export_project_input_map_to_disk()
#	CompoundActionExtension.new()
	var save_path = "res://pkg_input_manager/def/caex.tres"
	var caex = CompoundActionExtension.new()
	caex.test_var = 45
	var result = ResourceSaver.save(save_path, caex)
	print(save_path)
#	print(ResourceSaver.get_recognized_extensions(Shader.new()))
	assert(result == OK)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

