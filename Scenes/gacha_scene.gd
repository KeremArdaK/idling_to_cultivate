extends Control

@onready var mana_label = $VBoxContainer/ManaLabel
@onready var btn_roll = $VBoxContainer/Btn_Roll
@onready var result_name = $VBoxContainer/ResultPanel/VBoxContainer/ResultName
@onready var result_rarity = $VBoxContainer/ResultPanel/VBoxContainer/ResultRarity
@onready var result_desc = $VBoxContainer/ResultPanel/VBoxContainer/ResultDesc

var all_skills: Array[PassiveSkill] = []
var roll_cost: int = 100

func _ready() -> void:
	load_all_skills()
	update_ui()

func load_all_skills(path: String = "res://Skills/"):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# "." ve ".." klasörün kendisi ve üst klasör demektir. onları es geçtik
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				#yani eğer bu bir klasör ise:
				load_all_skills(path + file_name + "/")
			
			#eğer dosyaysa yani yetenek dosyaları ise
			elif file_name.ends_with(".tres") or file_name.ends_with(".remap"):
				var clean_name = file_name.replace(".remap", "")
				var resource = load(path + clean_name) as PassiveSkill
				if resource:
					all_skills.append(resource)
			
			file_name = dir.get_next()
		#eğer en dışarıdaki klasördeysek yani arama bittiyse
		if path == "res://Skills/":
			print(all_skills.size(), " adet yetenek alt klasörler de dahil başarıyla sunağa yüklendi.")
func update_ui():
	mana_label.text = "Total Dark Mana: " + str(Globals.total_dark_mana)
	btn_roll.disabled = Globals.total_dark_mana < roll_cost




func _on_btn_roll_pressed() -> void:
	if Globals.total_dark_mana >= roll_cost:
		Globals.total_dark_mana -= roll_cost
		update_ui()
		perform_roll()

func perform_roll():
	var roll = randf() #0.0 ile 1.0 arasında bir sayı verecek.
	var target_rarity: PassiveSkill.Rarity
	
	if roll <= 0.01: #%1 ihtimal ile legendary
		target_rarity = PassiveSkill.Rarity.LEGENDARY
	elif roll <= 0.06: #%5 ihtimal (%1 legendary'ye, %5 epic'e.)
		target_rarity = PassiveSkill.Rarity.EPIC
	elif roll <= 0.31: #25 ihtimal ile rare (%6 öncekilere, %25 buraya.)
		target_rarity = PassiveSkill.Rarity.RARE
	else:
		target_rarity = PassiveSkill.Rarity.COMMON
	
	var possible_skills = all_skills.filter(func(s): return s.rarity == target_rarity)

	if possible_skills.size() > 0:
		var pulled_skill = possible_skills.pick_random()
		show_result(pulled_skill)

func show_result(skill: PassiveSkill):
	result_name.text = skill.skill_name
	var rarity_texts = ["COMMON","RARE","EPIC","LEGENDARY"]
	result_rarity.text = rarity_texts[skill.rarity]
	result_desc.text = skill.description
	
	
