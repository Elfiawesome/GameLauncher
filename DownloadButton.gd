extends Button

var NewHostData: Dictionary
var http_request: HTTPRequest
var GameName="EliteCardWars"
var exe_file: String
var state=ButtonState.DownloadGame

enum ButtonState{
	DownloadGame,
	DownloadingGame,
	UpdateGame,
	PlayGame
}
var _ProgressBar
var _Thumnail
var thread = Thread.new()

func _ready():
	_initialize_file_links()
	self.disabled=true
	_get_server_HostData()
	_ProgressBar=$"../ProgressBar"
	_Thumnail=$"../TextureRect"

func _on_game_ready():
	self.disabled=false

func _on_Button_pressed(): 
	match(state):
		ButtonState.DownloadGame:
			var FileLocation="user://GameFolders/"+GameName
			#Disable multiple downloads
			self.disabled=true
			#Download Game Zip
			var Link=NewHostData[GameName]["FileLink"]
			var Version=NewHostData[GameName]["Version"]
			#_get_download_file(Link,FileLocation,Version)
			thread.start(self,"_get_download_file",[Link,FileLocation,Version])
		ButtonState.UpdateGame:
			#Remove all files
			var FileLocation="user://GameFolders/"+GameName
			var dir=Directory.new()
			dir.open(FileLocation)
			dir.list_dir_begin()
			while true:
				var f=dir.get_next()
				if f == "":
					break;
				elif not f.begins_with("."):
					dir.remove(FileLocation+"/"+f)
			dir.list_dir_end()
			#Disable multiple downloads
			self.disabled=true
			#Download Game Zip
			var Link=NewHostData[GameName]["FileLink"]
			var Version=NewHostData[GameName]["Version"]
			_get_download_file([Link,FileLocation,Version])
		ButtonState.PlayGame:
			OS.shell_open(OS.get_user_data_dir()+"/GameFolders/"+GameName+"/"+exe_file)

func _on_HostData_ready():
	#Check if host data has the game
	if !NewHostData.has(GameName):
		self.text="HostData Missing Game Link..."
		return
	if NewHostData[GameName].has("ThumbnailLink"):
		_get_game_thumbnail(NewHostData[GameName]["ThumbnailLink"])
	#Set exe file
	exe_file=NewHostData[GameName]["FileName"]
	#Check main GameFolder folder exists
	if !dir_exists("user://GameFolders"):
		file_create_folder("user://","GameFolders")
	
	#Check if individual game folders  exists
	var FileLocation="user://GameFolders/"+GameName
	
	#Create individual game folders
	if !dir_exists(FileLocation):
		file_create_folder("user://GameFolders",GameName)
	
	#Check if game exists
	self.text="Play Game"
	state=ButtonState.PlayGame
	if file_exists(FileLocation+"/"+exe_file):
		var NeedUpdate=CheckForAnyUpdates()
		if NeedUpdate:
			state=ButtonState.UpdateGame
			self.text="Update Available"
	else:
		state=ButtonState.DownloadGame
		self.text="Download Game"
	#Allow clicking button
	self.disabled=false


func _on_GameDownloaded_ready(GameZip: String, version:String):
	#Unzip game
	self.text="Unzipping"
	unzip("user://GameFolders/"+GameName+"/"+GameZip,"user://GameFolders/"+GameName+"/")
	
	#Write Version Number
	var file = File.new()
	file.open("user://GameFolders/"+GameName+"/Version.txt", File.WRITE)
	file.store_string(version)
	file.close()
	#Update the game state
	_on_HostData_ready()

func CheckForAnyUpdates():
	var newest_version=NewHostData[GameName]["Version"]
	#Read Current version
	var file = File.new()
	var current_version="0.0.0"
	if file_exists("user://GameFolders/"+GameName+"/Version.txt"):
		file.open("user://GameFolders/"+GameName+"/Version.txt", File.READ)
		current_version=file.get_as_text()
		file.close()
	
	var newest_version_value=Get_version_value(newest_version)
	var current_version_value=Get_version_value(current_version)
	
	if newest_version_value>current_version_value:
		return true
	else:
		return false

func Get_version_value(version: String):
	var total=0
	var valarray=version.split(".")
	
	var c=0
	for i in valarray:
		var mul=0
		match c:
			0:
				mul=100
			1:
				mul=10
			2:
				mul=1
		total+=int(i)*mul
		c+=1
	return total


var bodySize: int
var downloadedBytes: int
var yes=false
#var http_request: HTTPRequest
func _get_download_file(args):
	var link=args[0]
	var path=args[1]
	var version=args[2]
	yes=true
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	self.text="Downloading "+str(link.get_file())
	http_request.connect("request_completed",self,"_receive_download_file",[link.get_file(),version])
	http_request.set_download_file(path+"/"+link.get_file())
	var error=http_request.request(link)
	if error!=OK:
		self.text="Error: "+str(error)

func _process(delta):
	if yes:
		bodySize = http_request.get_body_size()
		downloadedBytes = http_request.get_downloaded_bytes()
		print(int(downloadedBytes*100/bodySize))
		var wid=rect_size.x
		_ProgressBar.rect_size=Vector2(wid*downloadedBytes/bodySize,_ProgressBar.rect_size.y)

func _receive_download_file(result, response_code, headers, body, GameZip, version):
	remove_child(http_request)
	_on_GameDownloaded_ready(GameZip,version)

#Request for game image
func _get_game_thumbnail(link:String):
	var http_request_Thumbnail = HTTPRequest.new()
	add_child(http_request_Thumbnail)
	http_request_Thumbnail.connect("request_completed", self, "_receive_game_thumbnail")
	http_request_Thumbnail.request(link)
	http_request_Thumbnail.set_download_file("user://"+GameName+"Thumnail")
	print(link)

func _receive_game_thumbnail():
	pass

#Request for server details
func _get_server_HostData():
	var http_request_HostData = HTTPRequest.new()
	add_child(http_request_HostData)
	http_request_HostData.connect("request_completed", self, "_receive_server_HostData")
	http_request_HostData.request("https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/HostData.json")
#Receive  for server details
func _receive_server_HostData(result, response_code, headers, body):
	var StringResult=body.get_string_from_utf8()
	NewHostData = JSON.parse(StringResult).result
	_on_HostData_ready()
	print("Succesfully received Server HostData")

func file_exists(path: String):
	var dir=Directory.new()
	return dir.file_exists(path)

func dir_exists(path: String):
	var dir=Directory.new()
	return dir.dir_exists(path)

func file_create_folder(path:String, FolderName:String):
	var dir=Directory.new()
	dir.open(path)
	dir.make_dir(FolderName)

func unzip(sourceFile,destination):
	var zip_file = sourceFile
	var storage_path = destination
	
	var gdunzip = load('res://addons/gdunzip.gd').new()
	var loaded = gdunzip.load(zip_file)

	if !loaded:
		print('- Failed loading zip file')
		return false
	ProjectSettings.load_resource_pack(zip_file)
	
	var i = 0
	for f in gdunzip.files:
		var readFile = File.new()
		if readFile.file_exists("res://"+f):
			readFile.open(("res://"+f), File.READ)
			var content = readFile.get_buffer(readFile.get_len())
			readFile.close()
			
			var base_dir = storage_path + f.get_base_dir()
			
			var dir = Directory.new()
			dir.make_dir(base_dir)
			
			var writeFile = File.new()
			writeFile.open(storage_path + f, File.WRITE)
			writeFile.store_buffer(content)
			writeFile.close()

func _initialize_file_links():#For uploading purposes only
	var HostData = {
		"EliteCardWars":{
			"Version":"1.0.0",
			"FileLink":"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip",
			"FileName":"EliteCardWars.exe",
			"ThumbnailLink":"https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/Thumbnails/EliteCardWars.JPG"
		},
		"EliteCardWarsBeta":{
			"Version":"0.0.1",
			"FileLink":"https://github.com/Elfiawesome/EliteCardWars/releases/download/TestingBuilds/EliteCardWarsTestingBuild_v1.0.4.4.zip",
			"FileName":"EliteCardWars.exe"
		},
		"OtherThing":{
			"Version":"0.0.1",
			"FileLink":""
		}
	}
	var file=File.new()
	file.open("res://GameFileLinks/HostData.json",File.WRITE)
	file.store_string(to_json(HostData))
	file.close()
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


