extends CharacterBody2D

# --- Constants ---
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 150.0
const ROLL_TIME = 0.35

# --- Variables ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_rolling = false
var roll_timer = 0.0

# --- References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Main function ---
func _physics_process(delta: float) -> void:
	# --- If rolling ---
	if is_rolling:
		# apply gravity even during roll
		if not is_on_floor():
			velocity += get_gravity() * delta

		roll_timer -= delta
		move_and_slide()

		if roll_timer <= 0:
			is_rolling = false

		return  # prevents normal movement

	# --- Normal movement ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Horizontal direction (-1, 0, 1) ---
	var direction := Input.get_axis("move_left", "move_right")

	# --- Start roll ---
	if Input.is_action_just_pressed("roll") and is_on_floor():
		start_roll(direction)
		return  # stops normal movement

	# --- Sprite flip ---
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# --- Animations ---
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

	# --- Horizontal movement ---
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- Function to start roll ---
func start_roll(direction: float) -> void:
	if direction == 0:
		direction = -1 if animated_sprite.flip_h else 1  # roll in the direction the sprite is facing

	is_rolling = true
	roll_timer = ROLL_TIME

	velocity.x = direction * ROLL_SPEED  # horizontal velocity
	# keep gravity on Y
	animated_sprite.play("roll")
