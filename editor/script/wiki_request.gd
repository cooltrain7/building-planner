extends HTTPRequest
class_name WikiRequest

var base_url: String  = "https://anvilempires.wiki.gg/index.php?title=Special:CargoExport"
var query_args: String
var json: Variant

signal wiki_request_complete

func query(query_args: String) -> void:
	var err = request(base_url + "&" + query_args)
	if err != OK:
		push_error("Wiki query error: ", err)
	pass
	
func _ready() -> void:
	request_completed.connect(self._request_completed)

func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var data = null
	if result == 0 && response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		data = json.get_data()
	wiki_request_complete.emit(result, response_code, data)
