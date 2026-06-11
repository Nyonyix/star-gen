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

var mean_anomaly: float:
    get:
        return mean_anomaly
    set(v):
        mean_anomaly = v

var parent_id: int:
    get:
        return parent_id
    set(v):
        parent_id = v

var epoch_days: float:
    get:
        return epoch_days
    set(v):
        epoch_days = v

func _init(p_semi_major_axis: float, p_period: float, p_eccentricity: float, p_argument_of_periapsis: float, p_parent_id: int = 0, p_mean_anomaly: float = 0, p_epoch_days: float = 0) -> void:

    period = p_period
    semi_major_axis = p_semi_major_axis
    eccentricity = p_eccentricity
    argument_of_periapsis = p_argument_of_periapsis
    parent_id = p_parent_id
    mean_anomaly = p_mean_anomaly
    epoch_days = p_epoch_days

func to_dict() -> Dictionary:

    return {
        "semi_major_axis_au": self.semi_major_axis / NyonUtils.AU,
        "eccentricity": self.eccentricity,
        "period_days": self.period / 86400.0,
        "argument_of_periapsis_deg": rad_to_deg(argument_of_periapsis),
        "mean_anomaly_deg": rad_to_deg(self.mean_anomaly),
        "parent_id": self.parent_id,
        "epoch_days": self.epoch_days
    }

static func from_dict(p_dict: Dictionary) -> Orbit:

    var ap: float = deg_to_rad(p_dict["argument_of_periapsis_deg"])
    var e: float = p_dict["eccentricity"]
    var p: float = p_dict["period_days"] * 86400.0
    var sma: float = p_dict["semi_major_axis_au"] * NyonUtils.AU
    var ma: float = deg_to_rad(p_dict["mean_anomaly_deg"])
    var p_id: int = p_dict["parent_id"]
    var ed: float = p_dict["epoch_days"]

    return Orbit.new(sma, p, e, ap, p_id, ma, ed)