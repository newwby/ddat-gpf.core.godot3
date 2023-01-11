extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
#	var c
	GlobalData.save_to_file()
	var c = GlobalData.load_from_file()
	print(c.get_class())
	print(c.is_class("Node"))
	print(c.is_class("CustomObject"))
	print(c is CustomObject)
	if c is CustomObject:
		c.say_hello()
	else:
		print("inval obj")
	if c != null:
		if c.has_method("say_hello"):
			c.say_hello()
		if c.has_method("get_property_list"):
			for prop in c.get_property_list():
				print(prop)
#			print(c.get_property_list())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
