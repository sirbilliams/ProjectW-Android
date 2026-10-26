extends Node3D
## Chunk 001: DUSTFALL. 96 x 96 meter settlement on ruins of a pre-collapse highway.
## Axis convention: north is -Z. Main street runs N/S along X=0.
const CHUNK_ID := "dustfall_001"
const CHUNK_WIDTH := 96.0

const SAND := Color(0.43, 0.35, 0.25)
const CONCRETE := Color(0.34, 0.35, 0.34)
const RUST := Color(0.36, 0.21, 0.13)
const METAL := Color(0.26, 0.29, 0.28)
const WOOD := Color(0.34, 0.25, 0.18)

func _ready() -> void:
    name = "Dustfall_001"
    _box("Dusty terrain", Vector3(0, -0.65, 0), Vector3(96, 1.3, 96), SAND)
    _box("Former highway asphalt", Vector3(0, 0.025, 0), Vector3(11, 0.05, 96), Color(0.19, 0.20, 0.19), false)
    _box("Old intersection", Vector3(0, 0.03, 12), Vector3(76, 0.055, 7), Color(0.23, 0.23, 0.21), false)

    # All doors face the central roadway; walk through any open door.
    _building("Boarding House", -15, 19, 11, 10, 4.6, WOOD, true)
    _building("Salvage Trading Post", 16, 17, 11, 9, 4.3, RUST)
    _building("Generator Saloon", -16, -7, 12, 12, 5.0, WOOD)
    _building("Repair Workshop", 17, -10, 11, 10, 4.1, METAL)
    _building("Makeshift Clinic", -16, -28, 11, 9, 3.9, CONCRETE)
    _building("Water Purifier", 17, -29, 10, 9, 3.8, METAL)

    _canteen_interior()
    _wrecked_bus(Vector3(32, 0, 8))
    _truck(Vector3(9, 0, -20))
    _collapsed_overpass()
    _water_tower()
    _perimeter()
    _small_details()

    _sign("North exit marker", Vector3(7, 0, -44))
    _sign("South exit marker", Vector3(7, 0, 44))

func _building(label: String, x: float, z: float, width: float, depth: float, height: float, wall_color: Color, bedroom: bool = false) -> void:
    var center := Vector3(x, 0, z)
    var facing_right := x < 0.0 # West buildings face east (+X); east buildings face west (-X)
    var inner_side := x + width * 0.5 if facing_right else x - width * 0.5
    var outer_side := x - width * 0.5 if facing_right else x + width * 0.5
    _box(label + " floor", center + Vector3(0, 0.14, 0), Vector3(width, 0.28, depth), CONCRETE)
    _box(label + " rear wall", Vector3(outer_side, height/2.0, z), Vector3(0.35, height, depth), wall_color)
    _box(label + " north wall", Vector3(x, height/2.0, z-depth/2.0), Vector3(width, height, 0.35), wall_color)
    _box(label + " south wall", Vector3(x, height/2.0, z+depth/2.0), Vector3(width, height, 0.35), wall_color)
    var segment := (depth - 2.5) / 2.0
    _box(label + " frontage north", Vector3(inner_side, height/2.0, z - (depth + 2.5)/4.0), Vector3(0.35, height, segment), wall_color)
    _box(label + " frontage south", Vector3(inner_side, height/2.0, z + (depth + 2.5)/4.0), Vector3(0.35, height, segment), wall_color)
    _box(label + " doorway lintel", Vector3(inner_side, height - 0.55, z), Vector3(0.35, 1.1, 2.5), wall_color)
    _box(label + " patched roof", Vector3(x, height + 0.2, z), Vector3(width+0.7, 0.4, depth+0.7), METAL)
    # Pieces of uneven sheet metal nailed to the outside give a scavenged silhouette.
    _box(label + " patch panel", Vector3(inner_side + (0.21 if facing_right else -0.21), 2.0, z + depth*0.29), Vector3(0.08, 2.3, 1.4), RUST, false)
    _box(label + " front canopy", Vector3(inner_side + (1.15 if facing_right else -1.15), 3.1, z), Vector3(2.4, 0.18, depth*0.75), RUST, false)
    if bedroom:
        _box("Bed frame", Vector3(x - 2.2, 0.55, z+2.0), Vector3(2.4, 0.45, 3), WOOD)
        _box("Faded mattress", Vector3(x - 2.2, 0.88, z+2.0), Vector3(2.2, 0.22, 2.8), Color(0.53, 0.49, 0.38))
        _box("Bedside crate", Vector3(x + 0.5, 0.65, z+2.5), Vector3(1.2, 1.3, 1.0), WOOD)
        _box("Broken window", Vector3(outer_side, 2.7, z-1.8), Vector3(0.08, 1.2, 1.7), Color(0.12, 0.15, 0.15), false)

func _canteen_interior() -> void:
    # The saloon doubles as Dustfall's communal dining hall.
    _box("Canteen counter", Vector3(-18.8, 0.9, -9.6), Vector3(1.15, 1.8, 4.7), WOOD)
    _box("Canteen table", Vector3(-15.8, 0.85, -3.7), Vector3(2.0, 0.18, 1.4), WOOD)
    _box("Canteen table legs", Vector3(-15.8, 0.43, -3.7), Vector3(0.45, 0.8, 0.5), METAL)
    _box("Canteen cooking barrel", Vector3(-19.4, 0.55, -4.4), Vector3(1.0, 1.1, 0.9), RUST)
    var lantern := OmniLight3D.new()
    lantern.name = "Canteen low-power lantern"
    lantern.position = Vector3(-17.5, 2.7, -7)
    lantern.light_color = Color(1.0, 0.67, 0.38)
    lantern.omni_range = 8.5
    lantern.light_energy = 0.8
    add_child(lantern)

func _wrecked_bus(pos: Vector3) -> void:
    _box("Rusted bus body", pos+Vector3(0, 1.9, 0), Vector3(3.3, 3.2, 9), RUST)
    _box("Bus roof", pos+Vector3(0, 3.58, 0), Vector3(3.4, 0.2, 9.2), METAL)
    for offset in [-3.1, -1.2, 0.7, 2.6]:
        _box("Black bus window", pos+Vector3(-1.68, 2.5, offset), Vector3(0.08, 0.9, 1.35), Color(0.09, 0.11, 0.11), false)
    _box("Bus scrap heap", pos+Vector3(3.3, 0.5, 1.8), Vector3(3, 1, 2.7), METAL)

func _truck(pos: Vector3) -> void:
    _box("Abandoned pickup", pos+Vector3(0, 0.85, 0), Vector3(2.3, 1.25, 4.4), RUST)
    _box("Crumpled cab", pos+Vector3(0, 1.8, -0.65), Vector3(2.0, 0.85, 2.1), METAL)
    for x in [-1.1, 1.1]:
        for z in [-1.4, 1.5]:
            _box("Flat tire", pos+Vector3(x, 0.42, z), Vector3(0.45, 0.8, 0.85), Color(0.1, 0.1, 0.09))

func _collapsed_overpass() -> void:
    _box("Broken highway deck", Vector3(-36, 5.0, -33), Vector3(11, 0.9, 12), CONCRETE)
    _box("Ruined highway pillar", Vector3(-40, 2.6, -35), Vector3(1.4, 5.2, 1.4), CONCRETE)
    _box("Fallen overpass slab", Vector3(-29, 0.65, -38), Vector3(11, 1.3, 5), CONCRETE)
    _box("Rubble", Vector3(-32, 0.4, -28), Vector3(5, 0.8, 4), CONCRETE)

func _water_tower() -> void:
    for x in [27.0, 32.0]:
        for z in [-30.0, -25.0]:
            _box("Tower metal leg", Vector3(x, 3.5, z), Vector3(0.35, 7, 0.35), METAL)
    _box("Tower platform", Vector3(29.5, 7.2, -27.5), Vector3(6.7, 0.3, 6.7), WOOD)
    _box("Corroded water tank", Vector3(29.5, 9.0, -27.5), Vector3(5.8, 3.4, 5.8), RUST)

func _perimeter() -> void:
    # Settlement borders; both road exits are intentionally open.
    for x in [-35.0, -30.0, -25.0, -20.0, -15.0, -10.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0]:
        _box("Scrap barricade", Vector3(x, 1, -43), Vector3(4.7, 2, 0.28), METAL)
    for z in [-35.0, -30.0, -25.0, -20.0, -15.0, -10.0, 25.0, 30.0, 35.0]:
        _box("Outer scrap fence", Vector3(-43, 1.15, z), Vector3(0.3, 2.3, 4.6), RUST)

func _small_details() -> void:
    for pos in [Vector3(-33,0,22), Vector3(35,0,33), Vector3(36,0,-33), Vector3(-31,0,-8)]:
        _box("Dead tree", pos+Vector3(0,2.2,0), Vector3(0.45,4.4,0.45), WOOD)
    for z in [-36.0, -8.0, 20.0, 38.0]:
        _box("Dead telephone pole", Vector3(39, 3.6, z), Vector3(0.4, 7.2, 0.4), WOOD)
        _box("Broken crossarm", Vector3(39, 6.2, z), Vector3(3.2, 0.2, 0.2), WOOD, false)
    for pos in [Vector3(7,0.55,29), Vector3(-7,0.55,-18), Vector3(24,0.55,-19), Vector3(-23,0.55,10)]:
        _box("Rusty barrel", pos, Vector3(0.85, 1.1, 0.85), RUST)
    for pos in [Vector3(-8,0.2,-23), Vector3(8,0.2,31), Vector3(10,0.2,-31), Vector3(-11,0.2,6)]:
        _box("Concrete debris", pos, Vector3(1.8,0.4,1.6), CONCRETE, false)
    _box("Community notice board", Vector3(6.9, 1.4, 3.8), Vector3(0.3, 2.8, 2.5), WOOD)
    _box("Solar panel from ruins", Vector3(23, 3.7, -10), Vector3(3.2, 0.16, 2.2), Color(0.09, 0.15, 0.19), false)
    var lamp := OmniLight3D.new()
    lamp.name = "Salvaged generator work light"
    lamp.position = Vector3(20, 3.4, -4)
    lamp.light_color = Color(1, 0.62, 0.3)
    lamp.omni_range = 8.0
    lamp.light_energy = 0.65
    add_child(lamp)

func _sign(label: String, pos: Vector3) -> void:
    _box(label, pos+Vector3(0, 1.5, 0), Vector3(0.22, 3, 0.22), WOOD)
    _box(label + " board", pos+Vector3(0, 2.6, 0), Vector3(0.3, 1.1, 2.4), RUST, false)

func _box(label: String, pos: Vector3, size: Vector3, color: Color, solid: bool = true) -> void:
    var body := StaticBody3D.new()
    body.name = label
    body.position = pos
    var mesh := MeshInstance3D.new()
    var geometry := BoxMesh.new()
    geometry.size = size
    mesh.mesh = geometry
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    mesh.material_override = mat
    body.add_child(mesh)
    if solid:
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        body.add_child(collision)
    add_child(body)
