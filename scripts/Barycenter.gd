class_name Barycenter
extends Celestial

var orbit: Orbit:
    get:
        return orbit
    set(v):
        orbit = v
    
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

func _init(p_id: int, p_child_a: Node2D, p_child_b: Node2D, p_orbit: Orbit) -> void:

    id = p_id
    random = RandomNumberGenerator.new()
    random.seed = id

    child_a = p_child_a
    child_b = p_child_b
    orbit = p_orbit

    mass = child_a.mass + child_b.mass

func to_dict() -> Dictionary:

    return {
        "type": "barycenter",
        "id": self.id,
        "orbit": self.orbit.to_dict(),
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

    return Barycenter.new(l_id, l_child_a, l_child_b, l_orbit)