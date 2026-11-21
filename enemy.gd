extends BallBearer
class_name Enemy

const SPEED = 100
@export var health = 1
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bounds := Rect2(position-Vector2(500,500),Vector2(1000,1000))
@onready var half_size := Vector2(collision_shape_2d.shape.radius, collision_shape_2d.shape.height / 2.0)*collision_shape_2d.scale
var fireballtexture: Texture2D = preload("res://assets/sprites/fireball.png")
const my_balls:PackedScene = preload("res://basketball.tscn")

var boundary_center: Vector2

var direction = Vector2.RIGHT.rotated(randi_range(1,4)*randf_range(PI/3, 2*PI/3)).normalized()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	velocity=Vector2(SPEED,0).rotated(randf_range(0,2*PI))
	
	ball_var.ball_sprite=fireballtexture
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
	var collision = move_and_collide(velocity*delta)
	if collision:
		var obj = collision.get_collider()
		if "health" in obj:
			obj.health-=1
		velocity=velocity.bounce(collision.get_normal())
		bounced=true	
	if position.x < (bounds.position + half_size).x:
		position.x = (bounds.position + half_size).x
		velocity = velocity.bounce(Vector2.RIGHT)
		bounced=true
	elif position.x > (bounds.end - half_size).x:
		position.x = (bounds.end - half_size).x
		velocity = velocity.bounce(Vector2.LEFT)
		bounced=true
	if position.y < (bounds.position + half_size).y:
		position.y = (bounds.position + half_size).y
		velocity = velocity.bounce(Vector2.DOWN)
		bounced=true
	elif position.y > (bounds.end - half_size).y:
		position.y = (bounds.end - half_size).y
		velocity = velocity.bounce(Vector2.UP)
		bounced=true	

	if bounced:
		var max_angle := PI/3
		velocity = velocity.rotated(randf_range(-max_angle, max_angle))
	if thrown<max_thrown:
		var posDif = get_parent().get_node("player").position - position
		if (posDif).length() < 1000:
			var ball = my_balls.instantiate()
			ball.setup(ball_var)
			get_tree().current_scene.add_child(ball)
			ball._throw(randf_range(0.1, 0.5), posDif.angle())
			thrown += 1

	
	
