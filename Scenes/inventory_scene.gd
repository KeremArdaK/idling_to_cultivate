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
	visibility_changed.connect(_on_visibility_changed)
	btn_equip.pressed.connect(_on_btn_equip_pressed)
	btn_unequip.pressed.connect(_on_btn_unequip_pressed)
	
func _on_visibility_changed() -> void:
	if visible: # Eğer bu sekme açıldıysa
		refresh_inventory_ui()
		
func refresh_inventory_ui():
	for child in inventory_grid.get_children():
		child.queue_free()
	for child in equipped_grid.get_children():
		child.queue_free()
	
	#her yetenek için bir buton oluşturuyoruz
	for skill in Globals.player_inv.equipped_skills:
		var eq_btn = Button.new()
		eq_btn.text = skill.skill_name
		eq_btn.custom_minimum_size = Vector2(100, 50)
		eq_btn.modulate = Color(1.0,0.8,0.2)
		eq_btn.pressed.connect(_on_skill_btn_pressed.bind(skill))
		equipped_grid.add_child(eq_btn)
		
	for skill in Globals.player_inv.unlocked_skills:
		var btn = Button.new()
		btn.text = skill.skill_name
		btn.custom_minimum_size = Vector2(100,50)
		btn.pressed.connect(_on_skill_btn_pressed.bind(skill))
		
		if Globals.player_inv.equipped_skills.has(skill):
			btn.modulate = Color(0.5, 1.0, 0.5) # Kuşanılmışsa yeşil
			
		inventory_grid.add_child(btn)

func _on_btn_equip_pressed():
	if selected_skill and not Globals.player_inv.equipped_skills.has(selected_skill):
		
		# EĞER SLOTLAR DOLUYSA, İLK KUŞANILAN YETENEĞİ ÇIKAR (FIFO Mantığı)
		if Globals.player_inv.equipped_skills.size() >= Globals.player_inv.max_equip_slots:
			var removed_skill = Globals.player_inv.equipped_skills.pop_front()
			print("Slot doluydu, çıkarılan yetenek: ", removed_skill.skill_name)
		
		# YENİ YETENEĞİ EKLE VE GÜCÜ HESAPLA
		Globals.player_inv.equipped_skills.append(selected_skill)
		Globals.calculate_combat_stats()
		refresh_inventory_ui()
		
		# Paneli yeni duruma göre güncelle
		_on_skill_btn_pressed(selected_skill)
func _on_btn_unequip_pressed():
	if selected_skill and Globals.player_inv.equipped_skills.has(selected_skill):
		Globals.player_inv.equipped_skills.erase(selected_skill)
		
		# GÜCÜ YENİDEN HESAPLA!
		Globals.calculate_combat_stats()
		
		refresh_inventory_ui()
		_on_skill_btn_pressed(selected_skill)
		
func _on_skill_btn_pressed(skill: PassiveSkill):
	selected_skill = skill
	skill_name.text = skill.skill_name
	skill_desc.text = skill.description
	
	var rarity_texts = ["COMMON","RARE","EPIC","LEGENDARY"]
	skill_rarity.text = rarity_texts[skill.rarity]
	
	# ---- BEFORE / AFTER STAT HESAPLAMASI ----
	if not Globals.player_inv.equipped_skills.has(skill):
		var proj = Globals.get_projected_stats(skill)
		
		# Değişim miktarını hesapla
		var inner_diff = proj["inner_str"] - Globals.inner_str
		
		# Farkın pozitif/negatif olmasına göre renk/işaret ayarlayabilirsin
		var sign_str = "+" if inner_diff >= 0 else ""
		
		# Arayüzdeki (varsayımsal) stat etiketine yazdır
		# Arayüzde $Control/HBoxContainer/RightPanel_40/SkillLblStats adında bir Label olmalı!
		$Control/HBoxContainer/RightPanel_40/SkillLblStats.text = "Inner STR: %s -> %s (%s%s)" % [
			Globals.format_number(Globals.inner_str), 
			Globals.format_number(proj["inner_str"]), 
			sign_str, 
			Globals.format_number(inner_diff)
		]
	else:
		# Zaten kuşanılmışsa projeksiyon yapma
		$Control/HBoxContainer/RightPanel_40/SkillLblStats.text = "Şu Anki Inner STR: " + Globals.format_number(Globals.inner_str)
	# -----------------------------------------

	if Globals.player_inv.equipped_skills.has(skill):
		btn_equip.visible = false
		btn_unequip.visible = true
	else:
		btn_equip.visible = true
		btn_unequip.visible = false

func clear_details_panel():
	skill_name.text = "Select a skill"
	skill_rarity.text = ""
	skill_desc.text = ""
	btn_equip.visible = false
	btn_unequip.visible = false
	selected_skill = null
