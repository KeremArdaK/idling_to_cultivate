class_name PassiveSkill
extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export var skill_name: String = "Bilinmeyen Yetenek"
@export_multiline var description: String = "Bu yetenek sana güç verir."
@export var rarity: Rarity = Rarity.COMMON
@export var icon: Texture2D


@export_group("Stat Çarpanları (1.0 = Etkisiz)")
@export var inner_strength_mult: float = 1.0
@export var outer_strength_mult: float = 1.0
@export var toughness_mult: float = 1.0
@export var dark_mana_gain_mult: float = 1.0
@export var poison_dmg_per_sec: float = 0.0
@export var burn_dmg_per_sec: float = 0.0
@export var bleed_dmg_per_sec: float = 0.0
