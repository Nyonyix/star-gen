extends Control

@onready var main_menu: VBoxContainer = %MainMenu
@onready var generate_dialog: PanelContainer = %GenerateDialog
@onready var seed_input: LineEdit = %SeedInput
@onready var count_spinbox: SpinBox = %CountSpinBox
@onready var progress_par: ProgressBar = %ProgressBar
@onready var status_label: Label = %StatusLabel
@onready var start_button: Button = %StartButton
@onready var view_button: Button = %ViewButton
@onready var file_dialog: FileDialog = %LoadFileDialog
@onready var generate_button: Button = %GenerateButton
@onready var load_button: Button = %LoadButton
@onready var back_button: Button = %BackButton

var is_generating: bool = false
var generation_done: bool = false
var seed: int

func _ready() -> void:

	generate_button.pressed.connect(_on_generate_pressed)
	load_button.pressed.connect(_on_load_pressed)
	start_button.pressed.connect(_on_start_generation)
	view_button.pressed.connect(_on_view_galaxy)
	back_button.pressed.connect(_on_back_pressed)
	file_dialog.file_selected.connect(_on_file_selected)

func _process(delta: float) -> void:

	if not is_generating:
		return
	
	var more: bool = StarGenGameData.generate_step()
	var idx: int = StarGenGameData.gen_index
	var cnt: int = StarGenGameData.gen_count

	progress_par.value = float(idx) / float(cnt)
	status_label.text = "Generating %d / %d..." % [idx, cnt]

	if not more:
		StarGenGameData.to_json(str("galaxy_", seed, ".json"))
		is_generating = false
		generation_done = true
		view_button.disabled = false
		start_button.disabled = true
		status_label.text = "Done, %d systems generated" % StarGenGameData.system_count()

func _on_generate_pressed() -> void:

	main_menu.visible = false
	generate_dialog.visible = true
	start_button.disabled = false
	view_button.disabled = true
	generation_done = false

func _on_load_pressed() -> void:

	file_dialog.popup_centered()

func _on_start_generation() -> void:

	seed = int(seed_input.text) if seed_input.text.is_valid_int() else RandomNumberGenerator.new().randi()
	var count: int = int(count_spinbox.value)

	StarGenGameData.start_generation(seed, count)
	is_generating = true
	generation_done = false

func _on_view_galaxy() -> void:

	get_tree().change_scene_to_file("res://GalaxyView.tscn")

func _on_back_pressed() -> void:

	generate_dialog.visible = false
	main_menu.visible = true

func _on_file_selected(p_path: String) -> void:

	StarGenGameData.from_json(p_path)
	get_tree().change_scene_to_file("res://GalaxyView.tscn")
