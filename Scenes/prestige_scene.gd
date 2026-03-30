extends Control

@onready var lbl_current_dm = $PanelContainer/VBoxContainer/CurrentDMLabel
@onready var lbl_gain = $PanelContainer/VBoxContainer/GainLabel
@onready var btn_prestige = $PanelContainer/VBoxContainer/PrestigeButton

func _ready() -> void:
	# Butonu sinyale bağla
	btn_prestige.pressed.connect(_on_prestige_button_pressed)
	# Sahne her görünür olduğunda UI'ı güncelle
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		update_prestige_ui()

# Kazanılacak Soul Fragment miktarını hesaplayan fonksiyon
func calculate_soul_fragments() -> float:
	# Örnek Formül: Her 1000 Dark Mana için 1, + Geçilen her 10 kat için 5 Soul Fragment
	var from_mana = floor(Globals.total_dark_mana / 1000.0)
	var from_floors = floor(Globals.current_floor / 10.0) * 5.0
	
	return from_mana + from_floors

func update_prestige_ui() -> void:
	var gain = calculate_soul_fragments()
	lbl_current_dm.text = "Sacrifice Dark Mana: " + Globals.format_number(Globals.total_dark_mana)
	lbl_gain.text = "Earn Soul Fragment: " + Globals.format_number(gain)
	
	# Eğer kazanım 1'den küçükse butonu deaktif et ki boşuna prestij atmasın
	btn_prestige.disabled = gain < 1.0 

func _on_prestige_button_pressed() -> void:
	var gain = calculate_soul_fragments()
	if gain >= 1.0:
		# Premium para birimini ekle
		Globals.soul_fragments += gain
		
		var msg = "Darkness sacrificed. " + "+" + Globals.format_number(gain) + "Soul fragments."
		GlobalNotifier.show_notify("Soul Ascension", msg)
		# ---- SOFT RESET BAŞLIYOR ----
		Globals.total_dark_mana = 0.0
		Globals.current_floor = 1
		Globals.enemies_defeated = 0
		
		# Dark Mana ile alınan güçlendirmeleri sıfırla (Çünkü prestij attın)
		for key in Globals.dark_mana_upgrades.keys():
			Globals.dark_mana_upgrades[key] = 0
			
		# Savaş istatistiklerini temiz değerlerle yeniden hesapla
		Globals.calculate_combat_stats()
		
		print("Prestige Başarılı! Kazanılan Ruh: ", gain)
		update_prestige_ui() # Ekranı yenile
