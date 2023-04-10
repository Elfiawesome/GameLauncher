extends Control
var HostData: Dictionary
var IsHostDataReady=false
var HostDataLink: String = "https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/HostData.json"
var GameList=[]
var HttpRequest: HTTPRequest

func _ready():
	_get_HostData()
	_initialize_file_links()

func _get_HostData():
	HttpRequest=HTTPRequest.new()
	add_child(HttpRequest)
	HttpRequest.connect("request_completed",self,"_receive_HostData")
	var error=HttpRequest.request(HostDataLink)
	if error!=OK:
		print("Error Requesting Server Host Data: "+error)
func _receive_HostData(result, _response_code, _headers, body):
	if result==0:#If successful
		remove_child(HttpRequest)
		var StringResult=body.get_string_from_utf8()
		HostData=JSON.parse(StringResult).result
		print("Succesfully receive HostData")
		IsHostDataReady=true
		_on_HostData_ready()
func _on_HostData_ready():	
	var GameButton=preload("res://Scenes/GameButton.tscn")
	var curx=0
	var cury=0
	for i in 4:
		var curGame="EliteCardWars"
		if i!=3:
			curGame+=str(i)
		
		var Game=GameButton.instance()
		if HostData.has(curGame):
			Game.GameName=curGame
			Game.HostData=HostData[curGame]
		Game.rect_position=Vector2(curx,cury)
		add_child(Game)
		curx+=200

func _on_Page_Games_visibility_changed():
	if visible:
		pass
	else:
		pass
		

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
	var file=File.new()
	file.open("res://GameFileLinks/HostData.json",File.WRITE)
	file.store_string(to_json(HostData))
	file.close()
