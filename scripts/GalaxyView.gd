extends Node2D

@onready var cam: Camera2D = $Camera2D
@onready var back_button: Button = %BackButton

var dragging: bool = false
var drag_mouse: Vector2
var drag_cam_start: Vector2

const CLICK_RADIUS: float = 10.0

func _ready() -> void:

    back_button.pressed.connect(_on_back)
    _spawn_system_nodes()
    _fit_camera()

func _spawn_system_nodes() -> void:

    for i in range(StarGenGameData.system_count()):
        var sys: SolarSystem = StarGenGameData.systems[i]

        var area: Area2D = Area2D.new()
        area.position = sys.position
        area.name = "System_%d" % sys.id

        var shape: CollisionShape2D = CollisionShape2D.new()
        var circle: CircleShape2D = CircleShape2D.new()
        circle.radius = CLICK_RADIUS
        shape.shape = circle
        area.add_child(shape)

        area.input_event.connect(_on_system_clicked.bind(i))
        add_child(area)

func _fit_camera() -> void:

    var vp: Vector2 = get_viewport().get_visible_rect().size
    var scale: float = min(vp.x, vp.y) / StarGenGameData.GALAXY_SIZE * 0.85
    cam.zoom = Vector2(scale, scale)
    cam.position = Vector2(StarGenGameData.GALAXY_SIZE, StarGenGameData.GALAXY_SIZE) * 0.5

func _draw() -> void:

    draw_rect(Rect2(Vector2.ZERO, Vector2.ONE * StarGenGameData.GALAXY_SIZE), Color.GRAY, false, 1.0)

    for sys in StarGenGameData.systems:
        var color: Color = Color.WHITE
        
        if sys.stars.size() > 0:
            color = NyonUtils.convert_kelvin_to_rgb(int(sys.stars[0].temperature))
        
        draw_circle(sys.position, 4.0, color)

func _input(event: InputEvent) -> void:

    if event is InputEventMouseButton:
        match event.button_index:
            MOUSE_BUTTON_WHEEL_UP:
                cam.zoom *= 1.1
            MOUSE_BUTTON_WHEEL_DOWN:
                cam.zoom /= 1.1
            MOUSE_BUTTON_MIDDLE:
                if event.pressed:
                    dragging = true
                    drag_mouse = event.position
                    drag_cam_start = cam.position
                else:
                    dragging = false

    elif event is InputEventMouseMotion and dragging:
        cam.position = drag_cam_start - (event.position - drag_mouse) / cam.zoom

func _on_system_clicked(viewport: Viewport, event: InputEvent, _shape_idx: int, index: int) -> void:

    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        StarGenGameData.selected_system_index = index
        get_tree().change_scene_to_file("res://SystemView.tscn")

func _on_back() -> void:

    StarGenGameData.systems.clear()
    get_tree().change_scene_to_file("res://Main.tscn")
