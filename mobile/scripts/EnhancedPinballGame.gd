extends Node2D

# Enhanced graphics pinball game with textures and particle effects
const SCREEN_WIDTH = 720
const SCREEN_HEIGHT = 1280

# Preload textures
var ball_texture: Texture2D
var flipper_texture: Texture2D
var bumper_texture: Texture2D
var background_texture: Texture2D

# Particle systems
var ball_particles: GPUParticles2D
var bumper_particles: Array[GPUParticles2D] = []

# Enhanced Ball class with sprite
class EnhancedBall:
	var sprite: Sprite2D
	var position: Vector2
	var velocity: Vector2
	var radius: float = 12
	var trail_particles: GPUParticles2D
	
	func _init(pos: Vector2, parent_node: Node2D):
		position = pos
		velocity = Vector2.ZERO
		
		# Create sprite
		sprite = Sprite2D.new()
		sprite.position = position
		sprite.scale = Vector2(0.3, 0.3)  # Scale down the ball
		parent_node.add_child(sprite)
		
		# Create ball trail particles
		trail_particles = GPUParticles2D.new()
		setup_trail_particles()
		parent_node.add_child(trail_particles)
	
	func setup_trail_particles():
		var material = ParticleProcessMaterial.new()
		material.direction = Vector3(0, 1, 0)
		material.initial_velocity_min = 20.0
		material.initial_velocity_max = 50.0
		material.angular_velocity_min = -45.0
		material.angular_velocity_max = 45.0
		material.orbit_velocity_min = 0.0
		material.orbit_velocity_max = 0.0
		material.linear_accel_min = 0.0
		material.linear_accel_max = 0.0
		material.radial_accel_min = 0.0
		material.radial_accel_max = 0.0
		material.tangential_accel_min = 0.0
		material.tangential_accel_max = 0.0
		material.damping_min = 0.0
		material.damping_max = 0.0
		material.scale_min = 0.1
		material.scale_max = 0.3
		material.color = Color.WHITE
		
		trail_particles.process_material = material
		trail_particles.amount = 50
		trail_particles.lifetime = 1.0
		trail_particles.emitting = true
	
	func update_physics(delta: float):
		velocity.y += 0.8 * delta * 60
		position += velocity * delta * 60
		
		# Update sprite position
		sprite.position = position
		trail_particles.position = position
		
		# Bounce off walls
		if position.x - radius <= 15 or position.x + radius >= SCREEN_WIDTH - 15:
			velocity.x = -velocity.x * 0.8
			position.x = clamp(position.x, radius + 15, SCREEN_WIDTH - radius - 15)
			
		if position.y - radius <= 15:
			velocity.y = -velocity.y * 0.8
			position.y = radius + 15

# Enhanced Flipper with sprite and glow effect
class EnhancedFlipper:
	var sprite: Sprite2D
	var glow_sprite: Sprite2D
	var position: Vector2
	var is_left: bool
	var rest_angle: float
	var active_angle: float
	var current_angle: float
	var length: float = 120.0
	var activated: bool = false
	
	func _init(pos: Vector2, left: bool, parent_node: Node2D):
		position = pos
		is_left = left
		rest_angle = -30.0 if left else 30.0
		active_angle = -60.0 if left else 60.0
		current_angle = rest_angle
		
		# Create main sprite
		sprite = Sprite2D.new()
		sprite.position = position
		sprite.rotation = deg_to_rad(current_angle)
		sprite.scale = Vector2(1.5, 0.3)
		parent_node.add_child(sprite)
		
		# Create glow effect sprite
		glow_sprite = Sprite2D.new()
		glow_sprite.position = position
		glow_sprite.rotation = deg_to_rad(current_angle)
		glow_sprite.scale = Vector2(1.7, 0.4)
		glow_sprite.modulate = Color(1, 1, 0, 0.5)
		glow_sprite.visible = false
		parent_node.add_child(glow_sprite)
	
	func update(pressed: bool, delta: float):
		activated = pressed
		var target_angle = active_angle if pressed else rest_angle
		current_angle = lerp(current_angle, target_angle, 0.3)
		
		# Update sprite rotation
		sprite.rotation = deg_to_rad(current_angle)
		glow_sprite.rotation = deg_to_rad(current_angle)
		glow_sprite.visible = activated
	
	func get_end_position() -> Vector2:
		var angle_rad = deg_to_rad(current_angle)
		return position + Vector2(cos(angle_rad), sin(angle_rad)) * length

# Enhanced Bumper with animation and particles
class EnhancedBumper:
	var sprite: Sprite2D
	var glow_sprite: Sprite2D
	var particles: GPUParticles2D
	var position: Vector2
	var radius: float = 45.0
	var hit_animation: int = 0
	var points: int = 100
	var base_scale: Vector2 = Vector2(1.5, 1.5)
	
	func _init(pos: Vector2, parent_node: Node2D):
		position = pos
		
		# Create main sprite
		sprite = Sprite2D.new()
		sprite.position = position
		sprite.scale = base_scale
		parent_node.add_child(sprite)
		
		# Create glow effect
		glow_sprite = Sprite2D.new()
		glow_sprite.position = position
		glow_sprite.scale = base_scale * 1.2
		glow_sprite.modulate = Color(1, 0, 0, 0)
		parent_node.add_child(glow_sprite)
		
		# Create hit particles
		particles = GPUParticles2D.new()
		setup_hit_particles()
		parent_node.add_child(particles)
	
	func setup_hit_particles():
		var material = ParticleProcessMaterial.new()
		material.direction = Vector3(0, -1, 0)
		material.spread = 45.0
		material.initial_velocity_min = 100.0
		material.initial_velocity_max = 200.0
		material.gravity = Vector3(0, 98, 0)
		material.scale_min = 0.2
		material.scale_max = 0.8
		material.color = Color.YELLOW
		
		particles.position = position
		particles.process_material = material
		particles.amount = 30
		particles.lifetime = 2.0
		particles.emitting = false
	
	func update():
		if hit_animation > 0:
			hit_animation -= 1
			var glow_alpha = float(hit_animation) / 10.0
			glow_sprite.modulate.a = glow_alpha
			sprite.scale = base_scale * (1.0 + glow_alpha * 0.3)
		else:
			glow_sprite.modulate.a = 0
			sprite.scale = base_scale
	
	func check_collision(ball_obj: EnhancedBall) -> bool:
		var distance = position.distance_to(ball_obj.position)
		if distance <= ball_obj.radius + radius:
			var normal = (ball_obj.position - position).normalized()
			var dot_product = ball_obj.velocity.dot(normal)
			ball_obj.velocity -= 2 * dot_product * normal
			ball_obj.velocity += normal * 5.0
			
			var overlap = ball_obj.radius + radius - distance
			ball_obj.position += normal * overlap
			
			hit_animation = 10
			particles.restart()
			return true
		return false

# Game variables
var ball: EnhancedBall
var left_flipper: EnhancedFlipper
var right_flipper: EnhancedFlipper
var bumpers: Array[EnhancedBumper] = []

# UI
var score: int = 0
var game_over: bool = false
var score_label: Label
var game_over_label: Label
var controls_label: Label

# Touch controls
var left_touch_area: TouchScreenButton
var right_touch_area: TouchScreenButton
var launch_touch_area: TouchScreenButton

func _ready():
	create_simple_textures()
	setup_ui()
	setup_game_objects()
	setup_touch_controls()
	setup_background_effects()

func create_simple_textures():
	# Since we don't have image files, create simple colored textures
	ball_texture = create_circle_texture(24, Color.WHITE, Color.GRAY)
	flipper_texture = create_rect_texture(Vector2(80, 16), Color.SILVER)
	bumper_texture = create_circle_texture(90, Color.BLUE, Color.WHITE)
	background_texture = create_rect_texture(Vector2(SCREEN_WIDTH, SCREEN_HEIGHT), Color(0.1, 0.1, 0.2))

func create_circle_texture(size: int, fill_color: Color, border_color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = size / 2
	var radius = center - 2
	
	for x in range(size):
		for y in range(size):
			var distance = Vector2(x - center, y - center).length()
			if distance <= radius:
				image.set_pixel(x, y, fill_color)
			elif distance <= center:
				image.set_pixel(x, y, border_color)
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func create_rect_texture(size: Vector2, color: Color) -> ImageTexture:
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func setup_ui():
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.position = Vector2(20, 20)
	score_label.add_theme_font_size_override("font_size", 36)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(score_label)
	
	game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nTap to Restart"
	game_over_label.position = Vector2(SCREEN_WIDTH/2 - 150, SCREEN_HEIGHT/2 - 50)
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	game_over_label.visible = false
	add_child(game_over_label)
	
	controls_label = Label.new()
	controls_label.text = "Tap sides for flippers • Tap top to launch"
	controls_label.position = Vector2(20, SCREEN_HEIGHT - 60)
	controls_label.add_theme_font_size_override("font_size", 24)
	controls_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(controls_label)

func setup_game_objects():
	ball = EnhancedBall.new(Vector2(SCREEN_WIDTH / 2, 150), self)
	ball.sprite.texture = ball_texture
	
	left_flipper = EnhancedFlipper.new(Vector2(200, SCREEN_HEIGHT - 180), true, self)
	left_flipper.sprite.texture = flipper_texture
	left_flipper.glow_sprite.texture = flipper_texture
	
	right_flipper = EnhancedFlipper.new(Vector2(520, SCREEN_HEIGHT - 180), false, self)
	right_flipper.sprite.texture = flipper_texture
	right_flipper.glow_sprite.texture = flipper_texture
	
	# Create bumpers
	bumpers.clear()
	var bumper_positions = [
		Vector2(180, 400),
		Vector2(360, 350),
		Vector2(540, 400),
		Vector2(270, 600),
		Vector2(450, 600)
	]
	
	for pos in bumper_positions:
		var bumper = EnhancedBumper.new(pos, self)
		bumper.sprite.texture = bumper_texture
		bumper.glow_sprite.texture = bumper_texture
		bumpers.append(bumper)

func setup_touch_controls():
	left_touch_area = TouchScreenButton.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)
	left_touch_area.shape = left_shape
	left_touch_area.position = Vector2(0, SCREEN_HEIGHT*2/3)
	add_child(left_touch_area)
	
	right_touch_area = TouchScreenButton.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)
	right_touch_area.shape = right_shape
	right_touch_area.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT*2/3)
	add_child(right_touch_area)
	
	launch_touch_area = TouchScreenButton.new()
	var launch_shape = RectangleShape2D.new()
	launch_shape.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT/3)
	launch_touch_area.shape = launch_shape
	launch_touch_area.position = Vector2(0, 0)
	add_child(launch_touch_area)

func setup_background_effects():
	# Add ambient lighting effect
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	var bg_sprite = Sprite2D.new()
	bg_sprite.texture = background_texture
	bg_sprite.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
	bg_sprite.z_index = -10
	canvas_layer.add_child(bg_sprite)

func _process(delta):
	handle_input()
	if not game_over:
		update_game(delta)

func handle_input():
	var left_pressed = left_touch_area.is_pressed() or Input.is_action_pressed("left_flipper")
	var right_pressed = right_touch_area.is_pressed() or Input.is_action_pressed("right_flipper")
	var launch_pressed = launch_touch_area.is_pressed() or Input.is_action_just_pressed("launch")
	
	left_flipper.update(left_pressed, get_process_delta_time())
	right_flipper.update(right_pressed, get_process_delta_time())
	
	if launch_pressed and not game_over and ball.position.y < 200:
		ball.velocity = Vector2(randf_range(-3, 3), 12)
	
	if Input.is_action_just_pressed("restart") and game_over:
		restart_game()
	
	if game_over and (launch_touch_area.is_pressed() or left_touch_area.is_pressed() or right_touch_area.is_pressed()):
		restart_game()

func update_game(delta):
	ball.update_physics(delta)
	
	check_flipper_collision(left_flipper)
	check_flipper_collision(right_flipper)
	
	for bumper in bumpers:
		bumper.update()
		if bumper.check_collision(ball):
			score += bumper.points
			score_label.text = "Score: " + str(score)
	
	if ball.position.y > SCREEN_HEIGHT:
		game_over = true
		game_over_label.visible = true
		controls_label.visible = false
		ball.trail_particles.emitting = false

func check_flipper_collision(flipper: EnhancedFlipper):
	var end_pos = flipper.get_end_position()
	var distance_to_line = point_distance_to_line(ball.position, flipper.position, end_pos)
	
	if distance_to_line <= ball.radius + 8:
		if flipper.activated:
			var angle_rad = deg_to_rad(flipper.current_angle - 90)
			var force = Vector2(cos(angle_rad), sin(angle_rad)) * 18
			ball.velocity += force
		else:
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
	if ball:
		ball.sprite.queue_free()
		ball.trail_particles.queue_free()
	
	ball = EnhancedBall.new(Vector2(SCREEN_WIDTH / 2, 150), self)
	ball.sprite.texture = ball_texture
	
	score = 0
	game_over = false
	score_label.text = "Score: 0"
	game_over_label.visible = false
	controls_label.visible = true
	
	for bumper in bumpers:
		bumper.hit_animation = 0

func _draw():
	# Draw walls with gradient effect
	draw_rect(Rect2(0, 0, SCREEN_WIDTH, 15), Color.WHITE)
	draw_rect(Rect2(0, 0, 15, SCREEN_HEIGHT), Color.WHITE)
	draw_rect(Rect2(SCREEN_WIDTH - 15, 0, 15, SCREEN_HEIGHT), Color.WHITE)