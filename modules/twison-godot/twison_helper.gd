extends Object

# This script allows importing twine stories into godot.
# Please note that only plain text and standart passage links are supported.

var passages = {}
var data = {}

# Parses the file for passages
# If this script was already filled with data, it will be lost.

# linkFilter is a function that accepts a RegExMatch containing link,
# and returns with what this link should be replaced.
# For more info take a look at two example filters provided, and the documentation. 
func parse_file(filePath: String, linkFilter: FuncRef = null):
	data = {}
	passages = {}
	data = _load_file(filePath)
	_extract_passages()
	if (linkFilter == null):
		linkFilter = funcref(self, "link_filter_erase")
	_filter_links(linkFilter)

func _extract_passages():
	for passage in data["passages"]:
		var pid = int(passage["pid"])
		passages[pid] = passage

func _filter_links(linkFilter: FuncRef):
	# \[\[(.+?(?=\]\]))\]\]
	var link_regex = "\\[\\[(.+?(?=\\]\\]))\\]\\]"
	var reg = RegEx.new()
	reg.compile(link_regex)
	
	var text
	for passage in passages:
		text = passages[passage]["text"]
		for result in reg.search_all(text):
			var newLink = linkFilter.call_func(result)
			text = text.replace(result.get_string(), newLink)
		
		text = text.strip_edges(true, true)
		passages[passage]["text"] = text

func _load_file(filePath: String):
	var jsonFile = File.new()
	jsonFile.open(filePath, jsonFile.READ)
	
	if (jsonFile.get_error()):
		printerr("Cannot open json file!")
		return data
	
	var text = jsonFile.get_as_text()
	data = parse_json(text)
	jsonFile.close()

	return data

# Identifyes name and link in string match.
# It is best not to send link with braces here,
# as they will not be stripped
static func identify_link(link: String):
	if (link.find("->") != -1):
		var temp = link.split("->")
		return {"name": temp[0], "link": temp[1]}
	if (link.find("<-") != -1):
		var temp = link.split("<-")
		return {"name": temp[1], "link": temp[0]}
	if (link.find("|") != -1):
		var temp = link.split("|")
		return {"name": temp[0], "link": temp[1]}
	
	return {"name": link, "link": link}

# Simply erases strings. This is the default filter.
static func link_filter_erase(link: RegExMatch):
	return ""

# Replaces links with bbcode urls.
# The displayed text will be equal to link name
# The data will be equal to target passage name
static func link_filter_bbcode(link: RegExMatch):
	var link_id = identify_link(link.get_string(1))
	return "[url=%s]%s[/url]" % [link_id["link"], link_id["name"]]

# Returns passage itself
func get_passage(pid: int):
	if(passages.has(pid)):
		return passages[pid]
	else:
		return {"text": "Error: Passage #"+str(pid)+" not found"}

# Returns passage itself
func get_passage_by_name(name: String):
	for pid in passages:
		if (passages[pid]["name"] == name):
			return passages[pid]
	return {"text": "Error: Passage \""+name+"\" not found"}

# Returns an array of links in string form, "name->link"
# If name IS the link, then just name.
func get_passage_links(passage: Dictionary):
	var result = []
	if (passage.has("links")):
		var links = passage["links"]
		for i in links:
			if (i["name"] == i["link"]):
				result.append(i["name"])
			else:
				result.append(i["name"]+"->"+i["link"])
	return result

func get_passage_names():
	var names = []
	for pid in passages:
		var passage = passages[pid]
		if(passage.has("name")):
			names.append(passage["name"])
		else:
			names.append("Name not found!")
	return names

func has_passage(pid: int):
	return passages.has(pid)

# Returns a pid
# Returns -1 if starting node not found
func get_starting_node():
	if (data.has("startnode")):
		return int(data["startnode"])
	else:
		return -1

# Returns story name
func get_story_name():
	if (data.has("name")):
		return data["name"]
	else:
		return "Error: Story name not found"