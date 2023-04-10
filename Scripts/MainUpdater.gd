extends Control
export(int) var VersionNumber = 0
var HttpRequest: HTTPRequest

func _ready():
	_initialize_file_links()
	if file_exists("user://Version"):
		var file = File.new()
		file.open("user://Version", File.WRITE)
		file.store_string(VersionNumber)
		file.close()
	_get_launcherDetails()
func _get_launcherDetails():
	HttpRequest=HTTPRequest.new()
	HttpRequest.connect("request_completed",self,"_receive_launcherDetails")
	HttpRequest.request("")
func _receive_launcherDetails(result, _response_code, _headers, body):
	if result==0:
		pass

#Functions
func file_exists(path: String):
	var dir=Directory.new()
	return dir.file_exists(path)
func _initialize_file_links():#For uploading purposes only
	var HostData = {
		"EliteCardWars":{
			"Version":"1.0.41",
			"FileLink":"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.1.zip",#"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip",
			"FileName":"EliteCardWars.exe",
			"ThumbnailLink":"https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/Thumbnails/EliteCardWars.JPG"
		},
		"EliteCardWarsBeta":{
			"Version":"0.0.1",
			"FileLink":"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip",
			"FileName":"EliteCardWars.exe"
		},
		"InvalidGame":{
		},
		"GameTestHere":{
			
		},
		"OtherThing":{
			"Version":"0.0.1",
			"FileLink":""
		}
	}
	var UpdaterData={
		"Link":"",
		"Version":0
	}
	var file=File.new()
	file.open("res://GameFileLinks/HostData.json",File.WRITE)
	file.store_string(to_json(HostData))
	file.close()
	file=File.new()
	file.open("res://GameFileLinks/LauncherData.json",File.WRITE)
	file.store_string(to_json(UpdaterData))
	file.close()
