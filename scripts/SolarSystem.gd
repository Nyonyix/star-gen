class_name SolarSystem
extends Celestial

var number_of_stars: int:
	get:
		return number_of_stars
	set(v):
		number_of_stars = v

var number_of_non_stars: int:
	get:
		return number_of_non_stars
	set(v):
		number_of_non_stars = v

var stars: Array[Star] = []:
	get:
		return stars
	set(v):
		stars = v

var root: Node2D:
	get:
		return root
	set(v):
		root = v

func _init(p_id: int, p_no_gen: bool) -> void:

	random = RandomNumberGenerator.new()
	random.seed = p_id
	id = p_id

	if p_no_gen == false:
		self.root = self._generate_stars()
		stars = self._collect_stars(self.root)
		number_of_stars = stars.size()

		number_of_non_stars = 0

func _generate_stars() -> Node2D:

	var primary: Star = self._generate_primary_star()
	return _build_node(primary, 0, primary.age * 1E6)

func _build_node(node: Node2D, depth: int, p_system_age: float) -> Node2D:

	if not _should_split_star(node.mass, depth):
		return node
	
	var comp_mass: float = self._determine_companion_mass(node.mass)
	if comp_mass < 0.08:
		return node
	
	var companion: Star = self._generate_companion_star(comp_mass, p_system_age)
	if companion == null:
		return node

	var child_a: Node2D = _build_node(node, depth + 1, p_system_age)
	var child_b: Node2D = _build_node(companion, depth + 1, p_system_age)

	var orbit: Orbit = self._generate_orbit_star(child_a, child_b)
	var bary: Barycenter = Barycenter.new(self.random.randi(), child_a, child_b, orbit)

	return bary

func _should_split_star(p_total_mass_solar: float, depth: int) -> bool:

	if depth >= 3:
		return false

	var base_probability: float = 0.2
	if p_total_mass_solar > 8.0:
		base_probability = 0.9
	elif p_total_mass_solar > 2.0:
		base_probability = 0.65
	elif p_total_mass_solar > 0.5:
		base_probability = 0.5

	var depth_factor: float = pow(0.3, depth)
	
	return self.random.randf() < base_probability * depth_factor

func _determine_companion_mass(p_total_mass_solar: float) -> float:

	return p_total_mass_solar * self.random.randf_range(0.1, 0.9)

func _generate_primary_star() -> Star:

	return Star.new(self.random.randi(), false)

func _generate_companion_star(p_target_mass: float, p_system_age: float) -> Star:

	return Star.new(self.random.randi(), false, p_target_mass, p_system_age)

func _generate_orbit_star(child_a: Node2D, child_b: Node2D) -> Orbit:

	var r_eff_a: float
	if child_a is Star:
		r_eff_a = child_a.radius * NyonUtils.SOLAR_RADIUS
	else:
		r_eff_a = child_a.orbit.semi_major_axis * (1 + child_a.orbit.eccentricity)

	var r_eff_b: float
	if child_b is Star:
		r_eff_b = child_b.radius * NyonUtils.SOLAR_RADIUS
	else:
		r_eff_b = child_b.orbit.semi_major_axis * (1 + child_b.orbit.eccentricity)

	var physical_min: float = 3.0 * (r_eff_a + r_eff_b)

	var stability_min: float = 0.0
	if child_a is Barycenter:
		stability_min = max(stability_min, 5.0 * child_a.orbit.semi_major_axis)
	if child_b is Barycenter:
		stability_min = max(stability_min, 5.0 * child_b.orbit.semi_major_axis)

	var a_min: float = max(physical_min, stability_min)
	var a_min_au: float = a_min / NyonUtils.AU
	if a_min_au > 500.0:
		a_min_au = 500.0

	var log_a_min: float = log(a_min_au) / log(10)
	var log_a_max: float = log(500.0) / log(10)
	var a_au: float = exp(self.random.randf_range(log_a_min, log_a_max) * log(10))

	var e: float = sqrt(self.random.randf())
	while a_au * (1.0 - e) < a_min_au and e > 0.0:
		e -= 0.05
	e = max(e, 0.0)

	var a_m: float = a_au * NyonUtils.AU
	var m_tot_kg: float = (child_a.mass + child_b.mass) * NyonUtils.SOLAR_MASS
	var p_sec: float = TAU * sqrt(pow(a_m, 3.0) / (NyonUtils.GRAVITATIONAL_CONSTANT * m_tot_kg))

	return Orbit.new(a_m, p_sec, e, self.random.randf_range(0.0, TAU))

func to_dict() -> Dictionary:

	return {
		"system_id": self.id,
		"root_object": self.root.to_dict(),
		"number_of_stars": number_of_stars,
		"number_of_non_stars": number_of_non_stars
	}

static func _collect_stars(node: Node2D) -> Array[Star]:

	if node is Star:
		return [node]
	
	var bary = node as Barycenter
	var arr: Array[Star] = []

	arr.append_array(_collect_stars(bary.child_a))
	arr.append_array(_collect_stars(bary.child_b))

	return arr

static func from_dict(p_dict: Dictionary) -> SolarSystem:

	var sys: SolarSystem = SolarSystem.new(p_dict["system_id"], true)
	
	if p_dict["root_object"]["type"] == 'star':
		sys.root = Star.from_dict(p_dict["root_object"])
	else:
		sys.root = Barycenter.from_dict(p_dict["root_object"])

	sys.number_of_stars = p_dict["number_of_stars"]
	sys.number_of_non_stars = p_dict["number_of_non_stars"]
	sys.stars = _collect_stars(sys.root)

	return sys