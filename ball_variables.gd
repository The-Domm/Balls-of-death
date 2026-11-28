class_name BallValues
extends RefCounted

var max_force: int
var ball_owner: Node2D
var max_healt: int
var bounciness: float
var ball_sprite: Texture2D

func _init(max_force: int = 2000,ball_owner: Node2D = null,max_healt: int = 1,bounciness: float = 1.1, ball_sprite: Texture2D = null) -> void:
	self.max_force = max_force
	self.ball_owner = ball_owner
	self.max_healt = max_healt
	self.bounciness = bounciness
	self.ball_sprite= ball_sprite
