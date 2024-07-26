class_name ProgressBar3D extends Node3D

@onready var mesh = $MeshInstance3D
@onready var progress_scale = $MeshInstance3D/Scale
var is_running = false
var duration: float
var timer: float
# Can call a function to start the progress bar, and register a callback signal for when its done
func start_timer(time: float):
	duration = time
	timer = 0
	progress_scale.scale.x = 0
	mesh.show()
	is_running = true

func _ready():
	mesh.hide()

func _process(delta):
	if is_running:
		timer += delta
		if timer >= duration:
			is_running = false
			mesh.hide()
			Signals.progress_bar_complete.emit(self)
		var progress = timer / duration
		progress_scale.scale.x = progress
	
