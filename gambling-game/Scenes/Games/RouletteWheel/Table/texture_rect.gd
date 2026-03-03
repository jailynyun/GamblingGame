extends TextureRect

@onready var highlight = $"../Highlight"

var regions := {
	# Rect2 defined as Rect2(position_vector, size_vector)
	#"1": Rect2(Vector2(45, 104), Vector2(40, 49)),
	#"2": Rect2(Vector2(45, 55), Vector2(40, 49)),
	#"3": Rect2(Vector2(45, 6), Vector2(40, 49))
}

func _ready():
	fill_regions_36()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	highlight.visible = false
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_mouse_entered():
	print("Hover start")

func _on_mouse_exited():
	print("Hover end")

func _gui_input(event):
	var local = get_local_mouse_position()
	
	# When region is clicked, prints the clicked region
	for r in regions:
		if regions[r].has_point(local):
			if event is InputEventMouseButton and event.pressed:
				print("Coords: ", local)
				print("Clicked region:", r)
	
	
	# Highlights when hovering over region
	var hovered_region = get_region(local)

	if hovered_region != "":
		highlight.visible = true
		highlight.position = regions[hovered_region].position
		highlight.size = regions[hovered_region].size
	else:
		highlight.visible = false


func get_region(point: Vector2) -> String:
	for r in regions:
		if regions[r].has_point(point):
			return r
	return ""
	
func fill_regions_36():
	var rect_size = Vector2(39.3, 49)
	var start_corner = Vector2(45, 104)
	var changing_corner = Vector2(45, 104)
	var num = 0
	for i in range(12):
		changing_corner.x += i * rect_size.x
		for j in range(3):
			regions[str(num)] = Rect2(changing_corner, rect_size)
			changing_corner.y -= rect_size.y
			num += 1
		changing_corner = start_corner
