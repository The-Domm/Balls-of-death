extends Button


signal upgrade_clicked(upgrade_id: String)

var id: String = ""

func _ready() -> void:
	pressed.connect(func(): upgrade_clicked.emit(id))

func update_display(id: String, title: String, level: int, max_level: int, cost: int, can_afford: bool) -> void:
	self.id = id
	if level >= max_level:
		text = "%s max level" % title
		disabled = true
	else:
		text = "%s (lv.%d) - cost: %d" % [title, level, cost]
		disabled = not can_afford
		
