class_name BasketBall
extends CharacterBody2D


var bounce_var:int=0
var ball_var :BallValues 
func _ready() -> void:
	assert(ball_var.ball_owner != null, "Error: 'target' must be assigned before add_child()!")
	pass
var prevpos : Vector2=Vector2.ZERO

@onready var basketball_sprite: Sprite2D = $basketball_sprite


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
			ball_var.ball_owner.thrown = false
			queue_free()
		velocity=(velocity*ball_var.bounciness).bounce(collision.get_normal())
		bounce_var+=1
	rotation+=PI/1000*velocity.length()
	if (bounce_var> ball_var.max_bounce || position.y > 300):
		if(ball_var.ball_owner != null):
			ball_var.ball_owner.thrown = false
		free()
		
	
	
func _throw(strenght: float, angle:float,offset:Vector2=Vector2.ZERO)->void:
	position=ball_var.ball_owner.position+offset
	velocity=(Vector2(ball_var.max_force,0)*strenght).rotated(angle)
	if ball_var.ball_owner is Enemy:
		print(collision_mask)
	collision_mask = ~ball_var.ball_owner.collision_layer
	collision_layer = ~ ball_var.ball_owner.collision_mask
		
func setup(ball_var:BallValues):
	self.ball_var=ball_var
	if ball_var.ball_sprite != null:
		$basketball_sprite.texture = ball_var.ball_sprite
