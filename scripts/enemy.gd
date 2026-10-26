extends CharacterBody3D

var health := 100
var player: Node3D
var attack_timer := 0.0

func _ready() -> void:
    add_to_group("enemies")
    var body_mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.38
    capsule.height = 1.65
    body_mesh.mesh = capsule
    body_mesh.position.y = 0.83
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.36, 0.20, 0.15)
    body_mesh.material_override = mat
    add_child(body_mesh)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.65
    collision.shape = shape
    collision.position.y = 0.83
    add_child(collision)
    player = get_tree().current_scene.get_node_or_null("Player")

func _physics_process(delta: float) -> void:
    attack_timer = maxf(0.0, attack_timer - delta)
    if not is_instance_valid(player):
        return
    var to_player := player.global_position - global_position
    to_player.y = 0
    var distance := to_player.length()
    if distance < 13.0 and distance > 1.6:
        var direction := to_player.normalized()
        velocity.x = direction.x * 2.2
        velocity.z = direction.z * 2.2
        look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0.0, 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 5.0 * delta)
    if not is_on_floor():
        velocity.y -= 9.8 * delta
    move_and_slide()

    if distance < 1.8 and attack_timer <= 0.0:
        attack_timer = 1.4
        if player.has_method("take_damage"):
            player.take_damage(8)

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
        get_tree().current_scene.set_status("Scavenger eliminated.")
