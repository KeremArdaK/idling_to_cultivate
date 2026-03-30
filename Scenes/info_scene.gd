extends Control

@onready var total_enemy_label: Label = $PanelContainer/VBoxContainer/Label

func _process(_delta: float) -> void:
	update_info_ui()

func update_info_ui() -> void:
	total_enemy_label.text = "Total Enemies Defeated: " + Globals.format_number(round(Globals.total_enemies_defeated))
