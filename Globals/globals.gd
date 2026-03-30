extends Node

var dark_mana_upgrades: Dictionary = {
	"base_inner_str": 0,
	"base_outer_str": 0,
	"base_bamt": 0,
	"base_as": 0
}

var suffixes = ["","K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc","Ud","Dd","Td"]
var player_inv: Inventory = preload("res://Player/players_inventory.tres")
var total_dark_mana: float = 1000.0
var current_floor: int = 1
var enemies_defeated: int = 0
var roll_cost: float = 100.0
var total_enemies_defeated: int = 0

var soul_fragments: float = 0.0
var prestige_dmg_mult: float = 0.0
var prestige_health_mult: float = 0.0
var prestige_upgrades: Dictionary = {
	"pure_strength": 0,
	"immortal_flesh": 0
}

var total_life_steal: float = 0.0
var total_poison_dmg: float = 0.0
var total_burn_dmg: float = 0.0
var total_bleed_dmg: float = 0.0
#base statlar
var base_inner_str: float = 10.0
var base_outer_str: float = 10.0
var base_bamt: float = 10.0

#yeteneklerle çarpılmış statlar
var inner_str : float = 10.0
var outer_str: float = 10.0
var bamt : float = 10.0

#dark mana kazancını arttıran stat
var dark_mana_gain_multiplier: float = 1.0

#savaş statları
var min_damage: float = 0.0
var max_damage: float = 0.0
var attack_speed: float = 0.0
var crit_chance: float = 0.0
var block_chance: float = 0.0
var damage_reduction: float = 0.0
var max_hp: float = 0.0
var hp_regen: float = 0.0

#savaş gücümüzü yeniden hesaplayan motor
func calculate_combat_stats() -> void:
	# 1. ÖNCE DARK MANA YÜKSELTMELERİNİ TEMEL STATLARA EKLE
	# Her bir seviye upgrade'i sana 5 stat puanı versin (bu çarpanı dilediğin gibi dengele)
	inner_str = base_inner_str + (dark_mana_upgrades["base_inner_str"] * 5.0)
	outer_str = base_outer_str + (dark_mana_upgrades["base_outer_str"] * 5.0)
	bamt = base_bamt + (dark_mana_upgrades["base_bamt"] * 5.0)
	
	dark_mana_gain_multiplier = 1.0
	total_bleed_dmg = 0.0
	total_burn_dmg = 0.0
	total_poison_dmg = 0.0
	total_life_steal = 0.0
	
	# 2. ÇANTADAKİ YETENEKLERİN ÇARPANLARINI UYGULA
	for skill in player_inv.equipped_skills:
		inner_str *= skill.inner_strength_mult
		outer_str *= skill.outer_strength_mult
		bamt *= skill.toughness_mult
		dark_mana_gain_multiplier *= skill.dark_mana_gain_mult
		total_bleed_dmg += skill.bleed_dmg_per_sec
		total_burn_dmg += skill.burn_dmg_per_sec
		total_poison_dmg += skill.poison_dmg_per_sec
		total_life_steal += skill.life_steal_percent
		
	# 3. YENİ STATLARLA SAVAŞ GÜCÜNÜ HESAPLA
	min_damage = 50.0 + (inner_str * 0.5)
	
	# Dikkat: Attack Speed'i doğrudan dark mana upgrade seviyesiyle(x2.0) arttırıyoruz!
	attack_speed = 20.0 + (inner_str * 0.2) + (dark_mana_upgrades["base_as"] * 2.0)
	
	crit_chance = clamp(inner_str * 0.5, 0.0, 100.0)
	max_damage = 10.0 + (outer_str * 1.5) + min_damage
	block_chance = clamp(outer_str * 0.5, 0.0, 75.0)
	max_hp = 100.0 + (outer_str * 5.0) + (bamt * 15.0)
	hp_regen = bamt * 0.2
	damage_reduction = clamp(bamt * 0.4, 0.0, 85.0)

func format_number(value: float) -> String:
	# Eğer sayı 1000'den küçükse hiç elleme, düz yaz
	if value < 1000.0:
		return str(round(value))
		
	var index = 0
	var temp_value = value
	
	# sayıyı 1000'e bölebildiğimiz kadar bölüp, index'i arttırıyoruz
	while temp_value >= 1000.0 and index < suffixes.size() - 1:
		temp_value /= 1000.0
		index += 1
		
	# virgülden sonra iki basamak gösterir (Örn: 1.25M veya 34.50T)
	return "%.2f%s" % [temp_value, suffixes[index]]
	
# Bu fonksiyon, parametre olarak verilen yetenek kuşanılırsa statların ne olacağını tahmin eder.
func get_projected_stats(new_skill: PassiveSkill) -> Dictionary:
	# 1. Temel statları geçici değişkenlere al (Dark mana yükseltmeleri dahil)
	var p_inner = base_inner_str + (dark_mana_upgrades["base_inner_str"] * 5.0)
	var p_outer = base_outer_str + (dark_mana_upgrades["base_outer_str"] * 5.0)
	var p_bamt = base_bamt + (dark_mana_upgrades["base_bamt"] * 5.0)
	
	# 2. Çantanın sahte bir kopyasını oluştur
	var sim_skills = player_inv.equipped_skills.duplicate()
	
	# Eğer bu yetenek zaten kuşanılmışsa statlar değişmez, aynısını döndür
	if sim_skills.has(new_skill):
		return {"inner_str": inner_str, "outer_str": outer_str, "bamt": bamt}
	
	# Eğer slotlar doluysa, gerçeğinde olduğu gibi ilk yeteneği simülasyondan çıkar
	if sim_skills.size() >= player_inv.max_equip_slots:
		sim_skills.pop_front()
		
	# Yeni yeteneği simülasyona ekle
	sim_skills.append(new_skill)
	
	# 3. Yeni komboya göre çarpanları uygula
	for skill in sim_skills:
		p_inner *= skill.inner_strength_mult
		p_outer *= skill.outer_strength_mult
		p_bamt *= skill.toughness_mult
		
	# 4. Sonuçları bir Sözlük (Dictionary) olarak raporla
	return {
		"inner_str": p_inner,
		"outer_str": p_outer,
		"bamt": p_bamt
	}
