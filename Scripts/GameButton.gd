extends Control
export var GameName:String
#Generic Vars
var HostData: Dictionary
onready var ThumbnailTexture=$TextureRect
onready var MainButton=$Button
onready var MainButtonText=$Button/Label
onready var MainButtonProgressBar=$Button/ProgressBar
onready var Animator=$AnimationPlayer
onready var Trash=$Trash
onready var TrashHighlight=$Trash/TrashHighlight
var IsButtonHighlight=false
enum ButtonState{DownloadGame,DownloadingGame,UpdateGame,PlayGame}
var state=ButtonState.DownloadGame
#Https Vars
var HttpRequest_Thumbnail: HTTPRequest
var HttpRequest_Game: HTTPRequest
var FileName=""
var IsDownloadingGame=false
onready var DownloadManager=get_parent().DownloadManager
var DownloadID=-1
#File Location Vars
var GameDir="user://GameFolders/"

func _ready():
	Animator.play_backwards("RESET")
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
	
	if DownloadID==-1:
		_check_game_state()

func _check_game_state():
	Trash.visible=false
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
		Trash.visible=true

#Get Thumbnail
func _get_Thumbnail(link:String, FileLocation:String):
	HttpRequest_Thumbnail = HTTPRequest.new()
	add_child(HttpRequest_Thumbnail)
	var DownloadDir=FileLocation+link.get_extension()
	HttpRequest_Thumbnail.connect("request_completed",self,"_receive_Thumbnail",[DownloadDir])
	HttpRequest_Thumbnail.set_download_file(DownloadDir)
	var error=HttpRequest_Thumbnail.request(link)
	if error!=OK:
		print("Error Request Thumbnail: "+str(error))
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
					DownloadID=DownloadManager._get_game_zip(HostData["FileLink"],GameDir,HostData["Version"],false)
					state=ButtonState.DownloadingGame
				ButtonState.UpdateGame:
					DownloadID=DownloadManager._get_game_zip(HostData["FileLink"],GameDir,HostData["Version"],true)
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
#Delete Press
func _on_TrashCollision_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.get_button_index()==1:
			if GameDir!="user://GameFolders/":
				DownloadManager._remove_all_gamefiles(GameDir)
				_check_game_state()
func _on_TrashCollision_mouse_entered():
	TrashHighlight.visible=true
func _on_TrashCollision_mouse_exited():
	TrashHighlight.visible=false

func _process(_delta):
	if DownloadID!=-1:
		if DownloadManager.HttpsRequestDictionaryProgress.has(DownloadID):
			var progress=DownloadManager.HttpsRequestDictionaryProgress[DownloadID]
			var wid=rect_size.x
			MainButtonProgressBar.rect_size=Vector2(wid*progress,MainButtonProgressBar.rect_size.y)
			MainButtonText.text="Downloading Game "+str(int(progress*100))+"%"
		if DownloadManager.CompletedRequests.has(DownloadID):
			DownloadManager._IsSatisfiedWithDownload(DownloadID)
			DownloadID=-1
			_check_game_state()

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
func readCurrentVersion(GameLocation):
	var curversion="0.0.0"
	if file_exists(GameLocation+"/Version.txt"):
		var file = File.new()
		file.open(GameLocation+"/Version.txt", File.READ)
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

