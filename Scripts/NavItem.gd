extends ColorRect
export(StreamTexture) var Icon
export var label: String
export(NodePath) var Page
export(bool) var IsDefaultOpen
var IsSelected=false

onready var ColorBar=$HBoxContainer/Selected
onready var SpriteIcon=$Sprite
onready var TextLabel=$Label

func _ready():
	SpriteIcon.texture=Icon
	ColorBar.visible=false
	TextLabel.text=label
	color.a=0
	if IsDefaultOpen:
		IsSelected=true
		ColorBar.visible=true
		get_node(Page).visible=true

func Selected():
	IsSelected=true
	ColorBar.visible=true
	get_node(Page).visible=true
	for item in $"..".get_children():
		if item!=self:
			item.Deselected()

func Deselected():
	IsSelected=false
	ColorBar.visible=false
	get_node(Page).visible=false


func _on_NavItem_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.get_button_index()==1:
			if IsSelected:
				Deselected()
			else:
				Selected()

func _on_NavItem_mouse_entered():
	color.a=0.5

func _on_NavItem_mouse_exited():
	color.a=0
