extends CharacterBody2D

@export var BOUNCINESS:float =1.1
@export var THROWABLE:int=2000
var bounce_var:int=0
var fireball_owner: Node2D = null
@export var bounce_count:int = 1
func _ready() -> void:
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
		if fireball_owner != null and obj.name == "player":
			get_tree().reload_current_scene()
		if "health" in obj and obj != fireball_owner:
			obj.health-=1
			if (fireball_owner != null):
				fireball_owner.thrown = false
			else:
				get_parent().get_node("player").thrown = false
			queue_free()
		velocity=(velocity*BOUNCINESS).bounce(collision.get_normal())
		bounce_var+=1
	rotation+=PI/1000*velocity.length()
	if (bounce_var> bounce_count || position.y > 300):
		if (fireball_owner != null):
			fireball_owner.thrown = false
		else:
			get_parent().get_node("player").thrown = false
		free()
		
	
	
func _throw(pos:Vector2, starting_vel:Vector2, strenght: float, angle:float, fireball = null)->void:
	position=pos
	velocity=(Vector2(THROWABLE,0)*strenght).rotated(angle)+starting_vel
	if fireball:
		basketball_sprite.texture = fireballtexture
		fireball_owner = fireball
		collision_mask = 1<<7 | 1
		print(collision_mask)
		
