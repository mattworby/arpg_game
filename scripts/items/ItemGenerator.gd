extends Node

const CHANCE_MAGIC = 0.30
const CHANCE_RARE = 0.10

const MAX_PREFIXES = 3
const MAX_SUFFIXES = 3
const MAX_TOTAL_AFFIXES = 6

func _ready():
	randomize()

func generate_item(base_item_id: String, item_level: int = 1, magic_find: float = 0.0) -> Dictionary:
	var base_data = BaseItems.get_base_item(base_item_id)
	if base_data.is_empty():
		return {}

	var roll = randf()
	var rarity = "normal"
	var num_affixes = 0

	var effective_magic_chance = CHANCE_MAGIC * (1.0 + magic_find / 100.0)
	var effective_rare_chance = CHANCE_RARE * (1.0 + magic_find / 100.0)

	if roll < effective_rare_chance:
		rarity = "rare"
		num_affixes = randi_range(3, MAX_TOTAL_AFFIXES)
	elif roll < effective_rare_chance + effective_magic_chance:
		rarity = "magic"
		num_affixes = randi_range(1, 2)
	else:
		rarity = "normal"
		num_affixes = 0

	var generated_item = {
		"base_item_id": base_item_id,
		"base_name": base_data.get("name", "Unknown Item"),
		"type": base_data.get("type", "unknown"),
		"subtype": base_data.get("subtype", "unknown"),
		"grid_size": base_data.get("grid_size", Vector2(1,1)),
		"valid_slots": base_data.get("valid_slots", []),
		"texture": base_data.get("texture", ""),
		"rarity": rarity,
		"prefixes": [],
		"suffixes": [],
		"display_name": base_data.get("name", "Unknown Item"),
		"final_stats": base_data.get("base_stats", {}).duplicate(true),
		"tooltip_color": BaseItems.NORMAL_COLOR,
		"item_level": item_level
	}

	if rarity == "magic" or rarity == "rare":
		var compatible_prefixes = Affixes.get_compatible_affixes(base_data, "prefix", item_level)
		var compatible_suffixes = Affixes.get_compatible_affixes(base_data, "suffix", item_level)

		var prefix_pool = {}
		for p_id in compatible_prefixes:
			prefix_pool[p_id] = Affixes.prefixes[p_id]

		var suffix_pool = {}
		for s_id in compatible_suffixes:
			suffix_pool[s_id] = Affixes.suffixes[s_id]

		var affixes_to_add = num_affixes
		var current_prefixes = 0
		var current_suffixes = 0

		while affixes_to_add > 0 and (current_prefixes < MAX_PREFIXES or current_suffixes < MAX_SUFFIXES) and (not prefix_pool.is_empty() or not suffix_pool.is_empty()):
			var can_add_prefix : bool = current_prefixes < MAX_PREFIXES and not prefix_pool.is_empty()
			var can_add_suffix : bool = current_suffixes < MAX_SUFFIXES and not suffix_pool.is_empty()

			if not can_add_prefix and not can_add_suffix:
				break

			var choice : int = -1
			if can_add_prefix and can_add_suffix:
				choice = randi() % 2
			elif can_add_prefix:
				choice = 0
			else:
				choice = 1

			if choice == 0:
				var selected_prefix_id_list: Array = Affixes.select_weighted_random_affixes(prefix_pool, 1)
				if not selected_prefix_id_list.is_empty():
					var selected_prefix_id = selected_prefix_id_list[0]
					generated_item.prefixes.append(selected_prefix_id)
					prefix_pool.erase(selected_prefix_id)
					current_prefixes += 1
					affixes_to_add -= 1
				else:
					can_add_prefix = false
					if not can_add_suffix: break
			else:
				var selected_suffix_id_list: Array = Affixes.select_weighted_random_affixes(suffix_pool, 1)
				if not selected_suffix_id_list.is_empty():
					var selected_suffix_id = selected_suffix_id_list[0]
					generated_item.suffixes.append(selected_suffix_id)
					suffix_pool.erase(selected_suffix_id)
					current_suffixes += 1
					affixes_to_add -= 1
				else:
					can_add_suffix = false
					if not can_add_prefix: break

		var all_affix_ids = generated_item.prefixes + generated_item.suffixes
		for affix_id in all_affix_ids:
			var affix_data = {}
			if Affixes.prefixes.has(affix_id):
				affix_data = Affixes.prefixes[affix_id]
			elif Affixes.suffixes.has(affix_id):
				affix_data = Affixes.suffixes[affix_id]
			else:
				push_warning("Affix ID '%s' not found in prefixes or suffixes." % affix_id)
				continue

			if affix_data.has("stats"):
				for stat_name in affix_data.stats:
					var affix_stat_value_or_range = affix_data.stats[stat_name]
					var rolled_value

					if affix_stat_value_or_range is Array:
						if affix_stat_value_or_range.size() == 2:
							var min_val = affix_stat_value_or_range[0]
							var max_val = affix_stat_value_or_range[1]

							if min_val > max_val:
								push_warning("Affix stat range min > max for '%s' in affix '%s'. Swapping." % [stat_name, affix_id])
								var temp = min_val
								min_val = max_val
								max_val = temp

							if min_val is float or max_val is float:
								rolled_value = randf_range(float(min_val), float(max_val))
							else:
								rolled_value = randi_range(int(min_val), int(max_val))

						else:
							push_warning("Invalid stat range array size for '%s' in affix '%s'. Expected [min, max]. Skipping stat." % [stat_name, affix_id])
							continue

					elif affix_stat_value_or_range is int or affix_stat_value_or_range is float:
						rolled_value = affix_stat_value_or_range
					else:
						push_warning("Unsupported stat value type for '%s' in affix '%s': %s. Skipping stat." % [stat_name, affix_id, typeof(affix_stat_value_or_range)])
						continue

					if generated_item.final_stats.has(stat_name):
						generated_item.final_stats[stat_name] = generated_item.final_stats[stat_name] + rolled_value
					else:
						generated_item.final_stats[stat_name] = rolled_value

		var prefix_names = []
		for p_id in generated_item.prefixes:
			prefix_names.append(Affixes.prefixes[p_id].name)

		var suffix_names = []
		for s_id in generated_item.suffixes:
			suffix_names.append(Affixes.suffixes[s_id].name)

		var name_parts = prefix_names + [generated_item.base_name] + suffix_names
		generated_item.display_name = " ".join(name_parts).strip_edges()


		var final_affix_count = generated_item.prefixes.size() + generated_item.suffixes.size()
		if final_affix_count == 0:
			generated_item.rarity = "normal"
			generated_item.tooltip_color = BaseItems.NORMAL_COLOR
			generated_item.display_name = generated_item.base_name 
		elif final_affix_count <= 2:
			generated_item.rarity = "magic"
			generated_item.tooltip_color = BaseItems.MAGIC_COLOR
		else:
			generated_item.rarity = "rare"
			generated_item.tooltip_color = BaseItems.RARE_COLOR

	elif rarity == "normal":
		generated_item.tooltip_color = BaseItems.NORMAL_COLOR
		generated_item.display_name = generated_item.base_name


	return generated_item
