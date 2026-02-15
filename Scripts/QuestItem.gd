###QuestItem.gd
extends Area3D

@onready var sprite_3d = $Sprite3D

# Vars
@export var item_id: String = ""
@export var item_quantity: int = 1
@export var item_icon: Texture3D

func  _ready() -> void:
	if not Engine.is_editor_hint():
		sprite_3d.texture = item_icon

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		sprite_3d.texture = item_icon
		
