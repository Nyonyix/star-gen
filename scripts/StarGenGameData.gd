extends Node

var systems: Array = []
var selected_system_index: int = -1

var gen_index: int
var gen_count: int
var gen_ids: Array = []

const GALAXY_SIZE: float = 1000.0

func start_generation(p_seed: int, p_count: int) -> void:

    systems.clear()

    gen_index = 0
    gen_count = p_count

    var id_rng = RandomNumberGenerator.new()
    id_rng.seed = p_seed
    gen_ids.clear()
    for i in range(p_count):
        gen_ids.append(id_rng.randi())

func generate_step() -> bool:

    if gen_index >= gen_count:
        return false

    var sys = SolarSystem.new(gen_ids[gen_index], false)
    var pos_rng = RandomNumberGenerator.new()
    pos_rng.seed = sys.id
    sys.position = Vector2(pos_rng.randf_range(0, GALAXY_SIZE), pos_rng.randf_range(0, GALAXY_SIZE))

    systems.append(sys)
    gen_index += 1
    return gen_index < gen_count

func get_progress() -> float:

    if gen_count == 0:
        return 0.0    
    return float(gen_index) / float(gen_count)

func is_done() -> bool:
    return gen_index >= gen_count

func system_count() -> int:
    return systems.size()

func to_json(p_path: String) -> void:

    var data: Dictionary = {}
    for sys in systems:
        var entry: Dictionary = sys.to_dict()
        data[str(sys.id)] = entry

    NyonUtils.dict_to_json(data, p_path)

func from_json(p_path: String) -> void:

    var data: Dictionary = NyonUtils.json_to_dict(p_path)
    if data == null:
        return
    
    systems.clear()
    for k in data:
        var entry: Dictionary = data[k]
        var sys: SolarSystem = SolarSystem.from_dict(entry)

        systems.append(sys)