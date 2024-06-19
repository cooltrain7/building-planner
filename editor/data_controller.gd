extends Node

class_name DataController
@export var wiki_query_active: bool = true
@export var buildables: Array[Buildable]

##Pair wiki requirement props with build enum
var requirements = {
	"RequiresTownHall": BuildableTier.BuildReqiurements.BuildInTown,
	"RequiresHomestead": BuildableTier.BuildReqiurements.BuildInHomestead,
	"RequiresCamp": BuildableTier.BuildReqiurements.BuildInLargeCamp,
	"RequiresSmallCamp": BuildableTier.BuildReqiurements.BuildInSmallCamp
}

func _ready():
	if buildables.size() == 0:
		push_error("No buildables set")
	if wiki_query_active:
		var s_query = WikiRequest.new()
		add_child(s_query)
		s_query.wiki_request_complete.connect(self._wiki_structure_request_complete)
		s_query.query("tables=structuretiers&fields=structuretiers.CodeNameString,structuretiers.NameText,structuretiers.Tier,structuretiers.RequiresTownHall,structuretiers.RequiresHomestead&limit=2000&format=json")

## Signal returned after the structure wiki query completes
func _wiki_structure_request_complete(result: int, response_code: int, json: Variant) -> void:
	if(result == OK && response_code == 200):
		if json == null:
			return
		_proc_structures(json)
		pass
	pass

## Process our wiki structure data and update our buildables to use that data
## The cursed staircase
func _proc_structures(json):
	for ele in json:
		if !ele.has("CodeNameString") || ele["CodeNameString"] == null:
			continue
		var code_name = ele["CodeNameString"]
		for buildable in buildables:
			if buildable == null || buildable.tiers.size() == 0:
				continue
			for tier in buildable.tiers:
				if tier == null:
					continue
				if tier.code_name == code_name:
					print("Query matched ", tier.code_name)
					if ele.has("NameText") && ele["NameText"] != null:
						tier.disp_name = ele["NameText"]
					for key in requirements.keys():
						if ele.has(key) and ele[key] != null:
							tier.add_build_req(requirements[key])

## Debug returns next pos in array or back to start
func next_buildable_pos(pos: int) -> int:
	if(pos >= buildables.size()-1):
		return 0
	return pos +1

func next_buildable(pos: int) -> Buildable:
	if(pos > buildables.size()-1):
		return buildables[0]
	return buildables[pos]
