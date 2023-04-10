extends ColorRect
enum TYPES{
	MINIMIZE,
	MAXIMISE,
	CLOSE
}
export(TYPES) var Type = TYPES.CLOSE
export(StreamTexture) var Icon = preload("res://Visuals/Icons/CloseIcon.svg")

func _ready():
	$Sprite.texture=Icon

func _on_MinButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.get_button_index()==1:
			match Type:
				TYPES.CLOSE:
					get_tree().quit()
				TYPES.MAXIMISE:
					OS.set_window_maximized(!OS.is_window_maximized())
				TYPES.MINIMIZE:
					OS.set_window_minimized(true)

func _on_MinButton_mouse_entered():
	if Type==TYPES.CLOSE:
		color="b70000"
	else:
		color="191d32"

func _on_MinButton_mouse_exited():
	color="282f44"
