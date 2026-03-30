extends Control

@onready var player_spot = $HBoxContainer/LeftSide/LeftTopPanel/HBoxContainer/PlayerSpot
@onready var enemy_spot = $HBoxContainer/LeftSide/LeftTopPanel/HBoxContainer/EnemySpot
@onready var label_floor = $HBoxContainer/LeftSide/LeftBottomPanel/VBoxContainer/FloorLabel
@onready var label_enemy_count = $HBoxContainer/LeftSide/LeftBottomPanel/VBoxContainer/EnemyCountLabel
@onready var label_dark_mana = $HBoxContainer/RightSide/RightTopPanel/VBoxContainer/DarkManaLabel
@onready var arena_box = $HBoxContainer/LeftSide/LeftTopPanel/HBoxContainer
@onready var label_name_enemy = $HBoxContainer/LeftSide/LeftBottomPanel/VBoxContainer/EnemyNameLabel
@onready var lbl_dmg = $HBoxContainer/RightSide/RightBottomPanel/PanelContainer/VBoxContainer/Lbl_Damage
@onready var lbl_speed = $HBoxContainer/RightSide/RightBottomPanel/PanelContainer/VBoxContainer/Lbl_AS
@onready var lbl_crit = $HBoxContainer/RightSide/RightBottomPanel/PanelContainer/VBoxContainer/Lbl_Crit
@onready var lbl_block =$HBoxContainer/RightSide/RightBottomPanel/PanelContainer/VBoxContainer/Lbl_Block
@onready var lbl_hp = $HBoxContainer/RightSide/RightBottomPanel/PanelContainer/VBoxContainer/Lbl_HP
@onready var lbl_dr = $HBoxContainer/RightSide/RightBottomPanel/PanelContainer/VBoxContainer/Lbl_DR
@onready var lbl_soul_fragments = $HBoxContainer/RightSide/RightTopPanel/VBoxContainer/SoulFragmentsLbl
#boss isimlerini oluşturmak için gereken değişkenler:
var boss_first_name = ["Abyssal","Umbral","Hollow","Cursed","Veiled","Crimson","Shattered","Relentless","Ironbound","Feral","Primordial","Forsaken","Ethereal","Arcane"]
var boss_last_name = ["Wraith","Banshee","Specter","Revenant","Wendigo","Chimera","Manticore","Behemoth","Lich","Nephilim","Creep","Golem"]
#sıradan enemyler için
var basic_first_name = ["Mud","Lesser","Stray","Rusted","Rabid","Blind","Foul","Weak","Feral","Wild","Scavenger"]
var basic_last_name = ["Slime","Imp","Goblin","Hound","Crawler","Bat","Skeleton","Bandit","Mite"]
var original_arena_pos: Vector2
var entity_scene = preload("res://Scenes/battleentity.tscn")
var player_entity
var enemy_entity
var dot_timer: float = 0.0

var is_combat_paused : bool = false
var atb_max: float = 100.0

const ENEMIES_PER_FLOOR: int = 10
var shake_strength : float = 0.0

func _ready() -> void:
	setup_arena()
	update_ui()
	call_deferred("save_original_pos")
	
func generate_boss_enemy_name() -> String:
	var f_name = boss_first_name.pick_random()
	var l_name = boss_last_name.pick_random()
	return f_name + " " + l_name

func generate_basic_enemy_name() -> String:
	var basic_f_name = basic_first_name.pick_random()
	var basic_l_name = basic_last_name.pick_random()
	return basic_f_name + " " + basic_l_name
	
func save_original_pos() -> void:
	original_arena_pos = arena_box.position
	
func setup_arena() -> void:
	player_entity = entity_scene.instantiate()
	enemy_entity = entity_scene.instantiate()
	
	player_spot.add_child(player_entity)
	enemy_spot.add_child(enemy_entity)
	
	#savaş başlamadan önce statları hesapla
	Globals.calculate_combat_stats()
	
	player_entity.max_hp = Globals.max_hp
	player_entity.current_hp = Globals.max_hp
	player_entity.speed = Globals.attack_speed
	player_entity.hp_bar.max_value = player_entity.max_hp
	player_entity.hp_bar.value = player_entity.current_hp
	
	spawn_new_enemy()
	update_stats_ui()

func update_stats_ui():
	lbl_dmg.text = "Damage: " + Globals.format_number(round(Globals.min_damage)) + " - " + Globals.format_number(round(Globals.max_damage))
	lbl_speed.text = "Attack Speed: " + str(round(Globals.attack_speed))
	lbl_hp.text = "Maximum Health: " + Globals.format_number(round(Globals.max_hp))
	lbl_crit.text = "Crit Chance: " + str(round(Globals.crit_chance))
	lbl_block.text = "Block Chance: " + str(round(Globals.block_chance))
	lbl_dr.text = "Damage Reduction: " + str(round(Globals.damage_reduction))
	
func spawn_new_enemy() -> void:
	enemy_entity.max_hp = 50 + (Globals.current_floor * 10.0)
	enemy_entity.current_hp = enemy_entity.max_hp
	enemy_entity.speed = 15.0 + (Globals.current_floor * 2)
	enemy_entity.hp_bar.max_value = enemy_entity.max_hp
	enemy_entity.hp_bar.value = enemy_entity.current_hp
	enemy_entity.character_texture.flip_h = true
	
	if Globals.enemies_defeated == ENEMIES_PER_FLOOR - 1:
		label_name_enemy.text = generate_boss_enemy_name()
		enemy_entity.max_hp *= 5.0
		enemy_entity.speed *= 1.2
	else:
		label_name_enemy.text = generate_basic_enemy_name()
	
	enemy_entity.current_hp = enemy_entity.max_hp
	enemy_entity.hp_bar.max_value = enemy_entity.max_hp
	enemy_entity.hp_bar.value = enemy_entity.current_hp
	enemy_entity.character_texture.flip_h = true
	
func _process(delta: float) -> void:
	update_ui()
	if not is_combat_paused and enemy_entity != null:
		dot_timer += delta
		if dot_timer >= 0.5: #dot_timer 1'e ulaştığı zaman
			dot_timer -= 0.5 #sayacı sıfırla
			apply_dot_effects()
	update_stats_ui()
	
	player_entity.max_hp = Globals.max_hp
	player_entity.speed = Globals.attack_speed
	
	#kamera sarsıntısı eklencek
	if shake_strength > 0:
		arena_box.position = original_arena_pos + Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		shake_strength = lerpf(shake_strength, 0.0, 5 * delta)
	else:
		arena_box.position = original_arena_pos
	if is_combat_paused:
		return
		
	if player_entity.current_hp <= player_entity.max_hp:
		player_entity.current_hp += Globals.hp_regen * delta
		
		if player_entity.current_hp > player_entity.max_hp:
			player_entity.current_hp = player_entity.max_hp
		
		player_entity.update_hp_ui()
		
	player_entity.atb += player_entity.speed * delta
	enemy_entity.atb += enemy_entity.speed * delta
	
	player_entity.progress_bar.value = player_entity.atb
	enemy_entity.progress_bar.value = enemy_entity.atb
	
	if player_entity.atb >= atb_max:
		execute_attack(player_entity, enemy_entity, true)
	elif enemy_entity.atb >= atb_max:
		execute_attack(enemy_entity, player_entity, false)

func apply_dot_effects() -> void:
	if Globals.total_poison_dmg > 0:
		deal_dot_damage(Globals.total_poison_dmg, Color.GREEN)
	if Globals.total_burn_dmg > 0:
		deal_dot_damage(Globals.total_burn_dmg, Color.ORANGE)
	if Globals.total_bleed_dmg > 0:
		deal_dot_damage(Globals.total_bleed_dmg, Color.DARK_RED)

func deal_dot_damage(amount: float, color: Color) -> void:
	if enemy_entity == null or enemy_entity.current_hp <= 0:
		return
		
	enemy_entity.current_hp -= amount
	enemy_entity.update_hp_ui()
	
	# renkli göstergeyi yarat
	var indicator = preload("res://Scenes/damage_indicator.tscn").instantiate()
	enemy_entity.add_child(indicator)
	indicator.setup_dot(str(round(amount)), color)
	
	indicator.position.x += randf_range(-10.0, 10.0)
	indicator.position.y += randf_range(-5.0, 5.0)
	
	# eğer zehirden/yanmadan öldüyse
	if enemy_entity.current_hp <= 0:
		enemy_entity.current_hp = 0
		is_combat_paused = true
		check_death(enemy_entity)
		is_combat_paused = false
	

func execute_attack(attacker, defender, is_player:bool) -> void:
	is_combat_paused = true
	
	attacker.atb = 0.0
	attacker.progress_bar.value = 0.0
	attacker.play_attack_animation(is_player)
	
	await get_tree().create_timer(0.3).timeout
	
	shake_strength = 3.0
	await get_tree().create_timer(0.01).timeout
	
	var final_damage: float = 0.0
	var is_crit: bool = false
	var is_blocked: bool = false
	
	if is_player:
		#oyuncu vuruyor ise
		var base_dmg = randf_range(Globals.min_damage, Globals.max_damage)
		
		#kritik hesaplama
		if randf() * 100.0 <= Globals.crit_chance:
			base_dmg *= 2
			is_crit = true
			print("Critical Hit!")
		final_damage = base_dmg
		shake_strength = 20.0 if is_crit else 10.0
		var heal_amount = final_damage * (Globals.total_life_steal / 100.0)
		
		if heal_amount > 0 and player_entity.current_hp < player_entity.max_hp:
			player_entity.current_hp += heal_amount
			
			if player_entity.current_hp > player_entity.max_hp:
				player_entity.current_hp = player_entity.max_hp
			var indicator = preload("res://Scenes/damage_indicator.tscn").instantiate()
			player_entity.add_child(indicator)
			indicator.setup(Globals.format_number(round(heal_amount)), false, true)
			player_entity.update_hp_ui()
	else:
		#düşman vuruyorsa
		var enemy_base_dmg = 10.0 + (Globals.current_floor * 5.0)
		
		if randf() * 100.0 <= Globals.block_chance:
			final_damage = 0.0
			is_blocked = true
			print("You blocked!")
			shake_strength = 5.0
		else:
			var reduction_multiplier = (100.0 - Globals.damage_reduction) / 100.0
			final_damage = enemy_base_dmg * reduction_multiplier
			shake_strength = 15.0
	if not is_blocked:
		defender.take_damage(final_damage)
		var indicator = preload("res://Scenes/damage_indicator.tscn").instantiate()
		defender.add_child(indicator)
		indicator.setup(Globals.format_number(round(final_damage)), is_crit)
	check_death(defender)
		
	is_combat_paused = false

func update_ui() -> void:
	lbl_soul_fragments.text = "Soul Fragments: " + Globals.format_number(Globals.soul_fragments)
	label_dark_mana.text = "Dark Mana: " + Globals.format_number(Globals.total_dark_mana)
	label_enemy_count.text = "Enemy: " + str(Globals.enemies_defeated + 1) + "/" + str(ENEMIES_PER_FLOOR)
	label_floor.text = "Floor: " + str(Globals.current_floor)

func check_death(defender) -> void:
	if defender.current_hp <= 0:
		if defender == player_entity:
			print("ÖLDÜN!")
			Globals.current_floor = 1
			Globals.enemies_defeated = 0
			player_entity.current_hp = player_entity.max_hp
			player_entity.hp_bar.value = player_entity.max_hp
			spawn_new_enemy()
			
		elif defender == enemy_entity:
			print("DÜŞMAN ÖLDÜ!")
			Globals.enemies_defeated += 1
			Globals.total_enemies_defeated += 1
			
			var earned_mana = Globals.total_enemies_defeated + 1 
			var final_earned = round(earned_mana * Globals.dark_mana_gain_multiplier)
			Globals.total_dark_mana += final_earned
			print("Toplam Kara Mana:", Globals.total_dark_mana, "| Kazanılan Mana:", final_earned)
			
			# ÖNCE KAT KONTROLÜNÜ YAP (Böylece yeni düşman yeni kata göre doğar)
			if Globals.enemies_defeated > ENEMIES_PER_FLOOR - 1:
				Globals.current_floor += 1
				Globals.enemies_defeated = 0
				print("KATA HÜKMETTİN. Yeni Kat: ", Globals.current_floor)
				
			# SONRA DÜŞMANI ÇAĞIR
			spawn_new_enemy()
			
		# SAVAŞ BİTTİĞİNDE ARAYÜZÜ KESİNLİKLE GÜNCELLE!
		update_ui()
