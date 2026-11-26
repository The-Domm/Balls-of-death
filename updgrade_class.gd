class_name UpgradeData
extends RefCounted

var name : String=""
var level:int=0
var max_level:int
var initial_cost:int
var scaled_cost: Callable
var effect: Callable
# Called when the node enters the scene tree for the first time.
func _init(name: String,max_level: int, initial_cost: int, scaled_cost: Callable, effect: Callable = func(level:int): return level+1) -> void:
	assert(max_level != null && initial_cost != null && scaled_cost.is_valid() && effect.is_valid(), "Some values are null")
	self.name=name
	self.max_level=max_level
	self.initial_cost=initial_cost
	self.scaled_cost=scaled_cost
	self.effect=effect

func get_cost() -> int:
	return scaled_cost.call(initial_cost, level)

func get_effect() -> Variant:
	return effect.call(level)
