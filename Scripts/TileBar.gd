extends Control

var following=false
var IsMaximised=false
var lastPosBeforeMax=Vector2()
var drag_pos=Vector2()

func _on_TileBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index()==1:
			following=!following
			drag_pos=get_local_mouse_position()

func _process(_delta):
	if following:
		OS.set_window_position(OS.window_position+get_local_mouse_position()-drag_pos)
