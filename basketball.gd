class_name BasketBall
extends CharacterBody2D

@export var BOUNCINESS:float =1.1
const THROWABLE:int=2000
var bounce_var:int=0
@export var ball_owner: Node2D = null
@export var bounce_count:int = 1
func _ready() -> void:
	assert(ball_owner != null, "Error: 'target' must be assigned before add_child()!")
	pass
var prevpos : Vector2=Vector2.ZERO

@onready var basketball_sprite: Sprite2D = $basketball_sprite
var fireballtexture: Texture2D = preload("res://assets/sprites/fireball.png")

func _physics_process(delta: float) -> void:
	prevpos=position
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var collision = move_and_collide(velocity*delta)
	if collision:
		var obj = collision.get_collider()
		if "health" in obj:
			obj.health-=1
			ball_owner.thrown = false
			queue_free()
		velocity=(velocity*BOUNCINESS).bounce(collision.get_normal())
		bounce_var+=1
	rotation+=PI/1000*velocity.length()
	if (bounce_var> bounce_count || position.y > 300):
		if(ball_owner != null):
			ball_owner.thrown = false
		free()
		
	
	
func _throw(strenght: float, angle:float,offset:Vector2=Vector2.ZERO)->void:
	position=ball_owner.position+offset
	velocity=(Vector2(THROWABLE,0)*strenght).rotated(angle)+ball_owner.velocity
	if ball_owner is Enemy:
		basketball_sprite.texture = fireballtexture
		print(collision_mask)
	collision_mask = ~ball_owner.collision_layer
	collision_layer = ~ ball_owner.collision_mask
		
