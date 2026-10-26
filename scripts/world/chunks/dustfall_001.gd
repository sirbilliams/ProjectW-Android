extends Node3D
## Worldspace 001: Dustfall, a quiet frontier settlement.
## One chunk is one self-contained scene/script; future chunks connect at road exits.
const CHUNK_ID := "dustfall_001"
const CHUNK_WIDTH := 96.0

func _ready() -> void:
    name = "Dustfall_001"
    _box("Dry earth", Vector3(0, -0.6, 0), Vector3(96, 1.2, 96), Color(0.47, 0.37, 0.25))
    _box("Main street", Vector3(0, 0.045, 0), Vector3(11, 0.09, 94), Color(0.39, 0.29, 0.19), false)
    _box("Cross road", Vector3(0, 0.05, 15), Vector3(70, 0.07, 7), Color(0.38, 0.28, 0.18), false)

    # The player begins inside the boarding house, facing the town's main street.
    _building("Boarding House", Vector3(-15, 0, 19), Vector3(12, 4.5, 10), Color(0.39, 0.29, 0.19), true)
    _building("Trading Post", Vector3(16, 0, 15), Vector3(12, 4.2, 9), Color(0.44, 0.30, 0.19))
    _building("Old Saloon", Vector3(-16, 0, -6), Vector3(13, 5.4, 12), Color(0.31, 0.23, 0.19))
    _building("Workshop", Vector3(17, 0, -9), Vector3(11, 3.8, 10), Color(0.32, 0.32, 0.29))
    _building("Clinic", Vector3(-15, 0, -27), Vector3(10, 3.9, 8), Color(0.42, 0.40, 0.33))
    _building("Water Station", Vector3(18, 0, -28), Vector3(9, 3.5, 8), Color(0.35, 0.34, 0.29))

    # Porch awnings and frontier details.
    for building in [
        Vector3(-15, 3.2, 12.6), Vector3(16, 3.1, 9.2),
        Vector3(-16, 3.5, 1.0), Vector3(17, 2.8, -2.8)
    ]:
        _box("Tin porch awning", building, Vector3(10, 0.2, 2.5), Color(0.27, 0.26, 0.24), false)

    _box("Water tower platform", Vector3(29, 4.5, -24), Vector3(6, 0.45, 6), Color(0.26, 0.22, 0.17))
    for x in [26.5, 31.5]:
        for z in [-26.5, -21.5]:
            _box("Tower support", Vector3(x, 2.25, z), Vector3(0.35, 4.5, 0.35), Color(0.27, 0.22, 0.18))
    _box("Water tank", Vector3(29, 6.4, -24), Vector3(5, 3.5, 5), Color(0.27, 0.33, 0.33))
    _box("Bulletin board", Vector3(6.3, 1.3, 4), Vector3(2.4, 2.6, 0.35), Color(0.42, 0.28, 0.15))
    _box("Town sign", Vector3(0, 2.5, 35), Vector3(5.5, 1.2, 0.3), Color(0.38, 0.25, 0.13))
    _box("Old truck", Vector3(9, 0.8, -18), Vector3(4, 1.6, 2), Color(0.30, 0.23, 0.18))

    for pos in [
        Vector3(-35, 0, 27), Vector3(34, 0, 32), Vector3(-37, 0, -35),
        Vector3(33, 0, -39), Vector3(-29, 0, -40), Vector3(39, 0, 2)
    ]:
        _dead_tree(pos)

    # Road exits remain open for later streamed neighboring chunks.
    _marker("NORTH ROAD — future chunk", Vector3(0, 0, -44), Color(0.72, 0.55, 0.23))
    _marker("SOUTH ROAD — future chunk", Vector3(0, 0, 44), Color(0.72, 0.55, 0.23))

func _building(title: String, pos: Vector3, size: Vector3, color: Color, open_front: bool = false) -> void:
    var cx := pos.x
    var cz := pos.z
    var half_x := size.x / 2.0
    var half_z := size.z / 2.0
    var height := size.y
    _box(title + " floor", Vector3(cx, 0.13, cz), Vector3(size.x, 0.25, size.z), Color(0.34, 0.25, 0.17))
    _box(title + " left wall", Vector3(cx - half_x, height/2.0, cz), Vector3(0.35, height, size.z), color)
    _box(title + " right wall", Vector3(cx + half_x, height/2.0, cz), Vector3(0.35, height, size.z), color)
    _box(title + " back wall", Vector3(cx, height/2.0, cz + half_z), Vector3(size.x, height, 0.35), color)
    # Every structure has an open doorway on the street-facing frontage.
    var front := cz - half_z if cz > 0 else cz + half_z
    var wall_left := cx - (half_x + 1.5) / 2.0
    var wall_right := cx + (half_x + 1.5) / 2.0
    _box(title + " frontage left", Vector3(wall_left, height/2.0, front), Vector3(half_x - 1.5, height, 0.35), color)
    _box(title + " frontage right", Vector3(wall_right, height/2.0, front), Vector3(half_x - 1.5, height, 0.35), color)
    _box(title + " door lintel", Vector3(cx, height - 0.55, front), Vector3(3.0, 1.1, 0.35), color)
    _box(title + " roof", Vector3(cx, height + 0.18, cz), Vector3(size.x + 0.8, 0.35, size.z + 0.8), Color(0.23, 0.22, 0.20))
    _box(title + " false-front", Vector3(cx, height + 0.95, front), Vector3(size.x + 0.5, 1.4, 0.28), color)
    if open_front:
        _box("Bed frame", Vector3(cx - 3.0, 0.65, cz + 1.4), Vector3(2.1, 0.7, 3.1), Color(0.23, 0.17, 0.14))
        _box("Bed mattress", Vector3(cx - 3.0, 1.08, cz + 1.4), Vector3(1.9, 0.18, 2.8), Color(0.52, 0.49, 0.38))
        _box("Side table", Vector3(cx + 0.5, 0.68, cz + 2.5), Vector3(1.3, 1.3, 1.0), Color(0.28, 0.20, 0.13))

func _dead_tree(pos: Vector3) -> void:
    _box("Dead tree", pos + Vector3(0, 2.1, 0), Vector3(0.4, 4.2, 0.4), Color(0.25, 0.19, 0.14))

func _marker(title: String, position3d: Vector3, color: Color) -> void:
    var post := Node3D.new()
    post.name = title
    post.position = position3d
    add_child(post)
    _box(title + " post", position3d + Vector3(6, 1.2, 0), Vector3(0.2, 2.4, 0.2), color, false)

func _box(title: String, position3d: Vector3, size: Vector3, color: Color, solid: bool = true) -> void:
    var body := StaticBody3D.new()
    body.name = title
    body.position = position3d
    var mesh := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = size
    mesh.mesh = shape
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.95
    mesh.material_override = material
    body.add_child(mesh)
    if solid:
        var collider := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = size
        collider.shape = box
        body.add_child(collider)
    add_child(body)
