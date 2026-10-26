extends CanvasLayer
## Controller/touch-friendly pause and settings for the prototype.
signal settings_changed
var open := false
var root_panel: Control
var page: VBoxContainer
var settings: Dictionary = {
    "master": 90.0, "music": 75.0, "effects": 85.0,
    "fov": 75.0, "mouse": 1.0, "stick": 1.0, "deadzone": 0.16,
    "invert_y": false, "vsync": true, "shadows": true, "fps": 60
}
const SAVE_PATH := "user://options.cfg"

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 20
    _load_settings()
    _apply_settings()
    _build_shell()
    _show_home()

func _build_shell() -> void:
    root_panel = Control.new()
    root_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_panel.visible = false
    root_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(root_panel)
    var dark := ColorRect.new()
    dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dark.color = Color(0.015, 0.02, 0.02, 0.91)
    root_panel.add_child(dark)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_panel.add_child(center)
    var card := PanelContainer.new()
    card.custom_minimum_size = Vector2(780, 670)
    center.add_child(card)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 20)
    card.add_child(margin)
    page = VBoxContainer.new()
    page.add_theme_constant_override("separation", 13)
    margin.add_child(page)

func _clear_page() -> void:
    for child in page.get_children():
        page.remove_child(child)
        child.queue_free()

func _title(value: String) -> void:
    var title := Label.new()
    title.text = value
    title.add_theme_font_size_override("font_size", 31)
    page.add_child(title)

func _button(text: String, callback: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size.y = 51
    b.pressed.connect(callback)
    page.add_child(b)
    return b

func _show_home() -> void:
    _clear_page()
    _title("PROJECT WASTELAND  /  PAUSED")
    _caption("DUSTFALL  •  ALPHA 3")
    var resume := _button("Resume game", func(): toggle())
    _button("Settings", _show_settings)
    _button("Controls", _show_controls)
    _button("Return to title (restart prototype)", func(): _restart())
    _button("Quit game", func(): get_tree().quit())
    resume.grab_focus()

func _show_settings() -> void:
    _clear_page()
    _title("SETTINGS")
    var tabs := HBoxContainer.new()
    page.add_child(tabs)
    for tab_name in ["Audio", "Video", "Controls"]:
        var b := Button.new()
        b.text = tab_name
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(func(): _show_settings_tab(tab_name))
        tabs.add_child(b)
    _show_settings_header("Audio")

func _show_settings_tab(tab: String) -> void:
    _show_settings_header(tab)

func _show_settings_header(tab: String) -> void:
    _clear_page()
    _title("SETTINGS  /  " + tab.to_upper())
    var tabs := HBoxContainer.new()
    page.add_child(tabs)
    for t in ["Audio", "Video", "Controls"]:
        var b := Button.new()
        b.text = t
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(func(): _show_settings_header(t))
        tabs.add_child(b)
    if tab == "Audio":
        _slider("Master volume", "master", 0.0, 100.0, 1.0)
        _slider("Music volume", "music", 0.0, 100.0, 1.0)
        _slider("Effects volume", "effects", 0.0, 100.0, 1.0)
        _caption("Music and effects buses are ready for future audio assets.")
    elif tab == "Video":
        _select_fps()
        _check("V-Sync", "vsync")
        _check("Dynamic sun shadows", "shadows")
        _caption("Android may override V-Sync and frame-rate preferences.")
    else:
        _slider("Field of view", "fov", 60.0, 100.0, 1.0)
        _slider("Mouse sensitivity", "mouse", 0.3, 2.5, 0.1)
        _slider("Right-stick sensitivity", "stick", 0.3, 2.5, 0.1)
        _slider("Stick deadzone", "deadzone", 0.05, 0.35, 0.01)
        _check("Invert look Y", "invert_y")
    var back := _button("Save & Back", _show_home)
    back.grab_focus()

func _slider(title: String, key: String, low: float, high: float, step: float) -> void:
    var line := HBoxContainer.new()
    page.add_child(line)
    var label := Label.new()
    label.text = title
    label.custom_minimum_size.x = 240
    line.add_child(label)
    var slider := HSlider.new()
    slider.min_value = low
    slider.max_value = high
    slider.step = step
    slider.value = float(settings[key])
    slider.custom_minimum_size.x = 280
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    line.add_child(slider)
    var amount := Label.new()
    amount.custom_minimum_size.x = 65
    amount.text = "%.2f" % float(settings[key]) if step < 0.1 else "%.1f" % float(settings[key])
    line.add_child(amount)
    slider.value_changed.connect(func(value: float):
        settings[key] = value
        amount.text = "%.2f" % value if step < 0.1 else "%.1f" % value
        _apply_settings()
        _save_settings()
    )

func _check(title: String, key: String) -> void:
    var check := CheckBox.new()
    check.text = title
    check.button_pressed = bool(settings[key])
    check.custom_minimum_size.y = 48
    check.toggled.connect(func(value: bool):
        settings[key] = value
        _apply_settings()
        _save_settings()
    )
    page.add_child(check)

func _select_fps() -> void:
    var line := HBoxContainer.new()
    page.add_child(line)
    var label := Label.new()
    label.text = "FPS limit"
    label.custom_minimum_size.x = 240
    line.add_child(label)
    var selection := OptionButton.new()
    for value in [30, 45, 60, 120, 0]:
        selection.add_item("Unlimited" if value == 0 else str(value) + " FPS", value)
    for idx in range(selection.item_count):
        if selection.get_item_id(idx) == int(settings["fps"]):
            selection.select(idx)
    selection.item_selected.connect(func(index: int):
        settings["fps"] = selection.get_item_id(index)
        _apply_settings()
        _save_settings()
    )
    line.add_child(selection)

func _show_controls() -> void:
    _clear_page()
    _title("CONTROLS")
    for line in [
        "Move     WASD / Left stick",
        "Look     Mouse / Right stick",
        "Interact / dialogue     E / X",
        "Jump     Space / A",
        "Wait one hour     T / Select (Back)",
        "Pause and settings     Esc / Start",
        "Fire     F / Right shoulder"
    ]:
        _caption(line)
    var back := _button("Back", _show_home)
    back.grab_focus()

func _caption(message: String) -> void:
    var label := Label.new()
    label.text = message
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    page.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause_menu") and not event.is_echo():
        get_viewport().set_input_as_handled()
        toggle()

func toggle() -> void:
    open = not open
    root_panel.visible = open
    get_tree().paused = open
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED
    if open:
        _show_home()

func _restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _apply_settings() -> void:
    _ensure_audio_bus("Music")
    _ensure_audio_bus("SFX")
    AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.001, float(settings["master"]) / 100.0)))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(maxf(0.001, float(settings["music"]) / 100.0)))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(maxf(0.001, float(settings["effects"]) / 100.0)))
    Engine.max_fps = int(settings["fps"])
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(settings["vsync"]) else DisplayServer.VSYNC_DISABLED)
    var parent_world := get_parent()
    if parent_world != null:
        var sun: DirectionalLight3D = parent_world.get("sun_light")
        if sun != null:
            sun.shadow_enabled = bool(settings["shadows"])
    settings_changed.emit()

func _ensure_audio_bus(name: String) -> void:
    if AudioServer.get_bus_index(name) == -1:
        AudioServer.add_bus()
        AudioServer.set_bus_name(AudioServer.bus_count - 1, name)

func _save_settings() -> void:
    var cfg := ConfigFile.new()
    for key in settings:
        cfg.set_value("settings", key, settings[key])
    cfg.save(SAVE_PATH)

func _load_settings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) != OK:
        return
    for key in settings:
        if cfg.has_section_key("settings", key):
            settings[key] = cfg.get_value("settings", key)
