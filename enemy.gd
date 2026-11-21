extends CharacterBody2D
class_name Enemy

const SPEED = 100
@export var health = 1

@export var boundary_width := 500.0
@export var boundary_height := 300.0

var thrown: bool = false

const my_balls:PackedScene = preload("res://basketball.tscn")

var boundary_center: Vector2

var direction = Vector2.RIGHT.rotated(randi_range(1,4)*randf_range(PI/3, 2*PI/3)).normalized()

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_top: RayCast2D = $RayCastTop
@onready var ray_cast_down: RayCast2D = $RayCastDown

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	boundary_center = global_position
	if(health==3):
		$AnimatedSprite2D.scale*=3
		$CollisionShape2D.scale*=3

func _physics_process(delta: float) -> void:
	if health==0:
		if($AnimatedSprite2D.scale.length()>2):
			$Sprite2D.visible=true
			position-=Vector2(200,0)
			return
		queue_free()
	var bounced := false

	if direction.y < 0.0 and ray_cast_top.is_colliding():
		direction = direction.bounce(Vector2.DOWN)
		bounced = true
	elif direction.y > 0.0 and ray_cast_down.is_colliding():
		direction = direction.bounce(Vector2.UP)
		bounced = true
	elif direction.x < 0.0 and ray_cast_left.is_colliding():
		direction = direction.bounce(Vector2.RIGHT)
		bounced = true
	elif direction.x > 0.0 and ray_cast_right.is_colliding():
		direction = direction.bounce(Vector2.LEFT)
		bounced = true

	var half_size := Vector2(boundary_width, boundary_height) / 2.0
	var next_position:Vector2 = global_position + direction * SPEED * delta
	var offset := next_position - boundary_center

	if offset.x < -half_size.x and direction.x < 0.0:
		direction.x = abs(direction.x)
		bounced = true
	elif offset.x > half_size.x and direction.x > 0.0:
		direction.x = -abs(direction.x)
		bounced = true

	if offset.y < -half_size.y and direction.y < 0.0:
		direction.y = abs(direction.y)
		bounced = true
	elif offset.y > half_size.y and direction.y > 0.0:
		direction.y = -abs(direction.y)
		bounced = true

	if bounced:
		var max_angle := PI/3
		direction = direction.rotated(randf_range(-max_angle, max_angle)).normalized()
	if !thrown:
		var posDif = get_parent().get_node("player").position - position
		if (posDif).length() < 1000:
			var ball = my_balls.instantiate()
			ball.ball_owner=self
			get_tree().current_scene.add_child(ball)
			ball._throw(randf_range(0.1, 0.5), posDif.angle())
			thrown = true

	velocity = direction*SPEED
	move_and_slide()
	
