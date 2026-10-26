extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const DUSTFALL_CHUNK = preload("res://scripts/world/chunks/dustfall_001.gd")

var status_label: Label
var health_label: Label
var inventory_label: Label
var scrap_count := 0
var intro_active := true
var dialogue_active := false
var dialogue_page := 0
var dialogue_panel: PanelContainer
var dialogue_text: Label
var dialogue_hint: Label
const MARA_LINES := [
    "MARA: Easy there, stranger. You're safe. Name's Mara. I fix what this town can't afford to replace.",
    "MARA: Found you unconscious on the south road, half buried in dust. Brought you here before the scavengers did.",
    "MARA: This is Dustfall. We have clean water when the purifier cooperates, and a roof when the wind is kind.",
    "MARA: Take a look around. When you're ready, meet me near the workshop. We could use another pair of hands."
]

func _ready() -> void:
    _setup_input_map()
    _build_environment()
    _build_player()
    _spawn_mara()
    _build_loot(Vector3(-12, 0.35, 18))
    _build_loot(Vector3(7, 0.35, -5))
    _build_hud()
    _build_dialogue()
    _show_wake_up_intro()
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

    var starting_chunk := Node3D.new()
    starting_chunk.set_script(DUSTFALL_CHUNK)
    add_child(starting_chunk)

func _build_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(-15, 0.35, 20)
    player.rotation.y = -PI / 2.0
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
    heading.text = "DUSTFALL  //  FIELD STATUS"
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
    status_label.text = "You wake in a strange room. Outside, Dustfall is quiet."
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

func _show_wake_up_intro() -> void:
    var overlay := CanvasLayer.new()
    overlay.name = "WakeUpOverlay"
    overlay.layer = 10
    add_child(overlay)
    var shade := ColorRect.new()
    shade.color = Color(0.035, 0.028, 0.023, 1.0)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(shade)
    var words := Label.new()
    words.text = "DUSTFALL\n\nThe wind slips through the window.\nSomewhere outside, an old bell rings.\n\nYou open your eyes."
    words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    words.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    words.add_theme_font_size_override("font_size", 27)
    words.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.add_child(words)
    await get_tree().create_timer(3.6).timeout
    if not is_instance_valid(shade):
        return
    var tween := create_tween()
    tween.tween_property(shade, "modulate:a", 0.0, 2.6)
    await tween.finished
    overlay.queue_free()
    set_status("Dustfall, a quiet frontier settlement. Find out where you are.")
