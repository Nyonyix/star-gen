class_name Barycenter
extends Celestial
    
var child_a: Node2D:
    get:
        return child_a
    set(v):
        child_a = v

var child_b: Node2D:
    get:
        return child_b
    set(v):
        child_b = v

var pair_sma: float:
    get:
        return pair_sma
    set(v):
        pair_sma = v

var pair_e: float:
    get:
        return pair_e
    set(v):
        pair_e = v

func _init(p_id: int, p_child_a: Node2D, p_child_b: Node2D) -> void:

    id = p_id
    random = RandomNumberGenerator.new()
    random.seed = id

    child_a = p_child_a
    child_b = p_child_b

    mass = child_a.mass + child_b.mass

func to_dict() -> Dictionary:

    return {
        "type": "barycenter",
        "id": self.id,
        "orbit": self.orbit.to_dict(),
        "pair_semi_major_axis_au": self.pair_sma / NyonUtils.AU,
        "pair_eccentricity": self.pair_e,
        "child_a": self.child_a.to_dict(),
        "child_b": self.child_b.to_dict()
    }

static func from_dict(p_dict: Dictionary) -> Barycenter:

    var l_child_a: Node2D
    if p_dict["child_a"]["type"] == 'star':
        l_child_a = Star.from_dict(p_dict["child_a"])
    else:
        l_child_a = Barycenter.from_dict(p_dict["child_a"])
    
    var l_child_b: Node2D
    if p_dict["child_b"]["type"] == 'star':
        l_child_b = Star.from_dict(p_dict["child_b"])
    else:
        l_child_b = Barycenter.from_dict(p_dict["child_b"])

    var l_orbit: Orbit = Orbit.from_dict(p_dict["orbit"])
    var l_id: int = p_dict["id"]
    var l_pair_sma = p_dict["pair_semi_major_axis_au"] * NyonUtils.AU
    var l_pair_e = p_dict["pair_eccentricity"]

    var bary: Barycenter = Barycenter.new(l_id, l_child_a, l_child_b)
    bary.orbit = l_orbit
    bary.pair_sma = l_pair_sma
    bary.pair_e = l_pair_e

    return bary