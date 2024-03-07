extends Node2D

@export var skyscrapers_scene : PackedScene

var game_running = false
var game_over = false

var scroll_ground
var scroll_background
var score
const scroll_background_speed = 1
const scroll_ground_speed = 4
var screen_size
var ground_height
var skyscrapers : Array
const skyscraper_delay = 100
const skyscraper_range = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	newGame()
	
func newGame():
	game_over = false
	game_running = false
	$ScoreLabel.text = "SCORE: 0" 
	$GameOver/RestartButton.hide()
	if $Plane/explosion.is_playing:
		$Plane/explosion.stop()
	$Explosion.hide()
	$Plane.show()
	score = 0
	scroll_ground = 0
	scroll_background = 0
	$Background.position.x = 0
	get_tree().call_group("skyscrapers", "queue_free")
	skyscrapers.clear()
	generate_skyscrapers()	
	$Plane.reset()
	
func _input(event):
	if !game_over:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if !game_running:
					start_game()
				else:
					if $Plane.flying:
						$Plane.flap()
						check_top()

func start_game():
	game_running = true
	$Plane.flying = true
	$Plane.flap()
	$SkycraperTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll_ground += scroll_ground_speed
		scroll_background += scroll_background_speed
		if scroll_ground >= screen_size.x:
			scroll_ground = 0
		if scroll_background >= 4.5*screen_size.x:
			scroll_background = 0
			
		$Ground.position.x = -scroll_ground	
		$Background.position.x = -scroll_background
		for skyscaper in skyscrapers:
			skyscaper.position.x -= scroll_ground_speed

func _on_skycraper_timer_timeout():
	generate_skyscrapers()
	
func generate_skyscrapers():
	var skyscraper = skyscrapers_scene.instantiate()
	skyscraper.position.x = screen_size.x + skyscraper_delay
	skyscraper.position.y = (screen_size.y - ground_height) / 2 + randi_range(-skyscraper_range, skyscraper_range)
	skyscraper.hit.connect(plane_hit)
	skyscraper.scored.connect(scored)
	add_child(skyscraper)
	skyscrapers.append(skyscraper)
	
func check_top():
	if $Plane.position.y <= 0:
		$Plane.falling = true	
		stop_game()
		
func stop_game():
	$GameOver/RestartButton.show()
	$SkycraperTimer.stop()
	$Plane.flying = false
	game_running = false
	game_over = true		

func plane_hit():
	$Plane.falling = false
	$Explosion.position = $Plane.position
	$Explosion.show()
	$Plane/explosion.play()
	get_node("Explosion").play("explosion")
	$Plane.hide()
	stop_game()
	await $Explosion.anim_fin
	
func scored():
	score += 1
	$Scored.play()
	$ScoreLabel.text = "SCORE: " + str(score)

func _on_ground_hit():
	$Explosion.position = $Plane.position
	$Plane.falling = false
	$Explosion.show()
	get_node("Explosion").play("explosion")
	$Plane/explosion.play()
	$Plane.hide()
	stop_game()
	await $Explosion.anim_fin

func _on_game_over_restart():
	newGame()

func _on_explosion_anim_fin():
	$Explosion.hide()
