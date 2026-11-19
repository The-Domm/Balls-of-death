extends CharacterBody2D

const SPEED = 1000
const JUMP_VELOCITY = -1200.0
var pressed = false
const basket_balls:PackedScene = preload("res://basketball.tscn")
@onready var jatekos: AnimatedSprite2D = $Jatekos
@onready var kez: AnimatedSprite2D = $Kez
@onready var kezhitbox: CollisionShape2D = $Kezhitbox
@onready var feny: PointLight2D = $Feny
var throw_force:int
var startPos = 0
var thrown: bool = false
var dimming=0
func _ready() -> void:
	throw_force= get_parent().get_node("basketball").THROWABLE
	#bossEvent()
	position=Vector2.ZERO
	
var direction := Input.get_axis("move_left", "move_right")
func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	if !thrown:
		var dir:float
		if Input.is_mouse_button_pressed(1):
			if !pressed:
				pressed = true
				startPos = get_local_mouse_position()
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
			get_tree().current_scene.add_child(ball)
			thrown = true
			ball._throw(position + Vector2(dir*36, -50), velocity, force.force, force.angle)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
		get_tree().quit()


func calcForce():
	var relPos :Vector2 = get_local_mouse_position() - startPos
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
	var vel : Vector2=Vector2(throw_force*force, 0).rotated(angle)+velocity
	for i in range(1,10):
		var particles = PARTICLE.instantiate()
		nextPos.y=pos.y+vel.y*i*0.1+0.5*get_gravity().y*i*i*0.01
		nextPos.x=pos.x+vel.x*i*0.1
		get_tree().current_scene.add_child(particles)
		particles.global_position = nextPos
		particle_instances.append(particles)

func _process(delta: float) -> void:
	if(position.y<-6500):
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
	feny.visible=true
	get_parent().get_node("CanvasModulate").visible=true
	dimming=0.01
	pass
