extends Control
export var GameName:String
#Generic Vars
var HostData: Dictionary
onready var ThumbnailTexture=$TextureRect
onready var MainButton=$Button
onready var MainButtonText=$Button/Label
onready var MainButtonProgressBar=$Button/ProgressBar
onready var Animator=$AnimationPlayer
var IsButtonHighlight=false
enum ButtonState{DownloadGame,DownloadingGame,UpdateGame,PlayGame}
var state=ButtonState.DownloadGame
#Https Vars
var HttpRequest_Thumbnail: HTTPRequest
var HttpRequest_Game: HTTPRequest
var FileName=""
var IsDownloadingGame=false
#File Location Vars
var GameDir="user://GameFolders/"

func _ready():
	Animator.play_backwards("RESET")
	print(HostData)
	GameDir="user://GameFolders/"+GameName
	#Create Main Game Directory
	if !dir_exists("user://GameFolders/"):
		file_create_folder("user://","GameFolders")
	#Create Game Directory
	if !dir_exists(GameDir):
		file_create_folder("user://GameFolders/",GameName)
	#Create Game Directory
	if !dir_exists(GameDir):
		file_create_folder("user://GameFolders/",GameName)
	#Get thumbnail
	if HostData.has("ThumbnailLink"):
		_get_Thumbnail(HostData["ThumbnailLink"],GameDir+"/GameThumbnail.")
	_check_game_state()


func _check_game_state():
	#Check if game exists
	if !HostData.has("FileName"):#get_game
		MainButtonText.text="Missing FileName in HostData"
		return
	else:
		FileName=HostData["FileName"]
		#Check if game exists
		if !file_exists(GameDir+"/"+FileName):
			state=ButtonState.DownloadGame
			MainButtonText.text="Download Game"
			return
		else:
			if IsNeedUpdate(readCurrentVersion(GameDir),HostData["Version"]):
				state=ButtonState.UpdateGame
				MainButtonText.text="Update Game"
				return
		state=ButtonState.PlayGame
		MainButtonText.text="Play Game"

#Get Thumbnail
func _get_Thumbnail(link:String, FileLocation:String):
	HttpRequest_Thumbnail = HTTPRequest.new()
	add_child(HttpRequest_Thumbnail)
	var DownloadDir=FileLocation+link.get_extension()
	HttpRequest_Thumbnail.connect("request_completed",self,"_receive_Thumbnail",[DownloadDir])
	HttpRequest_Thumbnail.set_download_file(DownloadDir)
	var error=HttpRequest_Thumbnail.request(link)
	if error!=OK:
		print("Error Request Thumbnail: "+error)
func _receive_Thumbnail(result, _response_code, _headers, _body, FileLocation):
	remove_child(HttpRequest_Thumbnail)
	if result==0:
		var image=Image.new()
		image.load(FileLocation)
		var t=ImageTexture.new()
		t.create_from_image(image,0)
		ThumbnailTexture.texture=t

#Button press
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.get_button_index()==1:
			if !HostData.has("FileLink"):
				MainButtonText.text="Missing Files from HostData Server"
				return
			if !HostData.has("Version"):
				HostData["Version"]="0.0.0"
			match(state):
				ButtonState.DownloadGame:
					_get_Game(HostData["FileLink"],GameDir,HostData["Version"])
					state=ButtonState.DownloadingGame
				ButtonState.UpdateGame:
					_remove_all_gamefiles()
					_get_Game(HostData["FileLink"],GameDir,HostData["Version"])
					state=ButtonState.DownloadingGame
				ButtonState.PlayGame:
					OS.shell_open(OS.get_user_data_dir()+"/GameFolders/"+GameName+"/"+HostData["FileName"])
func _on_Button_mouse_entered():
	if !IsButtonHighlight:
		Animator.play("MouseHoverOverButton")
		IsButtonHighlight=true
func _on_Button_mouse_exited():
	if IsButtonHighlight:
		Animator.play_backwards("MouseHoverOverButton")
		IsButtonHighlight=false



#get Game
func _get_Game(link:String, FileLocation:String, Version:String):
	HttpRequest_Game = HTTPRequest.new()
	add_child(HttpRequest_Game)
	var DownloadDir=FileLocation+"/"+link.get_file()
	HttpRequest_Game.connect("request_completed",self,"_receive_Game",[DownloadDir,Version])
	HttpRequest_Game.set_download_file(DownloadDir)
	var error=HttpRequest_Game.request(link)
	if error!=OK:
		print("Error Request Game Files: "+error)
	IsDownloadingGame=true
func _receive_Game(result, _response_code, _headers, _body, FileLocation, Version):
	remove_child(HttpRequest_Game)
	IsDownloadingGame=false
	if result==0:#If succesfull
		#Unzip Game
		unzip(FileLocation,GameDir+"/")
		#Create Version number
		var file = File.new()
		file.open(GameDir+"/Version.txt", File.WRITE)
		file.store_string(Version)
		file.close()
	_check_game_state()
func _process(_delta):
	if IsDownloadingGame:
		var bodySize: int = HttpRequest_Game.get_body_size()
		var downloadedBytes: int = HttpRequest_Game.get_downloaded_bytes()
		MainButtonText.text="Downloading Game "+str(abs(round(float(downloadedBytes)/bodySize*100)))+"%"
		var wid=rect_size.x
		MainButtonProgressBar.rect_size=Vector2(wid*downloadedBytes/bodySize,MainButtonProgressBar.rect_size.y)
func _remove_all_gamefiles():
	#Remove all files
	var FileLocation=GameDir
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

#functions
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
func readCurrentVersion(GameLocation):
	var curversion="0.0.0"
	if file_exists(GameLocation+"/version.txt"):
		var file = File.new()
		file.open(GameLocation+"/version.txt", File.READ)
		curversion=file.get_as_text()
		file.close()
	return curversion
func IsNeedUpdate(VersionCurrent:String,VersionReference:String):
	if get_version_value(VersionReference)>get_version_value(VersionCurrent):
		return true
	else:
		return false
func get_version_value(version:String):
	var valarray=version.split(".")
	var totalval=0
	var mul=100
	for i in valarray:
		totalval+=int(i)*mul
		mul=mul/10
	return totalval
