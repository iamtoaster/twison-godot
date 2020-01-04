# Twison to godot
---
This script allows easier communication between Twine and Godot using Twison exporter.


To start using this script, copy script located under modules/twison-godot folder to your project, at any location. (For example: `res://modules/twison-godot/twison_helper.gd`)

For instructions on how to install, configure and use [Twine](https://twinery.org/) and [Twison](https://github.com/lazerwalker/twison) exporter (clickable), refer to their respective documentations.

Once you have created and exported your story to json format, all you have to do to import your story to godot is import the script and call one function:
```
onready var twison = preload("res://path/to/twison_helper.gd")
onready var Twison = twison.new()

func _ready():
	Twison.parse_file(scriptPath)
```
And done! Now you have access to all helper fucntions that this script provides for working with twine stories.

For more info head over to the wiki section, or take a look at example scene provided with the script which demonstrates basic usage. (It is called `Node2D.tscn`, and is located at root of this repository.)

Please note that this sctipt only provides means with which to work with Twine stories, not how to display them. Example scene which is included with this script shows how to use `RichTextLabel` to display a story. 

P.S. You can just import `project.godot` to the editor if you simply want to have a look. Just saying.
