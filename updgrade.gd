extends CanvasLayer
@onready var list_container: VBoxContainer = $Control/ScrollContainer/VBoxContainer
@onready var parent = get_parent()
var upgrades := {
	&"more_balls": UpgradeData.new("More Balls",3,1,func(initial_cost:int, level:int): return initial_cost*level),
	&"faster_balls": UpgradeData.new("Faster Balls",3,1,func(initial_cost:int, level:int): return initial_cost*level,func(level:int): return 2000*pow(1.2,level)),
	&"bouncier_balls": UpgradeData.new("Bouncier Balls",3,1,func(initial_cost:int, level:int): return initial_cost*level)
}
const UPGRADE_BUTTON=preload("res://upgrade_button.tscn")
var points:int =99
var buttons := {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	for ID in upgrades:
		var button =UPGRADE_BUTTON.instantiate()
		list_container.add_child(button)
		button.upgrade_clicked.connect(_on_upgrade_clicked)
		buttons[ID]=button
	refresh_button()

func _process(delta: float) -> void:
	pass

func show_screen() -> void:
	show()
	get_tree().paused=true

func hide_screen()->void:
	hide()
	get_tree().paused=false
	


func _on_upgrade_clicked(id: String) -> void:
	var data = upgrades[id]
	print("click")
	if(data.get_cost()>points || data.level>=data.max_level):
		return
	else: 
		data.level+=1
		refresh_button()
		
func refresh_button() ->void:
	for ID in buttons:
		var data = upgrades[ID]
		var button = buttons[ID]
		button.update_display(
			ID,
			data.name,
			data.level,
			data.max_level,
			data.get_cost(),
			points >= data.get_cost()
		)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("upgrade_screen"):
		if visible:
			hide_screen()
		else:
			show_screen()
