extends ProgressBar

func _ready() -> void:
	max_value = 100.0  # Same as MAX_STAMINA in player

func _process(delta: float) -> void:
	if Global.player != null:
		value = Global.player.stamina
