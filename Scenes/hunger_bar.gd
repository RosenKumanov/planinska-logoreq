extends ProgressBar

@export var decrease_speed = 1.0
@onready var health_bar = $"../HealthBar"

func _process(delta):
	value -= decrease_speed * delta
	
	if value <= 0:
		value = 0
		
		# Start damaging health
		health_bar.start_losing_health()
		
		set_process(false)
