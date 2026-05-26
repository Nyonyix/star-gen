extends Node

var system_seed: int = 1337
var random: RandomNumberGenerator = RandomNumberGenerator.new()
var galaxy: Dictionary

func _ready() -> void:

	for i in range(1000):

		pass

		# var star: Star = Star.new(system_seed)

		# print(star.get("stellar_class_string") + " Primary")
		# print("{temperature} K".format({"temperature": snappedi(star.get("temperature"), 0)}))
		# print("{mass} {symbol}".format({"mass": snappedf(star.get("mass"), 0.0001), "symbol": NyonUtils.S_MASS_SYMBOL}))
		# print("{radius} {symbol}".format({"radius": snappedf(star.get("radius"), 0.0001), "symbol": NyonUtils.S_RADIUS_SYMBOL}))
		# print("{luminosity} {symbol}".format({"luminosity": snappedf(star.get("luminosity"), 0.0001), "symbol": NyonUtils.S_LUMINOSITY_SYMBOL}))
		# print(NyonUtils.to_scientific_notation(star.get("age")) + " Years")
		# print("{density} g/c^3".format({"density": snappedf(star.get("density"), 0.001)}))
		# print("{surface_gravity} m/s^2".format({"surface_gravity": snappedf(star.get("surface_gravity"), 0.001)}))
		# print()
		
		# system_seed += 1
		# var com_star: Star = Star.new(system_seed, star.get("mass") * 0.75)

		# print(com_star.get("stellar_class_string" ) + " Companion")
		# print("{temperature} K".format({"temperature": snappedi(com_star.get("temperature"), 0)}))
		# print("{mass} {symbol}".format({"mass": snappedf(com_star.get("mass"), 0.0001), "symbol": NyonUtils.S_MASS_SYMBOL}))
		# print("{radius} {symbol}".format({"radius": snappedf(com_star.get("radius"), 0.0001), "symbol": NyonUtils.S_RADIUS_SYMBOL}))
		# print("{luminosity} {symbol}".format({"luminosity": snappedf(com_star.get("luminosity"), 0.0001), "symbol": NyonUtils.S_LUMINOSITY_SYMBOL}))
		# print(NyonUtils.to_scientific_notation(com_star.get("age")) + " Years")
		# print("{density} g/c^3".format({"density": snappedf(com_star.get("density"), 0.001)}))
		# print("{surface_gravity} m/s^2".format({"surface_gravity": snappedf(com_star.get("surface_gravity"), 0.001)}))
		# print()

	# var galaxy_dict: Dictionary = NyonUtils.json_to_dict("res://galaxy.json")

	# for s in galaxy_dict:

	# 	var sys = SolarSystem.from_dict(galaxy_dict[s])
	# 	print(sys.to_dict())
	# 	print()
	# 	print()
	# 	print(sys.root.to_dict())

func _process(delta: float) -> void:

	var sol_system: SolarSystem = SolarSystem.new(system_seed, false)
	galaxy[system_seed] = sol_system.to_dict()

	system_seed += 1

func _notification(what: int) -> void:

	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			NyonUtils.dict_to_json(galaxy, "res://galaxy.json")
