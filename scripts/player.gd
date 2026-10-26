extends CharacterBody3D

const WALK_SPEED := 5.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.0022
const GAMEPAD_LOOK_SPEED := 2.4
const FIRE_DISTANCE := 45.0

var health := 100
var pitch := 0.0
var fire_cooldown := 0.0
var camera: Camera3D
var ray: RayCast3D

func _ready() -> void:
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.32
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    add_child(collision)

    camera = Camera3D.new()
    camera.name = "FirstPersonCamera"
    camera.position.y = 1.55
    camera.current = true
    add_child(camera)

    ray = RayCast3D.new()
    ray.name = "InteractionRay"
    ray.target_position = Vector3(0, 0, -3)
    ray.collide_with_areas = true
    camera.add_child(ray)

    var weapon := MeshInstance3D.new()
    weapon.name = "PlaceholderWeapon"
    var weapon_mesh := BoxMesh.new()
    weapon_mesh.size = Vector3(0.18, 0.16, 0.55)
    weapon.mesh = weapon_mesh
    weapon.position = Vector3(0.28, -0.25, -0.55)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.16, 0.17, 0.16)
    weapon.material_override = mat
    camera.add_child(weapon)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        pitch = clampf(pitch - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-85), deg_to_rad(85))
        camera.rotation.x = pitch
    elif event.is_action_pressed("pause_mouse") and not OS.has_feature("android"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
    elif event is InputEventMouseButton and event.pressed and not OS.has_feature("android"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    if not is_on_floor():
        velocity.y -= 9.8 * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = JUMP_VELOCITY

    var move_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
    if direction.length_squared() > 0.001:
        velocity.x = direction.x * WALK_SPEED
        velocity.z = direction.z * WALK_SPEED
    else:
        velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED * 5.0 * delta)

    _read_gamepad_look(delta)
    move_and_slide()

    if Input.is_action_just_pressed("interact"):
        _interact()
    if Input.is_action_just_pressed("fire"):
        _fire()

func _read_gamepad_look(delta: float) -> void:
    for device in Input.get_connected_joypads():
        var x := Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
        var y := Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)
        if absf(x) > 0.16 or absf(y) > 0.16:
            rotate_y(-x * GAMEPAD_LOOK_SPEED * delta)
            pitch = clampf(pitch - y * GAMEPAD_LOOK_SPEED * delta, deg_to_rad(-85), deg_to_rad(85))
            camera.rotation.x = pitch
            break

func _interact() -> void:
    ray.target_position = Vector3(0, 0, -3)
    ray.force_raycast_update()
    if not ray.is_colliding():
        _status("Nothing close enough to interact with.")
        return
    var target := ray.get_collider()
    if target is Node and target.is_in_group("interactable"):
        if target.get_meta("loot_type", "") == "scrap":
            get_tree().current_scene.add_scrap(randi_range(2, 8))
            target.queue_free()
            _status("Scrap recovered.")
            return
    _status("No useful interaction here.")

func _fire() -> void:
    if fire_cooldown > 0.0:
        return
    fire_cooldown = 0.25
    ray.target_position = Vector3(0, 0, -FIRE_DISTANCE)
    ray.force_raycast_update()
    var target := ray.get_collider()
    if target is Node and target.is_in_group("enemies"):
        target.take_damage(34)
        _status("Shot fired. Target hit.")
    else:
        _status("Shot fired. No hit.")

func _status(message: String) -> void:
    var main := get_tree().current_scene
    if main.has_method("set_status"):
        main.set_status(message)

func take_damage(amount: int) -> void:
    health = maxi(0, health - amount)
    if health <= 0:
        health = 100
        global_position = Vector3(0, 0, 2)
        velocity = Vector3.ZERO
        _status("You were downed. Respawned at the roadside.")
    var main := get_tree().current_scene
    if main.has_method("update_health"):
        main.update_health(health)
