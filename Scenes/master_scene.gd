extends Control

@onready var content_area = $MainVBox/MarginContainer
@onready var gacha_scene = $MainVBox/MarginContainer/GachaScene
@onready var battle_scene = $MainVBox/MarginContainer/BattleScene
@onready var inv_scene = $MainVBox/MarginContainer/InventoryScene
@onready var settings_scene = $MainVBox/MarginContainer/SettingsScene
@onready var skills_scene = $MainVBox/MarginContainer/SkillsScene
@onready var info_scene = $MainVBox/MarginContainer/InfoScene
@onready var saveload_scene = $MainVBox/MarginContainer/SaveLoadScene
@onready var prestige_scene = $MainVBox/MarginContainer/PrestigeScene
@onready var story_scene = $MainVBox/MarginContainer/StoryScene

func _ready() -> void:
	switch_tab(battle_scene) #battle scene ile başlat

func _on_btn_battle_pressed() -> void:
	switch_tab(battle_scene)

func switch_tab(tab_to_show: Control) -> void:
	for child in content_area.get_children():
		child.visible = false
	tab_to_show.visible = true


func _on_btn_gacha_pressed() -> void:
	switch_tab(gacha_scene)

func _on_btn_inv_pressed() -> void:
	switch_tab(inv_scene)


func _on_btn_settings_pressed() -> void:
	switch_tab(settings_scene)


func _on_btn_skills_pressed() -> void:
	switch_tab(skills_scene)


func _on_btn_info_pressed() -> void:
	switch_tab(info_scene)


func _on_btn_save_load_pressed() -> void:
	switch_tab(saveload_scene)


func _on_btn_prestige_pressed() -> void:
	switch_tab(prestige_scene)


func _on_btn_story_pressed() -> void:
	switch_tab(story_scene)
