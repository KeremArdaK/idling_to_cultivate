extends Control

var max_hp : float = 100.0
var current_hp : float = 100.0
var speed : float = 0.0
var atb : float = 0.0

@onready var character_texture = $VBoxContainer/TextureRect
@onready var progress_bar = $VBoxContainer/ATBBar
@onready var original_position = character_texture.position
@onready var hp_bar = $VBoxContainer/HealthBar
@onready var hp_label = $VBoxContainer/HealthBar/Label


func _process(_delta: float) -> void:
	update_hp_ui()
	
func _ready() -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	progress_bar.max_value = 100.0
	
func update_hp_ui() -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_label.text = str(round(current_hp)) + " / " + str(round(max_hp))
	
func take_damage(amount:float) -> void:
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
	update_hp_ui()
	hp_bar.value = current_hp
	
func play_attack_animation(is_player:bool) -> void:
	var direction : float = 1.0 if is_player else -1.0
	var tween = create_tween()
	#0.3
	tween.tween_property(character_texture, "position", original_position + Vector2(-20 * direction, 0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(character_texture, "position", original_position + Vector2(100 * direction, 0), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(character_texture, "position", original_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
