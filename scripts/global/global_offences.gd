extends Node

signal attack_damage_changed
signal melee_damage_changed
signal projectile_damage_changed
signal spell_damage_changed
signal attack_speed_changed
signal physical_damage_changed
signal fire_damage_changed
signal cold_damage_changed
signal lightning_damage_changed
signal poison_damage_changed
signal critical_chance_changed
signal critical_damage_changed

var inc_attack_damage: float = 0
var inc_melee_damage: float = 0
var inc_projectile_damage: float = 0
var inc_spell_damage: float = 0
var inc_attack_speed: float = 0
var inc_physical_damage: float = 0
var inc_fire_damage: float = 0
var inc_cold_damage: float = 0
var inc_lightning_damage: float = 0
var inc_poison_damage: float = 0
var inc_critical_chance: float = 0
var inc_critical_damage: float = 0

var more_attack_damage: float = 0
var more_melee_damage: float = 0
var more_projectile_damage: float = 0
var more_spell_damage: float = 0
var more_attack_speed: float = 0
var more_physical_damage: float = 0
var more_fire_damage: float = 0
var more_cold_damage: float = 0
var more_lightning_damage: float = 0
var more_poison_damage: float = 0
var more_critical_chance: float = 0
var more_critical_damage: float = 0

func get_inc_attack_damage() -> float: return inc_attack_damage
func get_inc_melee_damage() -> float: return inc_melee_damage
func get_inc_projectile_damage() -> float: return inc_projectile_damage
func get_inc_spell_damage() -> float: return inc_spell_damage
func get_inc_attack_speed() -> float: return inc_attack_speed
func get_inc_physical_damage() -> float: return inc_physical_damage
func get_inc_fire_damage() -> float: return inc_fire_damage
func get_inc_cold_damage() -> float: return inc_cold_damage
func get_inc_lightning_damage() -> float: return inc_lightning_damage
func get_inc_poison_damage() -> float: return inc_poison_damage
func get_inc_critical_chance() -> float: return inc_critical_chance
func get_inc_critical_damage() -> float: return inc_critical_damage

func get_more_attack_damage() -> float: return more_attack_damage
func get_more_melee_damage() -> float: return more_melee_damage
func get_more_projectile_damage() -> float: return more_projectile_damage
func get_more_spell_damage() -> float: return more_spell_damage
func get_more_attack_speed() -> float: return more_attack_speed
func get_more_physical_damage() -> float: return more_physical_damage
func get_more_fire_damage() -> float: return more_fire_damage
func get_more_cold_damage() -> float: return more_cold_damage
func get_more_lightning_damage() -> float: return more_lightning_damage
func get_more_poison_damage() -> float: return more_poison_damage
func get_more_critical_chance() -> float: return more_critical_chance
func get_more_critical_damage() -> float: return more_critical_damage

func set_inc_attack_damage(value: float):
	inc_attack_damage = value
	print("inc_attack_damage set to: ", inc_attack_damage)
	emit_signal("attack_damage_changed")

func set_inc_melee_damage(value: float):
	inc_melee_damage = value
	print("inc_melee_damage set to: ", inc_melee_damage)
	emit_signal("melee_damage_changed")
	
func set_inc_projectile_damage(value: float):
	inc_projectile_damage = value
	print("inc_projectile_damage set to: ", inc_projectile_damage)
	emit_signal("projectile_damage_changed")
	
func set_inc_spell_damage(value: float):
	inc_spell_damage = value
	print("inc_spell_damage set to: ", inc_spell_damage)
	emit_signal("spell_damage_changed")

func set_inc_attack_speed(value: float):
	inc_attack_speed = value
	print("inc_attack_speed set to: ", inc_attack_speed)
	emit_signal("attack_speed_changed")

func set_inc_physical_damage(value: float):
	inc_physical_damage = value
	print("inc_physical_damage set to: ", inc_physical_damage)
	emit_signal("physical_damage_changed")
	
func set_inc_fire_damage(value: float):
	inc_fire_damage = value
	print("inc_fire_damage set to: ", inc_fire_damage)
	emit_signal("fire_damage_changed")
	
func set_inc_cold_damage(value: float):
	inc_cold_damage = value
	print("inc_cold_damage set to: ", inc_cold_damage)
	emit_signal("cold_damage_changed")

func set_inc_lightning_damage(value: float):
	inc_lightning_damage = value
	print("inc_lightning_damage set to: ", inc_lightning_damage)
	emit_signal("lightning_damage_changed")

func set_inc_poison_damage(value: float):
	inc_poison_damage = value
	print("inc_poison_damage set to: ", inc_poison_damage)
	emit_signal("poison_damage_changed")

func set_inc_critical_chance(value: float):
	inc_critical_chance = value
	print("inc_critical_chance set to: ", inc_critical_chance)
	emit_signal("critical_chance_changed")

func set_inc_critical_damage(value: float):
	inc_critical_damage = value
	print("inc_critical_damage set to: ", inc_critical_damage)
	emit_signal("critical_damage_changed")
	
# -- More -- #

func set_more_attack_damage(value: float):
	more_attack_damage = value
	print("more_attack_damage set to: ", more_attack_damage)
	emit_signal("attack_damage_changed")

func set_more_melee_damage(value: float):
	more_melee_damage = value
	print("more_melee_damage set to: ", more_melee_damage)
	emit_signal("melee_damage_changed")
	
func set_more_projectile_damage(value: float):
	more_projectile_damage = value
	print("more_projectile_damage set to: ", more_projectile_damage)
	emit_signal("projectile_damage_changed")
	
func set_more_spell_damage(value: float):
	more_spell_damage = value
	print("more_spell_damage set to: ", more_spell_damage)
	emit_signal("spell_damage_changed")

func set_more_attack_speed(value: float):
	more_attack_speed = value
	print("more_attack_speed set to: ", more_attack_speed)
	emit_signal("attack_speed_changed")

func set_more_physical_damage(value: float):
	more_physical_damage = value
	print("more_physical_damage set to: ", more_physical_damage)
	emit_signal("physical_damage_changed")
	
func set_more_fire_damage(value: float):
	more_fire_damage = value
	print("more_fire_damage set to: ", more_fire_damage)
	emit_signal("fire_damage_changed")
	
func set_more_cold_damage(value: float):
	more_cold_damage = value
	print("inc_cold_damage set to: ", more_cold_damage)
	emit_signal("cold_damage_changed")

func set_more_lightning_damage(value: float):
	more_lightning_damage = value
	print("more_lightning_damage set to: ", more_lightning_damage)
	emit_signal("lightning_damage_changed")

func set_more_poison_damage(value: float):
	more_poison_damage = value
	print("more_poison_damage set to: ", more_poison_damage)
	emit_signal("poison_damage_changed")

func set_more_critical_chance(value: float):
	more_critical_chance = value
	print("more_critical_chance set to: ", more_critical_chance)
	emit_signal("critical_chance_changed")

func set_more_critical_damage(value: float):
	more_critical_damage = value
	print("more_critical_damage set to: ", more_critical_damage)
	emit_signal("critical_damage_changed")
