extends Control

signal dialog_finished  # Signal to indicate dialog is complete

@export var background_color: Color = Color(0, 0, 0, 0.5)  # Configurable background color
@export var text_color: Color = Color.WHITE  # Configurable text color
@export var font_size: int = 24  # Configurable font size

var background: ColorRect
var label: Label
var title_label: Label

# Dialog management variables
var full_dialog_text: String = ""
var current_dialog_page: int = 0
var dialog_pages: PackedStringArray = []
var is_dialog_active: bool = false

func _ready():
	# Ensure the dialog container fills the bottom of the screen
	anchor_left = 0
	anchor_right = 1
	anchor_bottom = 1
	anchor_top = 1
	
	# Offset from the bottom of the screen
	offset_top = -200  # Adjust this to change dialog height
	offset_bottom = 0
	
	# Create a background ColorRect for the dialog
	background = ColorRect.new()
	background.color = background_color
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Create a title Label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.anchor_left = 0.01
	title_label.anchor_right = 0.95
	title_label.anchor_top = 0.1
	title_label.anchor_bottom = 0.3
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", font_size + 4)
	title_label.add_theme_color_override("font_color", text_color)
	add_child(title_label)
	
	# Create a Label for the dialog text
	label = Label.new()
	label.name = "DialogLabel"
	label.anchor_left = 0.01
	label.anchor_right = 0.95
	label.anchor_top = 0.3
	label.anchor_bottom = 0.9
	
	# Style the label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	
	# Ensure text wraps across the full width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size.x = get_viewport_rect().size.x * 0.9
	
	add_child(label)
	
	# Initially hide the dialog
	visible = false
	
	# Set up input processing
	set_process_input(true)

func _input(event):
	# Handle dialog advancement
	if is_dialog_active:
		# Advance dialog on spacebar or left mouse click
		if (event.is_action_pressed("ui_select") or  # Spacebar
			(event is InputEventMouseButton and 
			 event.button_index == MOUSE_BUTTON_LEFT and 
			 event.pressed)):
			advance_dialog()

# Method to show dialog with specific text and optional title
func show_dialog(text: String, title: String = ""):
	# Split text into pages that fit the dialog box
	full_dialog_text = text
	dialog_pages = split_text_into_pages(text)
	current_dialog_page = 0
	
	title_label.text = title
	title_label.visible = not title.is_empty()
	
	# Show first page
	display_current_page()
	visible = true
	is_dialog_active = true

# Split long text into pages that fit the dialog box
func split_text_into_pages(text: String) -> PackedStringArray:
	var pages: PackedStringArray = []
	var words = text.split(" ")
	var current_page = ""
	
	for word in words:
		# Simulate adding the word to see if it would overflow
		var test_page = current_page + " " + word if current_page else word
		
		# Rough estimation of page capacity (you might need to adjust)
		if test_page.length() > 300:  # Adjust this value based on your UI
			pages.append(current_page.strip_edges())
			current_page = word
		else:
			current_page = test_page
	
	# Add last page
	if current_page:
		pages.append(current_page.strip_edges())
	
	return pages

# Display current page of dialog
func display_current_page():
	if current_dialog_page < dialog_pages.size():
		label.text = dialog_pages[current_dialog_page]
	
# Advance to next dialog page
func advance_dialog():
	current_dialog_page += 1
	
	if current_dialog_page < dialog_pages.size():
		# More pages to display
		display_current_page()
	else:
		# No more pages, close dialog
		hide_dialog()

# Method to hide dialog
func hide_dialog():
	visible = false
	is_dialog_active = false
	current_dialog_page = 0
	dialog_pages.clear()
	emit_signal("dialog_finished")
