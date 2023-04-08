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

func _process(delta):
	if following:
		OS.set_window_position(OS.window_position+get_global_mouse_position()-drag_pos)


func _on_MinButton_pressed():
	OS.set_window_minimized(true)

func _on_MaxButton_pressed():
	if !IsMaximised:
		lastPosBeforeMax=OS.get_window_position()
		OS.set_window_position(Vector2(0,0))
		OS.set_window_size(OS.get_screen_size())
	else:
		OS.set_window_size(Vector2(1024,600))
		OS.set_window_position(lastPosBeforeMax)
	IsMaximised=!IsMaximised

func _on_CloseButton_pressed():
	get_tree().quit()
