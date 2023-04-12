extends Control
export(int) var VersionNumber = -1
var HttpRequest: HTTPRequest

func _ready():
	_initialize_file_links()
	print(OS.get_executable_path())
	

#Functions
func _initialize_file_links():#For uploading purposes only
	var HostData = {
		"EliteCardWars":{
			"Version":"1.0.4.1",
			"FileLink":"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip",#"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip",
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
		"Link":"https://github.com/Elfiawesome/GameLauncher/releases/download/GameLauncher/GameLauncher_v0.0.2.exe",
		"Version":"0.0.2",
		"FolderName":"GameLauncher",
		"ExeName":"GameLauncher.exe"
	}
	var file=File.new()
	file.open("res://GameFileLinks/HostData.json",File.WRITE)
	file.store_string(to_json(HostData))
	file.close()
	file=File.new()
	file.open("res://GameFileLinks/LauncherData.json",File.WRITE)
	file.store_string(to_json(UpdaterData))
	file.close()
