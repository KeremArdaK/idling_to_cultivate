extends Node

var player_inv: Inventory = preload("res://Player/players_inventory.tres")
var total_dark_mana: int = 1000
var current_floor: int = 1

var inner_str : float = 10.0
var outer_str: float = 10.0
var bamt : float = 10.0 #body and mind toughness
var min_damage: float = 0.0
var max_damage: float = 0.0
var attack_speed: float = 0.0
var crit_chance: float = 0.0
var block_chance: float = 0.0
var damage_reduction: float = 0.0
var max_hp: float = 0.0
var hp_regen: float = 0.0

var unlocked_skills: Array[PassiveSkill] = []
var equipped_skills: Array[PassiveSkill] = []
var max_equip_slots: int = 1 #prestij ile artacak

#her stat değiştiğinde bu fonksiyon çağırılacak
func calculate_combat_stats() -> void:
	#innerstr
	min_damage = 5.0 + (inner_str * 0.5)
	attack_speed = 20.0 + (inner_str * 0.2)
	crit_chance = clamp(inner_str * 0.5, 0.0, 100.0)
	#outerstr
	max_damage = 10.0 + (outer_str * 1.5)
	block_chance = clamp(outer_str * 0.5, 0.0, 75.0)
	#bamt
	max_hp = 100.0 + (outer_str * 5.0) + (bamt * 15.0)
	hp_regen = bamt * 0.2
	damage_reduction = clamp(bamt * 0.4, 0.0, 85.0)
	#clamp en sondaki sayıyı geçmesini engeller. yani en fazla
	#%100 crit, %75 block ve %85 dmg reduction olabilir.
