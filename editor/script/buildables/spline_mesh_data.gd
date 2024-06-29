extends StaticMeshData
class_name SplineMeshData

## Mesh placed at the start of a spline
@export var start_mesh: PackedScene
## Mesh placed at the end of a spline
@export var end_mesh: PackedScene
## Mesh thats placed in the middle of the spline
@export var middle_mesh: PackedScene
## How often to place middle mesh throughout the spline
@export var middle_mesh_freq: int = 1
