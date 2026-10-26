extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const ENEMY_SCRIPT = preload("res://scripts/enemy.gd")

var status_label: Label
var health_label: Label
var inventory_label: Label
var scrap_count := 0

func _ready() -> void:
    _setup_input_map()
    _build_environment()
    _build_player()
    _build_loot(Vector3(2, 0.35, -4))
    _build_loot(Vector3(-5, 0.35, -8))
    _build_enemy(Vector3(5, 0, -12))
    _build_hud()
    if not OS.has_feature("android"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _setup_input_map() -> void:
    _add_key("move_forward", KEY_W)
    _add_key("move_backward", KEY_S)
    _add_key("move_left", KEY_A)
    _add_key("move_right", KEY_D)
    _add_key("jump", KEY_SPACE)
    _add_key("interact", KEY_E)
    _add_key("fire", KEY_F)
    _add_key("pause_mouse", KEY_ESCAPE)
    _add_button("jump", JOY_BUTTON_A)
    _add_button("interact", JOY_BUTTON_X)
    _add_button("fire", JOY_BUTTON_RIGHT_SHOULDER)
    _add_button("pause_mouse", JOY_BUTTON_START)
    _add_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
    _add_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
    _add_axis("move_forward", JOY_AXIS_LEFT_Y, -1.0)
    _add_axis("move_backward", JOY_AXIS_LEFT_Y, 1.0)

func _add_key(action: String, keycode: Key) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventKey.new()
    event.physical_keycode = keycode
    InputMap.action_add_event(action, event)

func _add_button(action: String, button: JoyButton) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventJoypadButton.new()
    event.button_index = button
    InputMap.action_add_event(action, event)

func _add_axis(action: String, axis: JoyAxis, value: float) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventJoypadMotion.new()
    event.axis = axis
    event.axis_value = value
    InputMap.action_add_event(action, event)

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.48, 0.52, 0.55)
    env.ambient_light_energy = 0.65
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    add_child(sun)

    _box("Wasteland ground", Vector3(0, -0.5, -10), Vector3(70, 1, 70), Color(0.34, 0.31, 0.25), true)
    _box("Cracked road", Vector3(0, 0.015, -10), Vector3(7, 0.03, 65), Color(0.19, 0.20, 0.19), false)
    _box("Gas station", Vector3(-8, 2, -12), Vector3(7, 4, 6), Color(0.38, 0.34, 0.28), true)
    _box("Broken canopy", Vector3(-8, 4.6, -9), Vector3(10, 0.35, 5), Color(0.43, 0.30, 0.20), true)
    _box("Canopy post 1", Vector3(-12, 2.2, -7.2), Vector3(0.25, 4.4, 0.25), Color(0.28, 0.27, 0.23), true)
    _box("Canopy post 2", Vector3(-4, 2.2, -7.2), Vector3(0.25, 4.4, 0.25), Color(0.28, 0.27, 0.23), true)
    _box("Collapsed wall", Vector3(8, 1.1, -7), Vector3(5, 2.2, 0.6), Color(0.37, 0.34, 0.29), true)
    _box("Rusty container", Vector3(11, 1, -17), Vector3(3, 2, 5), Color(0.35, 0.20, 0.13), true)
    _box("Concrete barrier", Vector3(-2, 0.55, -17), Vector3(3, 1.1, 0.8), Color(0.39, 0.38, 0.33), true)
    for pos in [Vector3(-15, 0, -19), Vector3(15, 0, -5), Vector3(17, 0, -23), Vector3(-17, 0, -2)]:
        _box("Dead tree trunk", pos + Vector3(0, 1.7, 0), Vector3(0.35, 3.4, 0.35), Color(0.22, 0.17, 0.12), true)

func _box(label: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
    var body := StaticBody3D.new()
    body.name = label
    body.position = pos
    var mesh := MeshInstance3D.new()
    var shape_mesh := BoxMesh.new()
    shape_mesh.size = size
    mesh.mesh = shape_mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.95
    mesh.material_override = mat
    body.add_child(mesh)
    if solid:
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        body.add_child(collision)
    add_child(body)

func _build_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 0, 2)
    player.set_script(PLAYER_SCRIPT)
    add_child(player)

func _build_loot(pos: Vector3) -> void:
    var loot := Area3D.new()
    loot.name = "Scrap cache"
    loot.position = pos
    loot.set_meta("loot_type", "scrap")
    loot.add_to_group("interactable")
    var mesh := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = Vector3(0.55, 0.45, 0.4)
    mesh.mesh = box_mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.72, 0.47, 0.16)
    mesh.material_override = mat
    loot.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.1, 1, 1)
    collision.shape = shape
    loot.add_child(collision)
    add_child(loot)

func _build_enemy(pos: Vector3) -> void:
    var enemy := CharacterBody3D.new()
    enemy.name = "Scavenger"
    enemy.position = pos
    enemy.set_script(ENEMY_SCRIPT)
    add_child(enemy)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "HUD"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(24, 24)
    panel.custom_minimum_size = Vector2(330, 110)
    layer.add_child(panel)
    var column := VBoxContainer.new()
    panel.add_child(column)
    var heading := Label.new()
    heading.text = "WASTELAND  //  FIELD STATUS"
    column.add_child(heading)
    health_label = Label.new()
    health_label.name = "Health"
    health_label.text = "HP  100 / 100"
    column.add_child(health_label)
    inventory_label = Label.new()
    inventory_label.text = "SCRAP  0"
    column.add_child(inventory_label)
    status_label = Label.new()
    status_label.position = Vector2(24, 150)
    status_label.size = Vector2(1850, 70)
    status_label.add_theme_font_size_override("font_size", 26)
    status_label.text = "WASD / LEFT STICK: Move   •   Mouse / RIGHT STICK: Look   •   E / X: Loot   •   F / RB: Fire"
    layer.add_child(status_label)

func add_scrap(amount: int) -> void:
    scrap_count += amount
    if is_instance_valid(inventory_label):
        inventory_label.text = "SCRAP  %d" % scrap_count

func update_health(amount: int) -> void:
    if is_instance_valid(health_label):
        health_label.text = "HP  %d / 100" % amount

func set_status(message: String) -> void:
    if is_instance_valid(status_label):
        status_label.text = message
