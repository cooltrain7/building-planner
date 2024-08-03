extends Resource

class_name BuildableTier
## Codename, used as its unique ID
@export var code_name: String
## Ingame name
@export var disp_name: String
## Game icon
@export var icon: Texture2D
## Game tier
@export var tier: int
## Bitmask of build requirements
@export_flags("Town", "Small Camp", "Large Camp", "Homestead","Workshop")  
var build_reqs: int = 0
## Build mesh scene
@export var mesh: PackedScene

## Adds a build requirement
func add_build_req(req: int) -> void:
	build_reqs |= req
	
## Removes a build requirement
func rem_build_req(req: int) -> void:
	build_reqs &= ~req
	
## Returns bool if a matching requirement is set
func has_build_req(req : int) -> bool:
	return (build_reqs & req) != 0

## Bitmask enum of structure build requirements
enum BuildReqiurements
{
	BuildInTown = 1 << 0,
	BuildInSmallCamp = 1 << 1,
	BuildInLargeCamp = 1 << 2,
	BuildInHomestead = 1 << 3,
	BuildInWorkshop = 1 << 4
}
