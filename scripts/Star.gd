class_name Star
extends Celestial

static var perf_star_total_usec: int
static var perf_star_primary_total_usec: int
static var perf_star_companion_total_usec: int

static var perf_star_primry_class_gen_usec: int
static var perf_star_primry_mass_gen_usec: int
static var perf_star_primry_radius_gen_usec: int
static var perf_star_primry_temperature_gen_usec: int

static var perf_star_companion_class_gen_usec: int
static var perf_star_companion_mass_gen_usec: int
static var perf_star_companion_radius_gen_usec: int
static var perf_star_companion_temperature_gen_usec: int

var start_time: int

const GRAVITY_SUN: float = NyonUtils.GRAVITY_IN_M * 28.02
var def_data: Dictionary = NyonUtils.json_to_dict("res://assets/data/star_definitions.json")["star"]

var luminosity: float:
	get:
		return luminosity
	set(v):
		luminosity = v

var global_scaler: float:
	get:
		return global_scaler
	set(v):
		global_scaler = v

var spectral_symbol: String:
	get:
		return spectral_symbol
	set(v):
		spectral_symbol = v

var spectral_descriptor: String:
	get:
		return spectral_descriptor
	set(v):
		spectral_descriptor = v

var spectral_scaler: float:
	get:
		return spectral_scaler
	set(v):
		spectral_scaler = v	

var luminosity_symbol: String:
	get:
		return luminosity_symbol
	set(v):
		luminosity_symbol = v

var luminosity_descriptor: String:
	get:
		return luminosity_descriptor
	set(v):
		luminosity_descriptor = v

var luminosity_scaler: float:
	get:
		return luminosity_scaler
	set(v):
		luminosity_scaler = v

var stellar_class_string: String:
	get:
		return stellar_class_string
	set(v):
		stellar_class_string = v

func _init(p_id: int, p_no_gen: bool, p_secondary_mass: float = 0, p_system_age: float = 0) -> void:

	random = RandomNumberGenerator.new()
	id = p_id
	random.seed = id

	start_time = Time.get_ticks_usec()

	if p_secondary_mass == 0 and p_no_gen == false:

		global_scaler = random.randf_range(0.0, 0.99)
		spectral_symbol = self._generate_class('spectral')
		spectral_descriptor = self.def_data["spectral_classes"][self.spectral_symbol]["class_descriptor"]
		luminosity_symbol = self._generate_class('luminosity')
		luminosity_descriptor = self.def_data["spectral_classes"][self.spectral_symbol]["luminosity_classes"][self.luminosity_symbol]["class_descriptor"]
		stellar_class_string = spectral_symbol + str(snappedf(global_scaler * 10, 0.1)) + luminosity_symbol + " " + self.spectral_descriptor + " " + self.luminosity_descriptor
		perf_star_primry_class_gen_usec = Time.get_ticks_usec() - start_time
		mass = self._generate_range('mass')
		perf_star_primry_mass_gen_usec = Time.get_ticks_usec() - start_time
		radius = self._generate_range('radius')
		perf_star_primry_radius_gen_usec = Time.get_ticks_usec() - start_time
		temperature = self._generate_range('temperature')
		perf_star_primry_temperature_gen_usec = Time.get_ticks_usec() - start_time
		age = self._assign_age(p_system_age)
		volume = self.calculate_volume(self.radius * NyonUtils.SOLAR_RADIUS) / NyonUtils.SOLAR_VOLUME
		density = self.calculate_density(self.mass * NyonUtils.SOLAR_MASS, self.volume * NyonUtils.SOLAR_VOLUME)
		surface_gravity = self.calculate_surface_gravity(self.mass * NyonUtils.SOLAR_MASS, self.radius * NyonUtils.SOLAR_RADIUS)
		surface_area = self.calculate_surface_area(self.radius * NyonUtils.SOLAR_RADIUS) / NyonUtils.SOLAR_SURFACE_AREA
		luminosity = self._calculate_luminosity() / NyonUtils.SOLAR_LUMINOSITY

		perf_star_primary_total_usec = Time.get_ticks_usec() - start_time
	
	elif p_secondary_mass > 0 and p_no_gen == false:

		var class_limits: Dictionary = self._find_class_limits(p_secondary_mass, p_system_age)

		if p_secondary_mass < class_limits["min"]["mass"]:
			spectral_symbol = class_limits["min"]["spectral_symbol"]
			luminosity_symbol = class_limits["min"]["luminosity_symbol"]
		elif p_secondary_mass > class_limits["max"]["mass"]:
			spectral_symbol = class_limits["max"]["spectral_symbol"]
			luminosity_symbol = class_limits["max"]["luminosity_symbol"]
		else:
			spectral_symbol = self._generate_limited_class('spectral', class_limits)
			luminosity_symbol = self._generate_limited_class('luminosity', class_limits)

		global_scaler = self._get_scaler_from_mass(p_secondary_mass)
		spectral_descriptor = self.def_data["spectral_classes"][self.spectral_symbol]["class_descriptor"]
		luminosity_descriptor = self.def_data["spectral_classes"][self.spectral_symbol]["luminosity_classes"][self.luminosity_symbol]["class_descriptor"]
		stellar_class_string = spectral_symbol + str(snappedf(global_scaler * 10, 0.1)) + luminosity_symbol + " " + self.spectral_descriptor + " " + self.luminosity_descriptor
		mass = self._generate_range('mass')
		radius = self._generate_range('radius')
		temperature = self._generate_range('temperature')
		age = self._assign_age(p_system_age)
		volume = self.calculate_volume(self.radius * NyonUtils.SOLAR_RADIUS) / NyonUtils.SOLAR_VOLUME
		density = self.calculate_density(self.mass * NyonUtils.SOLAR_MASS, self.volume * NyonUtils.SOLAR_VOLUME)
		surface_gravity = self.calculate_surface_gravity(self.mass * NyonUtils.SOLAR_MASS, self.radius * NyonUtils.SOLAR_RADIUS)
		surface_area = self.calculate_surface_area(self.radius * NyonUtils.SOLAR_RADIUS) / NyonUtils.SOLAR_SURFACE_AREA
		luminosity = self._calculate_luminosity() / NyonUtils.SOLAR_LUMINOSITY

func _generate_class(p_class_key: String) -> String:

	var classes: Dictionary

	if p_class_key == 'spectral':
		classes = self.def_data["spectral_classes"]
	elif p_class_key == 'luminosity':
		classes = self.def_data["spectral_classes"][self.spectral_symbol]["luminosity_classes"]

	var weight_sum: float = 0
	for i in classes:
		weight_sum += classes[i]['weight']
	
	var random_value: float = self.random.randf_range(0, weight_sum)

	if p_class_key == 'spectral':
		self.spectral_scaler = random_value
	elif p_class_key == 'luminosity':
		self.luminosity_scaler = random_value

	weight_sum = 0
	for i in classes:

		weight_sum += classes[i]['weight']

		if random_value <= weight_sum:
			return i

	return "E"

func _find_class_limits(p_secondary_mass: float, p_system_age: float) -> Dictionary:

	var classes: Dictionary

	if self.id == 1938881848:
		breakpoint

	var min_mass: float = INF
	var min_mass_spectral_symbol: String
	var min_mass_luminosity_symbol: String

	var max_mass: float = -INF
	var max_mass_spectral_symbol: String
	var max_mass_luminosity_symbol: String

	var spectral_classes: Dictionary = self.def_data["spectral_classes"]
	for s in spectral_classes:

		var luminosity_classes: Dictionary = spectral_classes[s]["luminosity_classes"]
		for l in spectral_classes[s]["luminosity_classes"]:

			var cur_range: Array = luminosity_classes[l]["mass"]

			if p_secondary_mass > cur_range[0] and p_secondary_mass < cur_range[1]:

				if p_system_age > 0 and not self._class_valid_for_age(luminosity_classes[l], p_system_age):
					continue
				
				if not classes.has(s):
					classes[s] = {}

				if not classes[s].has("luminosity_classes"):
					classes[s]["luminosity_classes"] = {}

				classes[s]["weight"] = spectral_classes[s]["weight"]
				classes[s]["luminosity_classes"][l] = luminosity_classes[l]

			elif p_secondary_mass > cur_range[0]:

				if p_system_age > 0 and not self._class_valid_for_age(luminosity_classes[l], p_system_age):
					continue

				if not classes.has(s):
					classes[s] = {}

				if not classes[s].has("luminosity_classes"):
					classes[s]["luminosity_classes"] = {}

				classes[s]["weight"] = spectral_classes[s]["weight"]
				classes[s]["luminosity_classes"][l] = luminosity_classes[l]

			if cur_range[0] < min_mass:
				min_mass = cur_range[0]
				min_mass_spectral_symbol = s
				min_mass_luminosity_symbol = l
			
			if cur_range[1] > max_mass:
				max_mass = cur_range[1]
				max_mass_spectral_symbol = s
				max_mass_luminosity_symbol = l

	var out_dict: Dictionary

	out_dict["classes"] = classes
	out_dict["min"] = {}
	out_dict["min"]["mass"] = min_mass
	out_dict["min"]["spectral_symbol"] = min_mass_spectral_symbol
	out_dict["min"]["luminosity_symbol"] = min_mass_luminosity_symbol
	out_dict["max"] = {}
	out_dict["max"]["mass"] = max_mass
	out_dict["max"]["spectral_symbol"] = max_mass_spectral_symbol
	out_dict["max"]["luminosity_symbol"] = max_mass_luminosity_symbol

	return out_dict

func _class_valid_for_age(p_lum_class: Dictionary, p_system_age: float) -> bool:

	var mass_range: Array
	if p_lum_class.has("progenitor_mass"):
		mass_range = p_lum_class["progenitor_mass"]
	else:
		mass_range = p_lum_class["mass"]

	var ms_lifetime_max: float = clamp(1E10 * pow(mass_range[1], -2.5), 0.0, 13.8E9)
	var ms_lifetime_min: float = clamp(1E10 * pow(mass_range[0], -2.5), 0.0, 13.8E9)

	if p_lum_class.get("luminosity_symbol", "") == "V" or p_lum_class.get("class_descriptor", "").to_lower().find("main sequence") != -1:
		return p_system_age < ms_lifetime_min
	else:
		return p_system_age > ms_lifetime_max

func _get_scaler_from_mass(p_secondary_mass: float) -> float:

	var mass_range: Array = self.def_data["spectral_classes"][self.spectral_symbol]["luminosity_classes"][self.luminosity_symbol]["mass"]

	if p_secondary_mass > mass_range[1]:
		return self.random.randf_range(0.0, 0.99)
	else:
		return 0.99 - ((p_secondary_mass - mass_range[0]) / (mass_range[1] - mass_range[0]))

func _generate_limited_class(p_class_key: String, p_class_limits: Dictionary) -> String:

	var classes: Dictionary

	if p_class_key == 'spectral':
		classes = p_class_limits["classes"]
	elif p_class_key == 'luminosity':
		classes = p_class_limits["classes"][self.spectral_symbol]["luminosity_classes"]

	var inverted_weights_sum: float = 0
	for i in classes:
		inverted_weights_sum += 1.0 / classes[i]["weight"]

	var random_value: float = self.random.randf_range(0, inverted_weights_sum)
	inverted_weights_sum = 0

	for i in classes:
		inverted_weights_sum += 1.0 / classes[i]["weight"]
		
		if random_value <= inverted_weights_sum:
			return i
		
	return "E"

func _generate_range(p_range_key: String) -> float:
	
	var star_range: Array

	if p_range_key == 'temperature':
		star_range = self.def_data["spectral_classes"][self.spectral_symbol]['temperature']
	else:
		star_range = self.def_data["spectral_classes"][self.spectral_symbol]["luminosity_classes"][self.luminosity_symbol][p_range_key]
	
	var delta: float = star_range[1] - star_range[0]
	var variability: float = self.random.randf_range(0, 0.1)
	
	var base_out: float = star_range[0] + delta * (0.99 - self.global_scaler)

	if random.randi_range(0, 1) == 0:
		return base_out + (variability * base_out)
	else:
		return base_out - (variability * base_out)

func _main_sequence_radius() -> float:

	if self.mass <= 1.5:
		return pow(self.mass, 0.8)
	else:
		return pow(self.mass, 0.57)

func _main_sequence_lifetime() -> float:

	var t = 1E10 * pow(self.mass, -2.5)
	return clamp(t, 0.0, 13.8E9)

func _assign_age(p_system_age: float = 0) -> float:

	if p_system_age > 0:
		return p_system_age / 1E6

	var radius_ms: float = self._main_sequence_radius()
	var out_age: float

	if self.radius < 0.02 and self.mass <= 1.4:
		out_age = exp(self.random.randf_range(log(50E6), log(13.8E9))) / 1E6
	elif self.radius <= 1.5 * radius_ms:
		var t_max: float = self._main_sequence_lifetime()
		out_age = self.random.randf_range(0.0, t_max) / 1E6
	else:

		var t_ms: float = self._main_sequence_lifetime()
		var extra: float

		if self.mass < 2.0:
			extra = self.random.randf_range(1E8, 10E9)
		elif self.mass < 8.0:
			extra = self.random.randf_range(20E6, 500E6)
		elif self.mass < 12.0:
			extra = self.random.randf_range(1E6, 50E6)
		else:
			extra = self.random.randf_range(2E5, 5E6)

		out_age =  (t_ms + extra) / 1E6

	return min(out_age, 13.8E9)

func _calculate_luminosity() -> float:

	return NyonUtils.STEFAN_BOLTZMANN * (self.surface_area * NyonUtils.SOLAR_SURFACE_AREA) * pow(self.temperature, 4)

func to_dict() -> Dictionary:

	return {
		"type": "star",
		"id": id,
		"class": self.stellar_class_string,
		"mass_Msun": self.mass,
		"radius_Rsun": self.radius,
		"temperature_K": self.temperature,
		"luminosity_Lsun": self.luminosity,
		"density_gm3": self.density,
		"surface_gravity_ms2": self.surface_gravity,
		"surface_area_SAsun": self.surface_area,
		"age_Myr": self.age
	}

static func from_dict(p_dict: Dictionary) -> Star:

	var s: Star = Star.new(p_dict["id"], true)

	s.age = p_dict["age_Myr"]
	s.stellar_class_string = p_dict["class"]
	s.density = p_dict["density_gm3"]
	s.luminosity = p_dict["luminosity_Lsun"]
	s.mass = p_dict["mass_Msun"]
	s.radius = p_dict["radius_Rsun"]
	s.surface_area = p_dict["surface_area_SAsun"]
	s.surface_gravity = p_dict["surface_gravity_ms2"]
	s.temperature = p_dict["temperature_K"]

	return s