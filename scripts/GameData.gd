extends Node

var systems: Array = []
var galaxy_positions: Array = []
var selected_system_index: int = -1

var gen_index: int
var gen_count: int
var gen_ids: Array = []

const GALAXY_SIZE: float = 1000.0

func start_generation(p_seed: int, p_count: int) -> void:

    systems.clear()
    galaxy_positions.clear()

    gen_index = 0
    gen_count = p_count

    var id_rng = RandomNumberGenerator.new()
    id_rng.seed = p_seed
    gen_ids.clear()
    for i in range(p_count):
        gen_ids.append(id_rng.randi())

    galaxy_positions.resize(p_count)
    for i in range(p_count):
        var pos_rng = RandomNumberGenerator.new()
        pos_rng.seed = gen_ids[i]
        galaxy_positions[i] = Vector2(pos_rng.randf_range(0, GALAXY_SIZE), pos_rng.randf_range(0, GALAXY_SIZE))