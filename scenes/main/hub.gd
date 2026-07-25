extends Control

@onready var chispa_label: Label = %ChispaLabel
@onready var upgrades_container: VBoxContainer = %UpgradesContainer
@onready var start_run_button: Button = %StartRunButton
@onready var respec_button: Button = %RespecButton
@onready var respec_confirm_dialog: ConfirmationDialog = %RespecConfirmDialog

var _upgrade_buttons: Dictionary = {}
var _branch_rows: Dictionary = {}


func _ready() -> void:
	chispa_label.text = "Chispa: %d" % Chispa.chispa
	Chispa.chispa_changed.connect(_on_chispa_changed)
	Chispa.upgrade_purchased.connect(_on_upgrade_purchased)

	start_run_button.pressed.connect(_on_start_run_pressed)
	respec_button.pressed.connect(_on_respec_button_pressed)
	respec_confirm_dialog.confirmed.connect(_on_respec_confirmed)

	_build_upgrade_buttons()
	_refresh_respec_button()


func _on_start_run_pressed() -> void:
	RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_respec_button_pressed() -> void:
	respec_confirm_dialog.dialog_text = "Vaciar el árbol y recuperar %d Chispa?" % Chispa.respec_refund_amount()
	respec_confirm_dialog.popup_centered()


func _on_respec_confirmed() -> void:
	Chispa.respec_tree()


func _on_chispa_changed(new_amount: int) -> void:
	chispa_label.text = "Chispa: %d" % new_amount
	_refresh_upgrade_buttons()
	_refresh_respec_button()


func _on_upgrade_purchased(_upgrade_id: String) -> void:
	_refresh_upgrade_buttons()
	_refresh_respec_button()


func _build_upgrade_buttons() -> void:
	for upgrade_id: String in Chispa.UPGRADES:
		var data: Dictionary = Chispa.UPGRADES[upgrade_id]
		var branch: String = data["branch"]

		if not _branch_rows.has(branch):
			var row := HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_theme_constant_override("separation", 16)
			upgrades_container.add_child(row)

			var branch_label := Label.new()
			branch_label.custom_minimum_size = Vector2(90, 0)
			branch_label.text = branch
			row.add_child(branch_label)

			_branch_rows[branch] = row

		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_id))
		_branch_rows[branch].add_child(button)
		_upgrade_buttons[upgrade_id] = button

	_refresh_upgrade_buttons()


func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	Chispa.buy_upgrade(upgrade_id)


func _refresh_upgrade_buttons() -> void:
	for upgrade_id: String in Chispa.UPGRADES:
		var button: Button = _upgrade_buttons[upgrade_id]
		var data: Dictionary = Chispa.UPGRADES[upgrade_id]
		var owned := Chispa.has_upgrade(upgrade_id)

		button.text = str(data["tier"])

		var tooltip := "%s %d — %s (%d Chispa)" % [data["branch"], data["tier"], data["display_name"], data["cost"]]
		if owned:
			tooltip += "\n(ya comprada)"
		elif not Chispa.is_dependency_met(upgrade_id):
			var requires_id: String = data["requires"]
			var requires_data: Dictionary = Chispa.UPGRADES[requires_id]
			tooltip += "\nRequiere: %s %d" % [requires_data["branch"], requires_data["tier"]]
		button.tooltip_text = tooltip

		button.disabled = owned or not Chispa.can_afford(upgrade_id)
		button.modulate = Color(0.55, 1.0, 0.55) if owned else Color(1, 1, 1)


func _refresh_respec_button() -> void:
	respec_button.disabled = Chispa.unlocked_upgrades.is_empty()
