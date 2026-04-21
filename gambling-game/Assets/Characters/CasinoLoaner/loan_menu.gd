extends CanvasLayer

@onready var loan100 : Button = $ColorRect/Loan100
@onready var loan500 : Button = $ColorRect/Loan500
@onready var loan1000 : Button = $ColorRect/Loan1000
@onready var current_loan_label : Label = $ColorRect/CurrentSelected

var current_loan_amount
signal loan_submitted(loan_amt)

func _ready() -> void:
	# multiply by 1.5 for interest
	loan100.pressed.connect(func(): set_loan_amount(100))
	loan500.pressed.connect(func(): set_loan_amount(500))
	loan1000.pressed.connect(func(): set_loan_amount(1000))
	

func set_loan_amount(amt : int):
	current_loan_amount = amt
	update_label()

func update_label():
	current_loan_label.text = "Loan: $%d" % current_loan_amount


func _on_confirm_pressed() -> void:
	loan_submitted.emit(current_loan_amount)
