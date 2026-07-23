extends Control

const UPGRADE_BUTTON_NAME_PREFIX := "UpgradeButton_"

@onready var chispa_label: Label = %ChispaLabel
@onready var upgrades_container: VBoxContainer = %UpgradesContainer
@onready var start_run_button: Button = %StartRunButton


func _ready() -> void:
	chispa_label.text = "Chispa: %d" % Chispa.chispa
	Chispa.chispa_changed.connect(_on_chispa_changed)
	Chispa.upgrade_purchased.connect(_on_upgrade_purchased)

	start_run_button.pressed.connect(_on_start_run_pressed)

	_build_upgrade_buttons()


func _on_start_run_pressed() -> void:
	RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_chispa_changed(new_amount: int) -> void:
	chispa_label.text = "Chispa: %d" % new_amount
	_refresh_upgrade_buttons()


func _on_upgrade_purchased(_upgrade_id: String) -> void:
	_refresh_upgrade_buttons()


func _build_upgrade_buttons() -> void:
	for upgrade_id: String in Chispa.UPGRADES:
		var button := Button.new()
		button.name = UPGRADE_BUTTON_NAME_PREFIX + upgrade_id
		button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_id))
		upgrades_container.add_child(button)

	_refresh_upgrade_buttons()


func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	Chispa.buy_upgrade(upgrade_id)


func _refresh_upgrade_buttons() -> void:
	for upgrade_id: String in Chispa.UPGRADES:
		var button: Button = upgrades_container.get_node(UPGRADE_BUTTON_NAME_PREFIX + upgrade_id)
		var data: Dictionary = Chispa.UPGRADES[upgrade_id]
		var owned := Chispa.has_upgrade(upgrade_id)

		var text := "%s %d — %s (%d Chispa)" % [data["branch"], data["tier"], data["display_name"], data["cost"]]
		if owned:
			text += " (ya comprada)"
		elif not Chispa.is_dependency_met(upgrade_id):
			var requires_id: String = data["requires"]
			var requires_data: Dictionary = Chispa.UPGRADES[requires_id]
			text += " — requiere: %s %d" % [requires_data["branch"], requires_data["tier"]]

		button.text = text
		button.disabled = owned or not Chispa.can_afford(upgrade_id)
