extends Control
var HostData: Dictionary
var IsHostDataReady=false
var HostDataLink: String = "https://raw.githubusercontent.com/Elfiawesome/GameLauncher/main/GameFileLinks/HostData.json"
var GameListOrder=[]
var HttpRequest: HTTPRequest

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
		print("Succesfully receive HostData")
		print(HostData)
		IsHostDataReady=true
		_on_HostData_ready()
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
		Game.rect_position=curpos+Vector2(offset,offset)
		add_child(Game)
		
		var boxsize=Game.rect_size
		curpos.x+=(boxsize.x+offset)
		if (curpos.x+boxsize.x) > (pagebox.x-offset):
			curpos.x=0
			curpos.y+=(boxsize.y+offset)

func _on_Page_Games_visibility_changed():
	if visible:
		pass
	else:
		pass
		

