extends TextureRect
#
#@onready var highlight = $"../Highlight"
#
#var regions := {
	## Rect2 defined as Rect2(position_vector, size_vector)
	##"1": Rect2(Vector2(45, 104), Vector2(40, 49)),
	##"2": Rect2(Vector2(45, 55), Vector2(40, 49)),
	##"3": Rect2(Vector2(45, 6), Vector2(40, 49))
#}
#
#signal bet_added(num_clicked)
##signal bet_removed()
#
#func _ready():
	#fill_regions_single()
	#fill_regions_third()
	#fill_regions_half()
	##mouse_entered.connect(_on_mouse_entered)
	##mouse_exited.connect(_on_mouse_exited)
	#highlight.visible = false
	#highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
#
#
#func _on_mouse_entered():
	##print("Hover start")
	#pass
#
#func _on_mouse_exited():
	##print("Hover end")
	#pass
#
#func _gui_input(event):
	#var local = get_local_mouse_position()
	#
	## When region is clicked, prints the clicked region
	#for r in regions:
		#if regions[r].has_point(local):
			#if event is InputEventMouseButton and event.pressed:
				##print("Coords: ", local)
				#print("Clicked region:", r)
				#bet_added.emit(r+1)
	#
	 #
	## Highlights when hovering over region
	#var hovered_region = get_region(local)
#
	#if hovered_region != -1:
		#highlight.visible = true
		#highlight.position = regions[hovered_region].position
		#highlight.size = regions[hovered_region].size
	#else:
		#highlight.visible = false
#
#
#func get_region(point: Vector2):
	#for r in regions:
		#if regions[r].has_point(point):
			#return r
	#return -1
	#
#func fill_regions_single():
	#var rect_size = Vector2(39.3, 49)
	#var start_corner = Vector2(45, 104)
	#var changing_corner = Vector2(45, 104)
	#var num = 0
	#for i in range(12):
		#changing_corner.x += i * rect_size.x
		#for j in range(3):
			#regions[num] = Rect2(changing_corner, rect_size)
			#changing_corner.y -= rect_size.y
			#num += 1
		#changing_corner = start_corner
	#
	## Green spots
	#regions[99] = Rect2(Vector2(7, 80), Vector2(39.3, 73.5)) # Green 0
	#regions[999] = Rect2(Vector2(7, 6.5), Vector2(39.3, 73.5)) #Green 00
#
#func fill_regions_third():
	## regions 120, 121, 122- sections of 12
	#var rect_size = Vector2(157.2, 30)
	#var start_corner = Vector2(45, 151)
	#var changing_corner = Vector2(45, 151)
	#var num = 120
	#for i in range(3):
		#changing_corner.x += i * rect_size.x
		#regions[num] = Rect2(changing_corner, rect_size)
		#num += 1
		#changing_corner = start_corner
	#
	## regions 123, 124, 125 - columns
	#rect_size = Vector2(39.3, 49)
	#start_corner = Vector2(517, 104)
	#changing_corner = Vector2(517, 104)
	#for i in range(3):
		#changing_corner.y -= i * rect_size.y
		#regions[num] = Rect2(changing_corner, rect_size)
		#num += 1
		#changing_corner = start_corner
	#
#
#func fill_regions_half():
	#var rect_size = Vector2(78.6, 30)
	#var start_corner = Vector2(45, 181)
	#var changing_corner = Vector2(45, 181)
	#var num = 60
	#for i in range(6):
		#changing_corner.x += i * rect_size.x
		#regions[num] = Rect2(changing_corner, rect_size)
		#num += 1
		#changing_corner = start_corner
