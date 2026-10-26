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
const CALDER_LINES := [
    "CALDER: Hey. You're awake. Easy now. Don't try getting up too quick.",
    "CALDER: Found you down in the Pit while I was scavenging for parts. Saw your hand beneath a pile of rusted scrap.",
    "CALDER: Dragged you out myself. Didn't expect you'd make it through the night.",
    "CALDER: You're in Dustfall. Name's Calder, but most folks call me Old Cal.",
    "CALDER: The Pit's no place to be lying unconscious. Once you can walk, get some food over at the saloon. Mara keeps that place running."
]
const MARA_LINES := [
    "MARA: Well, you're the one Old Cal pulled out of the Pit. He hasn't stopped talking about it.",
    "MARA: Welcome to the Dustfall canteen. Coffee's weak, stew's questionable, but nobody leaves hungry.",
    "MARA: If you're going to stay awhile, lend a hand. Ask around town and see what needs fixing."
]
var active_dialogue: Array = []
var active_speaker := ""
var world_minutes := 8.0 * 60.0
var world_day := 1
const GAME_MINUTES_PER_REAL_SECOND := 1.0
var sun_light: DirectionalLight3D
var sky_material: ProceduralSkyMaterial
var world_environment: WorldEnvironment
var clock_label: Label
var sky_timer := 0.0
var time_transition_active := false


func _ready() -> void:
    _setup_input_map()
    _build_environment()
    _build_player()
    _spawn_calder()
    _spawn_mara()
    _build_loot(Vector3(-12, 0.35, 18))
    _build_loot(Vector3(7, 0.35, -5))
    _build_bed_interaction()
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
    _add_key("wait", KEY_T)
    _add_button("wait", JOY_BUTTON_Y)
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
    sky_material = ProceduralSkyMaterial.new()
    sky_material.use_debanding = true
    env.sky.sky_material = sky_material
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.48, 0.52, 0.55)
    env.ambient_light_energy = 0.65
    world.environment = env
    add_child(world)
    world_environment = world

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    add_child(sun)
    sun_light = sun
    _update_sky()

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

func _spawn_calder() -> void:
    var calder := _make_npc("Calder", Vector3(-13.0, 0.0, 20.0), Color(0.33, 0.32, 0.27))
    _npc_part(calder, "Chair back", Vector3(0, 1.15, 0.36), Vector3(1.15, 1.7, 0.18), Color(0.3, 0.21, 0.13))
    _npc_part(calder, "Chair seat", Vector3(0, 0.53, 0), Vector3(1.2, 0.18, 1), Color(0.32, 0.22, 0.14))
    for x in [-0.53, 0.53]:
        _npc_part(calder, "Rocking runner", Vector3(x, 0.12, 0), Vector3(0.12, 0.18, 1.55), Color(0.23, 0.17, 0.12))
    var rocking := create_tween().set_loops()
    rocking.tween_property(calder, "rotation:z", 0.03, 1.7).set_trans(Tween.TRANS_SINE)
    rocking.tween_property(calder, "rotation:z", -0.03, 1.7).set_trans(Tween.TRANS_SINE)

func _spawn_mara() -> void:
    # Inside the saloon / canteen, facing its doorway toward main street.
    _make_npc("Mara", Vector3(-13.5, 0.0, -7.0), Color(0.36, 0.25, 0.20))

func _make_npc(npc_name: String, pos: Vector3, coat_color: Color) -> Area3D:
    var npc := Area3D.new()
    npc.name = npc_name
    npc.position = pos
    npc.add_to_group("dialogue_npc")
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.height = 2.0
    capsule.radius = 0.46
    collider.shape = capsule
    collider.position.y = 1.0
    npc.add_child(collider)
    _npc_part(npc, "Coat", Vector3(0, 1.18, 0), Vector3(0.72, 1.0, 0.45), coat_color)
    _npc_part(npc, "Head", Vector3(0, 1.94, 0), Vector3(0.48, 0.48, 0.46), Color(0.52, 0.4, 0.31))
    _npc_part(npc, "Boots", Vector3(0, 0.37, 0), Vector3(0.55, 0.74, 0.32), Color(0.19, 0.17, 0.15))
    add_child(npc)
    return npc

func _npc_part(parent: Node3D, label: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var part := MeshInstance3D.new()
    part.name = label
    part.position = pos
    var mesh := BoxMesh.new()
    mesh.size = size
    part.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    part.material_override = material
    parent.add_child(part)

func _build_dialogue() -> void:
    var layer := CanvasLayer.new()
    layer.name = "Dialogue"
    layer.layer = 5
    add_child(layer)
    dialogue_panel = PanelContainer.new()
    dialogue_panel.visible = false
    dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    dialogue_panel.offset_left = 64.0
    dialogue_panel.offset_right = -64.0
    dialogue_panel.offset_top = -250.0
    dialogue_panel.offset_bottom = -30.0
    layer.add_child(dialogue_panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 14)
    dialogue_panel.add_child(content)
    var heading := Label.new()
    heading.text = "DUSTFALL / CONVERSATION"
    heading.add_theme_font_size_override("font_size", 18)
    content.add_child(heading)
    dialogue_text = Label.new()
    dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_text.custom_minimum_size = Vector2(0, 90)
    dialogue_text.add_theme_font_size_override("font_size", 23)
    content.add_child(dialogue_text)
    dialogue_hint = Label.new()
    dialogue_hint.text = "E / X : Continue"
    content.add_child(dialogue_hint)

func start_dialogue(speaker: String = "Calder") -> void:
    if intro_active or dialogue_active:
        return
    active_speaker = speaker
    active_dialogue = MARA_LINES if speaker == "Mara" else CALDER_LINES
    dialogue_page = 0
    dialogue_active = true
    dialogue_panel.visible = true
    dialogue_text.text = active_dialogue[0]
    dialogue_hint.text = "E / X : Continue"

func advance_dialogue() -> void:
    if not dialogue_active:
        return
    dialogue_page += 1
    if dialogue_page >= active_dialogue.size():
        dialogue_active = false
        dialogue_panel.visible = false
        set_status("OBJECTIVE: Explore Dustfall. Find Mara at the saloon / canteen.")
        return
    dialogue_text.text = active_dialogue[dialogue_page]
    if dialogue_page == active_dialogue.size() - 1:
        dialogue_hint.text = "E / X : Finish"

func _build_bed_interaction() -> void:
    var bed := Area3D.new()
    bed.name = "SleepBed"
    bed.add_to_group("interactable")
    bed.set_meta("action", "sleep")
    bed.position = Vector3(-17.2, 1.15, 21)
    var collider := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(2.4, 0.9, 3)
    collider.shape = box
    bed.add_child(collider)
    add_child(bed)

func _process(delta: float) -> void:
    if intro_active or dialogue_active or time_transition_active:
        return
    world_minutes += delta * GAME_MINUTES_PER_REAL_SECOND
    while world_minutes >= 1440.0:
        world_minutes -= 1440.0
        world_day += 1
    sky_timer += delta
    if sky_timer >= 0.25:
        sky_timer = 0.0
        _update_sky()
        _update_clock()

func _update_clock() -> void:
    if clock_label == null:
        return
    var hours := int(world_minutes) / 60
    var minutes := int(world_minutes) % 60
    clock_label.text = "DAY %d  %02d:%02d  |  T / Y : Wait 1 hour" % [world_day, hours, minutes]

func _update_sky() -> void:
    # Procedural colors avoid expensive skybox textures on Android.
    var hour := world_minutes / 60.0
    var daylight := clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)
    var twilight := clampf(1.0 - absf(hour - 6.0) / 2.0, 0.0, 1.0)
    twilight = maxf(twilight, clampf(1.0 - absf(hour - 18.0) / 2.0, 0.0, 1.0))
    var night_top := Color(0.015, 0.024, 0.065)
    var day_top := Color(0.26, 0.37, 0.48)
    var night_horizon := Color(0.045, 0.051, 0.085)
    var day_horizon := Color(0.65, 0.50, 0.34)
    sky_material.sky_top_color = night_top.lerp(day_top, daylight)
    sky_material.sky_horizon_color = night_horizon.lerp(day_horizon, daylight).lerp(Color(0.78, 0.32, 0.18), twilight * 0.45)
    sky_material.ground_bottom_color = Color(0.13, 0.10, 0.08)
    sky_material.ground_horizon_color = Color(0.24, 0.19, 0.15).lerp(day_horizon, daylight)
    sun_light.rotation_degrees = Vector3(-12.0 - 156.0 * (hour / 24.0), -28.0, 0.0)
    sun_light.light_energy = 0.08 + 1.05 * daylight
    sun_light.light_color = Color(1.0, 0.58, 0.34).lerp(Color(1.0, 0.96, 0.85), daylight)
    world_environment.environment.ambient_light_energy = 0.2 + 0.45 * daylight

func wait_one_hour() -> void:
    if intro_active or dialogue_active or time_transition_active:
        return
    _advance_time(60.0, "You wait an hour. The settlement carries on around you.")

func sleep_in_bed() -> void:
    if intro_active or dialogue_active or time_transition_active:
        return
    var morning := 7.0 * 60.0
    var passed := fposmod(morning - world_minutes, 1440.0)
    if passed < 60.0:
        passed += 1440.0
    _advance_time(passed, "You wake rested as morning light reaches the room.")

func _advance_time(minutes: float, message: String) -> void:
    time_transition_active = true
    var layer := CanvasLayer.new()
    layer.layer = 15
    add_child(layer)
    var fade := ColorRect.new()
    fade.color = Color(0.015, 0.014, 0.014, 0)
    fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(fade)
    var fade_in := create_tween()
    fade_in.tween_property(fade, "color:a", 1.0, 0.32)
    await fade_in.finished
    world_minutes += minutes
    while world_minutes >= 1440.0:
        world_minutes -= 1440.0
        world_day += 1
    _update_sky()
    _update_clock()
    var fade_out := create_tween()
    fade_out.tween_property(fade, "color:a", 0.0, 0.45)
    await fade_out.finished
    layer.queue_free()
    time_transition_active = false
    set_status(message)

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
    clock_label = Label.new()
    column.add_child(clock_label)
    _update_clock()
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
    shade.color = Color(0.025, 0.023, 0.02, 1.0)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(shade)
    var words := Label.new()
    words.text = "DUSTFALL\n\nA wooden chair creaks beside you.\nSomeone clears his throat.\n\n'Hey. You're awake.'"
    words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    words.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    words.add_theme_font_size_override("font_size", 26)
    words.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.add_child(words)
    await get_tree().create_timer(2.6).timeout
    if not is_instance_valid(shade):
        return
    var player := get_node_or_null("Player")
    var camera: Camera3D = player.get_node_or_null("FirstPersonCamera")
    camera.rotation.x = -0.25
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(shade, "modulate:a", 0.0, 2.0)
    await tween.finished
    overlay.queue_free()
    intro_active = false
    start_dialogue("Calder")
    while dialogue_active:
        await get_tree().process_frame
    var rising := create_tween()
    rising.set_parallel(true)
    rising.tween_property(camera, "position:y", 1.55, 2.0)
    rising.tween_property(camera, "rotation:x", 0.0, 2.0)
    await rising.finished
    set_status("OBJECTIVE: Leave the boarding house. Mara works at the saloon.")
