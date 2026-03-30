extends PanelContainer

@onready var inner_str_lbl: Label = $VBoxContainer/InnerSTR/InnerStrLbl
@onready var inner_str_btn: Button = $VBoxContainer/InnerSTR/InnerStrBtn
@onready var outer_str_lbl: Label = $VBoxContainer/OuterSTR/OuterStrLbl
@onready var outer_str_btn: Button = $VBoxContainer/OuterSTR/OuterStrBtn
@onready var toughness_lbl: Label = $VBoxContainer/Toughness/ToughnessLbl
@onready var toughness_btn: Button = $VBoxContainer/Toughness/ToughnessBtn
@onready var as_lbl: Label = $VBoxContainer/AttackSpeed/ASLbl
@onready var as_btn: Button = $VBoxContainer/AttackSpeed/ASBtn

var base_cost: float = 50.0
var cost_multiplier: float = 1.3

func _process(delta: float) -> void:
	update_all_ui()
	
func _ready() -> void:
	update_all_ui()
	
	inner_str_btn.pressed.connect(func(): buy_upgrade("base_inner_str"))
	outer_str_btn.pressed.connect(func(): buy_upgrade("base_outer_str"))
	toughness_btn.pressed.connect(func(): buy_upgrade("base_bamt"))
	as_btn.pressed.connect(func(): buy_upgrade("base_as"))
	
func get_cost(stat_key: String) -> float:
	var current_level = Globals.dark_mana_upgrades.get(stat_key, 0)
	return base_cost * pow(cost_multiplier, current_level)


func buy_upgrade(stat_key: String) -> void:
	var cost = get_cost(stat_key)
	
	if Globals.total_dark_mana >= cost:
		Globals.total_dark_mana -= cost
		Globals.dark_mana_upgrades[stat_key] += 1
		
		Globals.calculate_combat_stats()
		update_all_ui()
	
	
	
func update_all_ui() -> void:
	inner_str_btn.text = "Upgrade (" + Globals.format_number(get_cost("base_inner_str")) + ")"
	inner_str_lbl.text = "Inner Strength"
	outer_str_btn.text = "Upgrade (" + Globals.format_number(get_cost("base_outer_str")) + ")"
	outer_str_lbl.text = "Outer Strength"
	toughness_btn.text = "Upgrade (" + Globals.format_number(get_cost("base_bamt")) + ")"
	toughness_lbl.text = "Toughness"
	as_btn.text = "Upgrade (" + Globals.format_number(get_cost("base_atk_speed")) + ")"
	as_lbl.text = "Attack Speed"
