extends Control

#sol taraf %60lık
@onready var inventory_grid = $Control/HBoxContainer/LeftPanel_60/ScrollContainer/InventoryGrid
@onready var equipped_grid = $Control/HBoxContainer/LeftPanel_60/EquippedGrid

#%40lık sağ taraf, detaylar var
@onready var skill_icon = $Control/HBoxContainer/RightPanel_40/TextureRect
@onready var skill_name = $Control/HBoxContainer/RightPanel_40/SkillLblName
@onready var skill_desc = $Control/HBoxContainer/RightPanel_40/SkillLblDesc
@onready var skill_rarity = $Control/HBoxContainer/RightPanel_40/SkillLblRarity
@onready var btn_equip = $Control/HBoxContainer/RightPanel_40/Btn_Equip
@onready var btn_unequip = $Control/HBoxContainer/RightPanel_40/Btn_Unequip

var selected_skill: PassiveSkill = null

func _ready() -> void:
	clear_details_panel()
	refresh_inventory_ui()

func refresh_inventory_ui():
	for child in inventory_grid.get_children():
		child.queue_free()
	#her yetenek için bir buton oluşturuyoruz
	for skill in Globals.player_inv.unlocked_skills:
		var btn = Button.new()
		btn.text = skill.skill_name
		btn.custom_minimum_size = Vector2(100,50)
		#butona tıklandığında detayları göstermesi için sinyal
		btn.pressed.connect(_on_skill_btn_pressed.bind(skill))
		
		#yetenek kuşanılmışsa butonun rengini yeşilimsi yapalım
		if Globals.player_inv.equipped_skills.has(skill):
			btn.modulate = Color(0.5, 1.0, 0.5)
			
		inventory_grid.add_child(btn)
func _on_skill_btn_pressed(skill: PassiveSkill):
	selected_skill = skill
	skill_name.text = skill.skill_name
	skill_desc.text = skill.description
	
	var rarity_texts = ["COMMON","RARE","EPIC","LEGENDARY"]
	skill_rarity.text = rarity_texts[skill.rarity]
	
	if Globals.player_inv.equipped_skills.has(skill):
		btn_equip.visible = false
		btn_unequip.visible = true
	else:
		btn_equip.visible = true
		btn_unequip.visible = false

func clear_details_panel():
	skill_name.text = "Bir yetenek seçin"
	skill_rarity.text = ""
	skill_desc.text = ""
	btn_equip.visible = false
	btn_unequip.visible = false
	selected_skill = null
