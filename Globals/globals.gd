extends Node

var total_dark_mana: int = 1000
var current_floor: int = 1

var inner_str : float = 10.0
var outer_str: float = 10.0
var bamt : float = 10.0 #body and mind toughness

var unlocked_skills: Array[PassiveSkill] = []
var equipped_skills: Array[PassiveSkill] = []
var max_equip_slots: int = 1 #prestij ile artacak
