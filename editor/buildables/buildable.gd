extends Resource

class_name Buildable
@export var tiers : Array[BuildableTier]

## Return the buildables base tier int
func base_tier() -> int:
	return tiers[0].tier

## Return a BuildableTier of a specific game tier
func get_tier(tier_req: int) -> BuildableTier:
	for tier in tiers:
		if tier.tier == tier_req:
			return tier
	return null
	
## Return the next tier int or loop back to the start
func next_tier(current_tier: int) -> int:
	for i in range(tiers.size()):
		var next = i+1
		if(tiers[i].tier == current_tier && next  < tiers.size()):
			return tiers[next].tier
	return base_tier()
