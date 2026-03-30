extends Node

const SAVE_PATH= "user://itoc_save.tres"


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	load_game()
	
func save_game() -> void:
	#boş kayıt şablonu oluşturuyoruz
	var current_save = SaveData.new()
	
	#şablonu doldur
	current_save.total_dark_mana = Globals.total_dark_mana
	current_save.current_floor = Globals.current_floor
	current_save.unlocked_skills = Globals.player_inv.unlocked_skills
	current_save.equipped_skills = Globals.player_inv.equipped_skills
	current_save.enemies_defeated = Globals.enemies_defeated
	current_save.roll_cost = Globals.roll_cost
	current_save.total_enemies_defeated = Globals.total_enemies_defeated
	current_save.soul_fragments = Globals.soul_fragments
	current_save.prestige_upgrades = Globals.prestige_upgrades
	#şablonu diske yazdır
	ResourceSaver.save(current_save, SAVE_PATH)
	print("Başarıyla kaydedildi.")
func load_game() -> void:
	#diskte dosya var mı kontrol et
	if ResourceLoader.exists(SAVE_PATH):
		var loaded_save = ResourceLoader.load(SAVE_PATH) as SaveData
		
		if loaded_save:
			Globals.total_enemies_defeated = loaded_save.total_enemies_defeated
			Globals.enemies_defeated = loaded_save.enemies_defeated
			Globals.roll_cost = loaded_save.roll_cost
			Globals.total_dark_mana = loaded_save.total_dark_mana
			Globals.current_floor = loaded_save.current_floor
			Globals.player_inv.unlocked_skills = loaded_save.unlocked_skills
			Globals.player_inv.equipped_skills = loaded_save.equipped_skills
			
			Globals.calculate_combat_stats()
		else:
			print("kayıtlı dosya yok")
		
func hard_reset() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	#statları fabrika ayarlarına döndür
	Globals.total_dark_mana = 1000
	Globals.roll_cost = 100
	Globals.current_floor = 1
	Globals.enemies_defeated = 0
	Globals.total_enemies_defeated = 0
	
	#çantayı ve yetenekleri tamamen boşalt
	Globals.player_inv.equipped_skills.clear()
	Globals.player_inv.unlocked_skills.clear()
	
	Globals.calculate_combat_stats()
	
	get_tree().reload_current_scene()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

func do_prestige() -> void:
	# 1. Kazanılacak ruh parçalarını hesapla (Örn: Her 5 kat için 1 parça)
	var gained_fragments = floor(Globals.current_floor / 5.0)
	
	if gained_fragments <= 0:
		print("Evreni yakmak için yeterince ileri gitmedin. En az 5. kata ulaşmalısın.")
		return
		
	# 2. Ruh parçalarını evrensel hafızaya ekle
	Globals.soul_fragments += gained_fragments
	print("Kıyamet koptu. Kazanılan Ruh Parçası: ", gained_fragments)
	
	# 3. GEÇİCİ HER ŞEYİ SİL (Hard reset mantığı)
	Globals.total_dark_mana = 1000.0
	Globals.current_floor = 1
	Globals.enemies_defeated = 0
	Globals.roll_cost = 100.0
	Globals.player_inv.unlocked_skills.clear()
	Globals.player_inv.equipped_skills.clear()
	
	# 4. Kaydet ve Evreni Baştan Başlat
	save_game()
	get_tree().reload_current_scene()
