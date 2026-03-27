extends Control

@onready var player_spot = $HBoxContainer/LeftSide/LeftTopPanel/HBoxContainer/PlayerSpot
@onready var enemy_spot = $HBoxContainer/LeftSide/LeftTopPanel/HBoxContainer/EnemySpot
@onready var label_floor = $HBoxContainer/LeftSide/LeftBottomPanel/VBoxContainer/FloorLabel
@onready var label_enemy_count = $HBoxContainer/LeftSide/LeftBottomPanel/VBoxContainer/EnemyCountLabel
@onready var label_dark_mana = $HBoxContainer/RightSide/RightTopPanel/VBoxContainer/DarkManaLabel
@onready var arena_box = $HBoxContainer/LeftSide/LeftTopPanel/HBoxContainer

var original_arena_pos: Vector2
var entity_scene = preload("res://Scenes/battleentity.tscn")
var player_entity
var enemy_entity

var is_combat_paused : bool = false
var atb_max: float = 100.0

var enemies_defeated: int = 0
const ENEMIES_PER_FLOOR: int = 10
var shake_strength : float = 0.0

func _ready() -> void:
	setup_arena()
	update_ui()
	call_deferred("save_original_pos")

func save_original_pos() -> void:
	original_arena_pos = arena_box.position
func setup_arena() -> void:
	player_entity = entity_scene.instantiate()
	enemy_entity = entity_scene.instantiate()
	
	player_spot.add_child(player_entity)
	enemy_spot.add_child(enemy_entity)
	
	player_entity.speed = 500.0
	player_entity.max_hp = 100.0
	player_entity.current_hp = 100.0
	
	spawn_new_enemy()

func spawn_new_enemy() -> void:
	enemy_entity.max_hp = 50 + (Globals.current_floor * 10.0)
	enemy_entity.current_hp = enemy_entity.max_hp
	enemy_entity.speed = 15.0 + (Globals.current_floor * 2)
	enemy_entity.hp_bar.max_value = enemy_entity.max_hp
	enemy_entity.hp_bar.value = enemy_entity.current_hp
	enemy_entity.character_texture.flip_h = true
	
func _process(delta: float) -> void:
	#kamera sarsıntısı eklencek
	if shake_strength > 0:
		arena_box.position = original_arena_pos + Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		shake_strength = lerpf(shake_strength, 0.0, 5 * delta)
	else:
		arena_box.position = original_arena_pos
	if is_combat_paused:
		return
		
	player_entity.atb += player_entity.speed * delta
	enemy_entity.atb += enemy_entity.speed * delta
	
	player_entity.progress_bar.value = player_entity.atb
	enemy_entity.progress_bar.value = enemy_entity.atb
	
	if player_entity.atb >= atb_max:
		execute_attack(player_entity, enemy_entity, true)
	elif enemy_entity.atb >= atb_max:
		execute_attack(enemy_entity, player_entity, false)

func execute_attack(attacker, defender, is_player:bool) -> void:
	is_combat_paused = true
	
	attacker.atb = 0.0
	attacker.progress_bar.value = 0.0
	attacker.play_attack_animation(is_player)
	
	await get_tree().create_timer(0.3).timeout
	
	shake_strength = 3.0
	var damage = 20.0
	defender.take_damage(damage)
	await get_tree().create_timer(0.01).timeout
	
	#death check
	if defender.current_hp <= 0:
		if defender == player_entity:
			print("ÖLDÜN!")
			Globals.current_floor = 1
			enemies_defeated = 0
			player_entity.current_hp = player_entity.max_hp
			player_entity.hp_bar.value = player_entity.max_hp
			spawn_new_enemy()
		elif defender == enemy_entity:
			print("DÜŞMAN ÖLDÜ!")
			enemies_defeated += 1
			var earned_mana = enemies_defeated + 1 
			Globals.total_dark_mana += earned_mana
			print("Toplam Kara Mana:", Globals.total_dark_mana, "| Kazanılan Mana:", earned_mana)
			
			if enemies_defeated > ENEMIES_PER_FLOOR - 1:
				Globals.current_floor += 1
				enemies_defeated = 0
				print("KATA HÜKMETTİN. Yeni Kat: ", Globals.current_floor)
			
			spawn_new_enemy()
			
		player_entity.atb = 0.0
		enemy_entity.atb = 0.0
		update_ui()
		
	is_combat_paused = false

func update_ui() -> void:
	label_dark_mana.text = "Dark Mana: " + str(Globals.total_dark_mana)
	label_enemy_count.text = "Enemy: " + str(enemies_defeated + 1) + "/" + str(ENEMIES_PER_FLOOR)
	label_floor.text = "Floor: " + str(Globals.current_floor)
