extends Control
export(int) var VersionNumber = -1
var HttpRequest: HTTPRequest

func _ready():
	_initialize_file_links()
#	if file_exists("user://Version"):
#		var file = File.new()
#		file.open("user://Version", File.WRITE)
#		file.store_string(VersionNumber)
#		file.close()
#	_get_launcherDetails()
#func _get_launcherDetails():
#	HttpRequest=HTTPRequest.new()
#	add_child(HttpRequest)
#	HttpRequest.connect("request_completed",self,"_receive_launcherDetails")
#	var error=HttpRequest.request("https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/LauncherData.json")
#	if error!=OK:
#		print("Error Requesting Server Host Data: "+str(error))
#func _receive_launcherDetails(result, _response_code, _headers, body):
#	remove_child(HttpRequest)
#	if result==0:
#		var StringResult=body.get_string_from_utf8()
#		var LauncherData=JSON.parse(StringResult).result
#		print("Succesfully receive LauncherData")
#		if int(LauncherData["Version"])>VersionNumber:
#			print("Version Update Required")

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
		"PlatformerEngine":{
			"Version":"0.0.1",
			"FileLink":"https://github.com/Elfiawesome/GameLauncher/releases/download/OtherGames/PlatformerEngine.zip",
			"FileName":"PlatformerEngine.exe",
			"ThumbnailLink":"https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/Thumbnails/PlatformerEngine.jpg"
		},
		"LetThereBeChaos":{
			"Version":"0.0.1",
			"FileLink":"https://github.com/Elfiawesome/GameLauncher/releases/download/OtherGames/LetThereBeChaos.zip",
			"FileName":"LetThereBeChaos.exe",
			"ThumbnailLink":"https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/Thumbnails/LetThereBeChaos.jpg"
		},
		"SkyVessels2022":{
			"Version":"0.0.1",
			"FileLink":"https://github.com/Elfiawesome/GameLauncher/releases/download/OtherGames/SkyVessels2022.zip",
			"FileName":"SkyVessels2022.exe",
			"ThumbnailLink":"https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/Thumbnails/SkyVessels2022.jpg"
		}
	}
	var UpdaterData={
		"Link":"https://github.com/Elfiawesome/GameLauncher/releases/download/GameLauncher/GameLauncher.exe",
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
