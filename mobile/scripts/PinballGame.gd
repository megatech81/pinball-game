extends Node2D

# Game constants
const SCREEN_WIDTH = 720
const SCREEN_HEIGHT = 1280
const BALL_RADIUS = 12
const GRAVITY = 0.8
const BOUNCE_DAMPING = 0.8

# Game objects
var ball: Ball
var left_flipper: Flipper
var right_flipper: Flipper
var bumpers: Array[Bumper] = []

# Game state
var score: int = 0
var game_over: bool = false

# UI elements
var score_label: Label
var game_over_label: Label
var controls_label: Label

# Touch input areas
var left_touch_area: TouchScreenButton
var right_touch_area: TouchScreenButton
var launch_touch_area: TouchScreenButton

class Ball:
	var position: Vector2
	var velocity: Vector2
	var radius: float
	var body: RigidBody2D
	
	func _init(pos: Vector2, r: float = BALL_RADIUS):
		position = pos
		velocity = Vector2.ZERO
		radius = r
		
	func update_physics(delta: float):
		# Apply gravity
		velocity.y += GRAVITY * delta * 60  # Adjust for framerate independence
		
		# Update position
		position += velocity * delta * 60
		
		# Bounce off walls
		if position.x - radius <= 0 or position.x + radius >= SCREEN_WIDTH:
			velocity.x = -velocity.x * BOUNCE_DAMPING
			position.x = clamp(position.x, radius, SCREEN_WIDTH - radius)
			
		# Bounce off top wall
		if position.y - radius <= 0:
			velocity.y = -velocity.y * BOUNCE_DAMPING
			position.y = radius

class Flipper:
	var position: Vector2
	var is_left: bool
	var rest_angle: float
	var active_angle: float
	var current_angle: float
	var length: float
	var activated: bool = false
	
	func _init(pos: Vector2, left: bool = true):
		position = pos
		is_left = left
		rest_angle = -30.0 if left else 30.0
		active_angle = -60.0 if left else 60.0
		current_angle = rest_angle
		length = 120.0
		
	func update(pressed: bool, delta: float):
		activated = pressed
		var target_angle = active_angle if pressed else rest_angle
		current_angle = lerp(current_angle, target_angle, 0.3)
	
	func get_end_position() -> Vector2:
		var angle_rad = deg_to_rad(current_angle)
		return position + Vector2(cos(angle_rad), sin(angle_rad)) * length

class Bumper:
	var position: Vector2
	var radius: float
	var hit_animation: int = 0
	var points: int = 100
	
	func _init(pos: Vector2, r: float = 45.0):
		position = pos
		radius = r
		
	func update():
		if hit_animation > 0:
			hit_animation -= 1
	
	func check_collision(ball_obj: Ball) -> bool:
		var distance = position.distance_to(ball_obj.position)
		if distance <= ball_obj.radius + radius:
			# Calculate collision normal
			var normal = (ball_obj.position - position).normalized()
			
			# Reflect velocity
			var dot_product = ball_obj.velocity.dot(normal)
			ball_obj.velocity -= 2 * dot_product * normal
			
			# Add extra force
			ball_obj.velocity += normal * 5.0
			
			# Move ball outside bumper
			var overlap = ball_obj.radius + radius - distance
			ball_obj.position += normal * overlap
			
			hit_animation = 10
			return true
		return false

func _ready():
	setup_ui()
	setup_game_objects()
	setup_touch_controls()

func setup_ui():
	# Score label
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.position = Vector2(20, 20)
	score_label.add_theme_font_size_override("font_size", 32)
	add_child(score_label)
	
	# Game over label
	game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nTap to Restart"
	game_over_label.position = Vector2(SCREEN_WIDTH/2 - 100, SCREEN_HEIGHT/2 - 50)
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.modulate = Color.RED
	game_over_label.visible = false
	add_child(game_over_label)
	
	# Controls label
	controls_label = Label.new()
	controls_label.text = "Tap sides for flippers • Tap top to launch"
	controls_label.position = Vector2(20, SCREEN_HEIGHT - 60)
	controls_label.add_theme_font_size_override("font_size", 24)
	add_child(controls_label)

func setup_game_objects():
	# Initialize ball
	ball = Ball.new(Vector2(SCREEN_WIDTH / 2, 150))
	
	# Initialize flippers
	left_flipper = Flipper.new(Vector2(200, SCREEN_HEIGHT - 180), true)
	right_flipper = Flipper.new(Vector2(520, SCREEN_HEIGHT - 180), false)
	
	# Initialize bumpers
	bumpers.clear()
	bumpers.append(Bumper.new(Vector2(180, 400)))
	bumpers.append(Bumper.new(Vector2(360, 350)))
	bumpers.append(Bumper.new(Vector2(540, 400)))
	bumpers.append(Bumper.new(Vector2(270, 600)))
	bumpers.append(Bumper.new(Vector2(450, 600)))

func setup_touch_controls():
	# Left flipper touch area
	left_touch_area = TouchScreenButton.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)
	left_touch_area.shape = left_shape
	left_touch_area.position = Vector2(0, SCREEN_HEIGHT*2/3)
	add_child(left_touch_area)
	
	# Right flipper touch area
	right_touch_area = TouchScreenButton.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)
	right_touch_area.shape = right_shape
	right_touch_area.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT*2/3)
	add_child(right_touch_area)
	
	# Launch touch area
	launch_touch_area = TouchScreenButton.new()
	var launch_shape = RectangleShape2D.new()
	launch_shape.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT/3)
	launch_touch_area.shape = launch_shape
	launch_touch_area.position = Vector2(0, 0)
	add_child(launch_touch_area)

func _process(delta):
	handle_input()
	if not game_over:
		update_game(delta)
	queue_redraw()

func handle_input():
	# Handle touch input
	var left_pressed = left_touch_area.is_pressed() or Input.is_action_pressed("left_flipper")
	var right_pressed = right_touch_area.is_pressed() or Input.is_action_pressed("right_flipper")
	var launch_pressed = launch_touch_area.is_pressed() or Input.is_action_just_pressed("launch")
	
	# Update flippers
	left_flipper.update(left_pressed, get_process_delta_time())
	right_flipper.update(right_pressed, get_process_delta_time())
	
	# Launch ball
	if launch_pressed and not game_over and ball.position.y < 200:
		ball.velocity = Vector2(randf_range(-3, 3), 12)
	
	# Restart game
	if Input.is_action_just_pressed("restart") and game_over:
		restart_game()
	
	# Touch restart for mobile
	if game_over and (launch_touch_area.is_pressed() or left_touch_area.is_pressed() or right_touch_area.is_pressed()):
		restart_game()

func update_game(delta):
	# Update ball physics
	ball.update_physics(delta)
	
	# Check flipper collisions
	check_flipper_collision(left_flipper)
	check_flipper_collision(right_flipper)
	
	# Check bumper collisions
	for bumper in bumpers:
		bumper.update()
		if bumper.check_collision(ball):
			score += bumper.points
			score_label.text = "Score: " + str(score)
	
	# Check game over
	if ball.position.y > SCREEN_HEIGHT:
		game_over = true
		game_over_label.visible = true
		controls_label.visible = false

func check_flipper_collision(flipper: Flipper):
	var end_pos = flipper.get_end_position()
	var distance_to_line = point_distance_to_line(ball.position, flipper.position, end_pos)
	
	if distance_to_line <= ball.radius + 8:  # 8 is flipper width/2
		if flipper.activated:
			# Strong upward force when flipper is activated
			var angle_rad = deg_to_rad(flipper.current_angle - 90)
			var force = Vector2(cos(angle_rad), sin(angle_rad)) * 18
			ball.velocity += force
		else:
			# Gentle bounce
			ball.velocity.y *= -0.8

func point_distance_to_line(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()
	if line_len == 0:
		return point_vec.length()
	
	var dot = point_vec.dot(line_vec) / line_len
	dot = clamp(dot, 0, line_len)
	var closest = line_start + line_vec.normalized() * dot
	return point.distance_to(closest)

func restart_game():
	ball = Ball.new(Vector2(SCREEN_WIDTH / 2, 150))
	score = 0
	game_over = false
	score_label.text = "Score: 0"
	game_over_label.visible = false
	controls_label.visible = true
	
	# Reset bumpers
	for bumper in bumpers:
		bumper.hit_animation = 0

func _draw():
	if ball:
		draw_ball()
	if left_flipper:
		draw_flipper(left_flipper)
	if right_flipper:
		draw_flipper(right_flipper)
	for bumper in bumpers:
		draw_bumper(bumper)
	draw_walls()

func draw_ball():
	draw_circle(ball.position, ball.radius, Color.WHITE)
	draw_arc(ball.position, ball.radius, 0, TAU, 32, Color.GRAY, 3)

func draw_flipper(flipper: Flipper):
	var end_pos = flipper.get_end_position()
	var color = Color.YELLOW if flipper.activated else Color.LIGHT_GRAY
	draw_line(flipper.position, end_pos, color, 12)
	draw_circle(flipper.position, 8, color)

func draw_bumper(bumper: Bumper):
	var color = Color.RED if bumper.hit_animation > 0 else Color.BLUE
	draw_circle(bumper.position, bumper.radius, color)
	draw_arc(bumper.position, bumper.radius, 0, TAU, 32, Color.WHITE, 4)

func draw_walls():
	# Top wall
	draw_rect(Rect2(0, 0, SCREEN_WIDTH, 15), Color.WHITE)
	# Left wall
	draw_rect(Rect2(0, 0, 15, SCREEN_HEIGHT), Color.WHITE)
	# Right wall
	draw_rect(Rect2(SCREEN_WIDTH - 15, 0, 15, SCREEN_HEIGHT), Color.WHITE)