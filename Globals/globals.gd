extends Node

var suffixes = ["","K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc","Ud","Dd","Td"]
var player_inv: Inventory = preload("res://Player/players_inventory.tres")
var total_dark_mana: float = 1000.0
var current_floor: int = 1
var enemies_defeated: int = 0
var roll_cost: float = 100.0
var total_enemies_defeated: int = 0
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
	#önce her şeyi temel hale çevir
	inner_str = base_inner_str
	outer_str = base_outer_str
	bamt = base_bamt
	dark_mana_gain_multiplier = 1.0
	total_bleed_dmg = 0.0
	total_burn_dmg = 0.0
	total_poison_dmg = 0.0
	total_life_steal = 0.0
	
	#çantadaki aktif yetenekleri tek tek oku ve gücü arttır
	for skill in player_inv.equipped_skills:
		inner_str *= skill.inner_strength_mult
		outer_str *= skill.outer_strength_mult
		bamt *= skill.toughness_mult
		dark_mana_gain_multiplier *= skill.dark_mana_gain_mult
		total_bleed_dmg += skill.bleed_dmg_per_sec
		total_burn_dmg += skill.burn_dmg_per_sec
		total_poison_dmg += skill.poison_dmg_per_sec
		total_life_steal += skill.life_steal_percent
		
	min_damage = 50.0 + (inner_str * 0.5)
	attack_speed = 20.0 + (inner_str * 0.2)
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
	
	
