extends Control

@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var close_button: Button = $CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	hide()

func _on_close_pressed() -> void:
	for child in subviewport.get_children():
		child.queue_free()
	hide()
