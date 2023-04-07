extends Button

var zipLink=""

var ZipPath="user://EliteCardWarsGame.zip"
var ZipLink="https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip"
var version_path

var http_request: HTTPRequest

func _ready():
	self.disabled=true
	var IsUpdate=CheckForAnyUpdates()

func CheckForAnyUpdates():
	return true

func file_exists(path: String):
	var dir=Directory.new()
	return dir.file_exists(path)

#func _ready():
#	_verify_gamefiles()
#	self.disabled=true
#
#func file_exists(path: String):
#	var dir=Directory.new()
#	return dir.file_exists(path)
#
#func _verify_gamefiles():
#	#Check game files are complete
#	if file_exists(GamePath):
#		_download_file(version_link,version_path,true)
#	else:
#		_check_integrity()
#
#func _download_file(link:String, path:String, just_version:bool):
#	#Create a Http req node and connect its completion signal
#	http_request = HTTPRequest.new()
#	add_child(http_request)
#
#	self.text="Downloading "+str(path.get_file())
#	http_request.connect("_request_completed",self,"_install_file",[path,just_version])
#	var error=http_request.request_raw(link)
#	if error!=OK:
#		self.text="Error: "+str(error)
#
#func _install_file(_result,_response_code,_headers,body,path,just_version:bool):
#	if just_version:
#		var new_version=str(body.get_string_from_utf8())
#		_compare_version(new_version)
#		return
#
#	var dir=Directory.new()
#	dir.remove(path)
#
#	var file=File.new()
#	file.open(path,File.WRITE)
#	file.store_buffer(body)
#	file.close()
#	#Check integrity
#	_check_integrity()
#
#func _check_integrity():
#	if file_exists(GamePath):
#		_download_file(zipLink,GamePath,false)
#		print("Missing Zip Game")
#		return
#
#func _compare_version(new_version):
#	#read current version
#	var file=File.new()
#	var version_path=""
#	file.open(version_path, File.READ)
#	var cur_version=file.get_as_text()
#	file.close()
#	#compare
#	if int(new_version)>cur_version:
#		var dir=Directory.new()
#		dir.remove(version_path)
#	_check_integrity()
#
#func _on_Button_pressed():
#	pass
