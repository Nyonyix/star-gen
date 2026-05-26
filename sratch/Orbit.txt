class_name Orbit
extends Resource

var period: float:
    get:
        return period
    set(v):
        period = v

var semi_major_axis: float:
    get:
        return semi_major_axis
    set(v):
        semi_major_axis = v

var eccentricity: float:
    get:
        return eccentricity
    set(v):
        eccentricity = v

var argument_of_periapsis: float:
    get:
        return argument_of_periapsis
    set(v):
        argument_of_periapsis = v

func _init(p_semi_major_axis: float, p_period: float, p_eccentricity: float, p_argument_of_periapsis: float) -> void:

    period = p_period
    semi_major_axis = p_semi_major_axis
    eccentricity = p_eccentricity
    argument_of_periapsis = p_argument_of_periapsis

func to_dict() -> Dictionary:

    return {
        "semi_major_axis_au": self.semi_major_axis / NyonUtils.AU,
        "eccentricity": self.eccentricity,
        "period_days": self.period / 86400.0,
        "argument_of_periapsis_deg": rad_to_deg(argument_of_periapsis)
    }

static func from_dict(p_dict: Dictionary) -> Orbit:

    var ap: float = deg_to_rad(p_dict["argument_of_periapsis_deg"])
    var e: float = p_dict["eccentricity"]
    var p: float = p_dict["period_days"] * 86400.0
    var sma: float = p_dict["semi_major_axis_au"] * NyonUtils.AU

    return Orbit.new(sma, p, e, ap)