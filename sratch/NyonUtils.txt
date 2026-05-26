class_name NyonUtils

const STEFAN_BOLTZMANN: float = 5.670374419E-8 # W⋅m−2⋅K−4
const GRAVITATIONAL_CONSTANT: float = 6.67430e-11 # N⋅m^2⋅kg^(−2)
const GRAVITY_IN_M: float = 9.80665 # m/s^2
const AU: float = 1.495979e+11 # m

const SOLAR_MASS: float = 1.9885e30 # Kg
const SOLAR_RADIUS: float = 6.957e8 # m
const SOLAR_LUMINOSITY: float = 3.828e26 # W
const SOLAR_VOLUME: float = 1.41044001085e+27 # m^3
const SOLAR_DENSITY: float = 1.40984372586 # g/c^3
const SOLAR_SURFACE_GRAVITY = 274.21254 # m/s^2
const SOLAR_SURFACE_AREA: float = 6.08210440213e+18 # m^2
const S_MASS_SYMBOL: String = "M☉"
const S_RADIUS_SYMBOL: String = "R☉"
const S_LUMINOSITY_SYMBOL: String = "L☉"

static func to_scientific_notation(number: float, decimal_places: int = 3) -> String:

	if number == 0:
		return "0"

	var negative_sign: String = "-" if number < 0 else ""
	number = abs(number)

	var exponent: float = floor(log(number) / log(10))
	var coefficient: float = number / pow(10, exponent)

	var coefficient_string: String = "%.*f" % [decimal_places, coefficient]

	coefficient_string = coefficient_string.rstrip("0").rstrip(".")

	var exponent_string: String = "E%+d" % exponent

	return negative_sign + coefficient_string + exponent_string

static func dict_to_json(p_dict: Dictionary, p_path: String) -> bool:

	var f: FileAccess = FileAccess.open(p_path, FileAccess.WRITE)
	var json_string: String = JSON.stringify(p_dict, "\t")

	var to_return: bool = f.store_string(json_string)
	f.close()

	return to_return

static func json_to_dict(p_path: String) -> Dictionary:

	var f: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	var json_string: String = f.get_as_text()
	f.close()

	return JSON.parse_string(json_string)