extends BallBearer
const SPRITE_HEIGHT = 294
const SPEED = 1000
const JUMP_VELOCITY = -1680.0



@onready var jatekos: AnimatedSprite2D = $Jatekos

@export var jump_height_ratio: float = 2.0
@export var time_to_apex: float = 0.75
@export var fall_multiplier: float = 2.2
@export var jump_cut_multiplier: float = 0.5



@onready var player_height: float = SPRITE_HEIGHT * abs(jatekos.scale.y)
@onready var jump_height: float = player_height * jump_height_ratio
@onready var gravity_f: float = (2.0 * jump_height) / (time_to_apex * time_to_apex)
@onready var jump_velocity: float = -(2.0 * jump_height) / time_to_apex


var pressed = false
const basket_balls:PackedScene = preload("res://basketball.tscn")
const basketball_texture: Texture2D = preload("res://assets/sprites/basketBall.png")
@export var health:int=1
@onready var kez: AnimatedSprite2D = $Kez
@onready var kezhitbox: CollisionShape2D = $Kezhitbox
@onready var feny: PointLight2D = $Feny
var startPos = 0
var thrown: bool = false
var dimming=0
var no_boss:bool = true

var start_time := -1

func _ready() -> void:
	ball_var.ball_sprite=basketball_texture
	#bossEvent()
	position=Vector2.ZERO
	ProjectSettings.set_setting("physics/2d/default_gravity", gravity_f)
	var space := get_world_2d().space
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity_f)
	print(get_gravity())
var direction : float
func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	if !thrown:
		var dir:float
		if Input.is_mouse_button_pressed(1):
			if !pressed:
				pressed = true
				startPos = get_viewport().get_mouse_position()
			var force = calcForce()
			if force.angle < 3*PI/2 and force.angle > PI/2:
				dir = -1
			else:
				dir = 1
			show_trow(force.angle, force.force, position + Vector2(dir*36, -50))
		elif pressed:
			pressed = false
			delete_particles()
			var force = calcForce()
			var ball = basket_balls.instantiate()
			ball.setup(ball_var)
			get_tree().current_scene.add_child(ball)
			thrown = true
			ball._throw(force.force, force.angle,Vector2(dir*36, -50))
	# Add the gravity.
	if not is_on_floor():
		if (start_time == -1): start_time = Time.get_ticks_msec()
		velocity += get_gravity() * delta
		print(get_gravity())
	else:
		start_time = -1

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or Time.get_ticks_msec() - start_time <= 200):
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump" ) and velocity.y < 0:
		velocity.y*=0.3
		
	
	if direction == -1:
		jatekos.flip_h = true
		kez.flip_h = true
		kez.position.x = jatekos.position.x - 80
		kezhitbox.position.x = jatekos.position.x - 80
	elif direction == 1:
		jatekos.flip_h = false
		kez.flip_h = false
		kez.position.x = jatekos.position.x + 80
		kezhitbox.position.x = jatekos.position.x + 80
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if(position.y>1000):
		get_tree().reload_current_scene()


func calcForce():
	var relPos :Vector2 = get_viewport().get_mouse_position() - startPos
	var size = get_viewport_rect().size 
	var relSize = 1920/size.x
	var force = relSize * relPos.length()
	var forcePercent = force / 500
	var angle = relPos.angle() + PI
	if (forcePercent > 1):
		forcePercent = 1
	return {"angle": angle, "force": forcePercent}

const PARTICLE: PackedScene = preload("res://particle.tscn")
var particle_instances: Array[Node] = []

func delete_particles():
	for particles in particle_instances:
		if is_instance_valid(particles):
			particles.queue_free()

func show_trow(angle, force, pos: Vector2):
	delete_particles()

	var nextPos = pos
	var vel : Vector2=Vector2(ball_var.max_force*force, 0).rotated(angle)
	for i in range(1,10):
		var particles = PARTICLE.instantiate()
		nextPos.y=pos.y+vel.y*i*0.1+0.5*get_gravity().y*i*i*0.01
		nextPos.x=pos.x+vel.x*i*0.1
		get_tree().current_scene.add_child(particles)
		particles.global_position = nextPos
		particle_instances.append(particles)

func _process(delta: float) -> void:
	if(health<1):
		get_tree().reload_current_scene()
	if(position.y<-6500 && no_boss):
		bossEvent()
		velocity=Vector2(0,100)
		position=Vector2(-1119.0,-24447.0)
	jatekos.offset=Vector2i(0,0)
	if not is_on_floor():
		jatekos.play("jump")
		if thrown:
			kez.play("empty")
		else:
			kez.play("jump")
	else:
		if thrown:
			kez.play("empty")
		else:
			kez.play("idle")
		if direction == 0:
			jatekos.play("idle")
		else:
			jatekos.offset=Vector2i(-100,0)*direction
			jatekos.play("run")
			
func bossEvent()->void:
	no_boss=false
	feny.visible=true
	get_parent().get_node("CanvasModulate").visible=true
	dimming=0.01
	pass
