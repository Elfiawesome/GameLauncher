extends Control
var HostData: Dictionary
var IsHostDataReady=false
var HostDataLink: String = "https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/HostData.json"
var HttpRequest: HTTPRequest
var TimerRequest=0
onready var DownloadManager = $"../../../../DownloadManager"
var DownloadIDDictionary={}
var GameListOrder=[]

func _ready():
	_get_HostData()

func _get_HostData():
	HttpRequest=HTTPRequest.new()
	add_child(HttpRequest)
	HttpRequest.connect("request_completed",self,"_receive_HostData")
	var error=HttpRequest.request(HostDataLink)
	if error!=OK:
		print("Error Requesting Server Host Data: "+str(error))
func _receive_HostData(result, _response_code, _headers, body):
	if result==0:#If successful
		remove_child(HttpRequest)
		var StringResult=body.get_string_from_utf8()
		HostData=JSON.parse(StringResult).result
		if !IsHostDataReady:
			print("Succesfully receive HostData")
			_on_HostData_ready()
			IsHostDataReady=true
		else:
			print("Updated HostData")
			_on_HostData_update()
func _on_HostData_ready():
	var GameButton=preload("res://Scenes/GameButton.tscn")
	var curpos=Vector2(0,0)
	var pagebox=self.rect_size
	var offset=30
	for m in HostData:
		var curGame=m
		var Game=GameButton.instance()
		if HostData.has(curGame):
			Game.GameName=curGame
			Game.HostData=HostData[curGame]
		if DownloadIDDictionary.has(curGame):
			Game.DownloadID=DownloadIDDictionary[curGame]
			Game.state = Game.ButtonState.DownloadingGame
		Game.rect_position=curpos+Vector2(offset,offset)
		add_child(Game)
		GameListOrder.push_back(Game)
		var boxsize=Game.rect_size
		curpos.x+=(boxsize.x+offset)
		if (curpos.x+boxsize.x) > (pagebox.x-offset):
			curpos.x=0
			curpos.y+=(boxsize.y+offset)
	DownloadIDDictionary.clear()

func _on_HostData_update():
	for m in HostData:
		if game_exists_in(m,GameListOrder):
			print("NewGameDetected")
func game_exists_in(NewGameName:String,ObjGameArray:Array):
	var _r=true
	for game in ObjGameArray:
		if game.GameName == NewGameName:
			_r=false
			break
	return _r

func _process(_delta):
	TimerRequest+=1
	if TimerRequest>200:
		TimerRequest=0
		_get_HostData()

func _refresh_games():
	for game in GameListOrder:
		DownloadIDDictionary[game.GameName]=game.DownloadID
		remove_child(game)
		game.queue_free()
	GameListOrder.clear()
	_on_HostData_ready()

func _on_Page_Games_visibility_changed():
	if visible:
		_refresh_games()
	else:
		pass
		

