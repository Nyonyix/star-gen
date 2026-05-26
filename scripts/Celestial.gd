class_name Celestial
extends Node2D

var mass: float:
	get:
		return mass
	set(v):
		mass = v

var radius: float:
	get:
		return radius
	set(v):
		radius = v

var volume: float:
	get:
		return volume
	set(v):
		volume = v

var surface_area: float:
	get:
		return surface_area
	set(v):
		surface_area = v

var temperature: float: # Kelvin
	get:
		return temperature
	set(v):
		temperature = v

var age: float:
	get:
		return age
	set(v):
		age = v

var surface_gravity: float: # m/s^2
	get:
		return surface_gravity
	set(v):
		surface_gravity = v

var hillsphere: float: # Meters
	get:
		return hillsphere
	set(v):
		hillsphere = v

var density: float: # g/c^3
	get:
		return density
	set(v):
		density = v

var velocity: Vector2:
	get:
		return velocity
	set(v):
		velocity = v

var random: RandomNumberGenerator:
	get:
		return random
	set(v):
		random = v

var id: int:
	get:
		return id
	set(v):
		id = v

func calculate_volume(p_radius: float) -> float:

	return (4.0/3.0) * PI * pow(p_radius, 3)

func calculate_density(p_mass: float, p_volume: float) -> float:

	return (p_mass / p_volume) / 1000

func calculate_surface_gravity(p_mass: float, p_radius: float) -> float:

	return NyonUtils.GRAVITATIONAL_CONSTANT * p_mass / pow(p_radius, 2)

func calculate_surface_area(p_radius:float) -> float:

	return 4 * PI * pow(p_radius, 2)