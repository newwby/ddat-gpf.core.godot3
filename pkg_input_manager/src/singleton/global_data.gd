extends Node


# validate file paths are strings and valid before we do anything with them
# this will probably need to be called on any attempt at opening a file,
# so it is its own function
func validate_file_path(file_path):
	var data_file = File.new()
	if not file_path is String:
		# log error
		return false
	elif not data_file.file_exists(file_path):
		# log error
		return false
	else:
		return true


func open_and_return_file_as_string(file_path):
	if not validate_file_path(file_path):
		return ""
	else:
		var data_file = File.new()
		
		if data_file.open(str(file_path), File.READ) != OK:
			return ""
		else:
			var file_content = data_file.get_as_text()
			data_file.close()
			if typeof(file_content) == TYPE_STRING:
				return str(file_content)
			else:
				return ""


func open_and_overwrite_file_with_string(file_path, new_string, override_validation = false):
	if not validate_file_path(file_path) and not override_validation:
		return
	else:
		var data_file = File.new()
		if data_file.open(file_path, File.WRITE) != OK:
			return
		else:
			if typeof(new_string) == TYPE_STRING:
				data_file.store_string(new_string)
			data_file.close()


func open_and_return_file_json_str_as_dict(file_path):
	var file_as_json_str = open_and_return_file_as_string(file_path)
	var file_as_dict
	# intercept json parse error
	if file_as_json_str != "":
		file_as_dict = JSON.parse(file_as_json_str).result
	else:
		# log error
		pass
	if typeof(file_as_dict) == TYPE_DICTIONARY:
		return file_as_dict
	else:
		# log error
		pass


func open_and_overwrite_file_with_json_dict(file_path, new_dict, override_validation = false):
	if typeof(new_dict) == TYPE_DICTIONARY:
		# convert dict to json formatted str and pass to str function
		var file_content_as_str = str(to_json(new_dict))
		open_and_overwrite_file_with_string(file_path, file_content_as_str, override_validation)
	else:
		pass
		# log error

