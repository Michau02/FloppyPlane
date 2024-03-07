extends CharacterBody2D

const max_velocity = 600
const flap_speed = -450
var flying = false
var falling = false
const starting_position = Vector2(100, 400) 

func _ready():
	reset()
	
func reset():
	flying = false
	position = starting_position
	set_rotation(0)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if flying or falling:
		velocity.y += gravity * delta
		if velocity.y > max_velocity:
			velocity.y = max_velocity
		if flying:
			set_rotation(deg_to_rad(velocity.y*0.05))	
		elif falling:
			set_rotation(PI/2)
		move_and_collide(velocity*delta)
			
func flap():
	$Flap.play()
	velocity.y = flap_speed
