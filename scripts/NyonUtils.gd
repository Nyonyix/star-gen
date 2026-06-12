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

static func _convert_red(kelvin: int) -> int:

	if kelvin <= 66:

		return 255
	
	else:

		var red: int = round(329.698727446 * (kelvin - 60) ** -0.1332047592)
		red = 0 if red < 0 else red
		red = 255 if red > 255 else red
		return red

static func _convert_green(kelvin: int) -> int:

	if kelvin <= 66:

		var green:int = round(99.4708025861 * log(kelvin) - 161.11955681661)
		green = 0 if green < 0 else green
		green = 255 if green > 255 else green
		return green

	else:

		var green: int = round(288.1221695283 * (kelvin - 60) ** -0.0755148492)
		green = 0 if green < 0 else green
		green = 255 if green > 255 else green
		return green 

static func _convert_blue(kelvin: int) -> int:

	if kelvin >= 66:

		return 255

	else:

		if kelvin <= 19:

			return 0
		
		else:

			var blue: int = round(138.5177312231 * log(kelvin - 10) - 305.0447927307)
			blue = 0 if blue < 0 else blue
			blue = 255 if blue > 255 else blue
			return blue  

static func convert_kelvin_to_rgb(kelvin: int) -> Color:

	kelvin = kelvin / 100

	return Color8(_convert_red(kelvin), _convert_green(kelvin), _convert_blue(kelvin))

static func solve_kepler(M: float, e: float) -> float:

	if e < 1E-10:
		return M
	
	var E = M
	for _i in range(20):
		var dE = (E - e * sin(E) - M) / (1.0 - e * cos(E))
		E -= dE
		if abs(dE) < 1E-10:
			break
	
	return E

static func position_at_time(orbit: Orbit, t_days: float) -> Vector2:

	var n = TAU / (orbit.period / 86400.0)
	var M = fmod(orbit.mean_anomaly + n * (t_days - orbit.epoch_days), TAU)
	var e = orbit.eccentricity
	var E = solve_kepler(M, e)
	var a = orbit.semi_major_axis
	var x_local = a * (cos(E) - e)
	var y_local = a * sqrt(1.0 - e * e) * sin(E)

	return Vector2(x_local, y_local).rotated(orbit.argument_of_periapsis)

static func ellipse_points(orbit: Orbit, n_points: int = 128) -> PackedVector2Array:

	var pts = PackedVector2Array()
	var e = orbit.eccentricity
	var a = orbit.semi_major_axis
	var b = a * sqrt(1.0 - e * e)
	var c = a * e
	for i in range(n_points + 1):
		var angle = TAU * float(i) / n_points
		pts.append(Vector2(a * cos(angle) - c, b * sin(angle)).rotated(orbit.argument_of_periapsis))

	return pts
