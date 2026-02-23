extends ProgressBar

@export var decrease_speed = 5.0 # The speed at which you will lose health
var is_losing_health := false

func start_losing_health():
	is_losing_health = true
	set_process(true)

func _process(delta):
	if is_losing_health:
		value -= decrease_speed * delta
		
		if value <= 0:
			value = 0
			set_process(false)
