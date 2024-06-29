extends Resource
class_name StaticMeshData

@export var meshes: Array[PackedScene]

## Return the default first mesh, or null if empty
func get_default_mesh() -> PackedScene:
	if meshes.size() == 0:
		return null
	return meshes[0]
