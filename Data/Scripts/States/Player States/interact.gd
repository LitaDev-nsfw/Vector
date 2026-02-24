extends State

@onready var player: Player = get_parent().get_parent()

var current_interaction_type: Player.InteractionTypes
var interaction_speed: float = 5.0

func begin_state():
	player.play_animation("interact")
	player.progress_bar.start_progress_bar()
	if player.latest_interactable is HarvestableTerrain:
		match player.latest_interactable.harvest_type:
			Terrain.HarvestTypes.MINING: current_interaction_type = Player.InteractionTypes.MINING
			Terrain.HarvestTypes.GATHERING: current_interaction_type = Player.InteractionTypes.GATHERING
			Terrain.HarvestTypes.FISHING: current_interaction_type = Player.InteractionTypes.FISHING
	elif player.latest_interactable is Terrain:
		current_interaction_type = Player.InteractionTypes.GENERIC
	if !current_interaction_type:
		push_error("No Current Interaction Type")
	match current_interaction_type:
		Player.InteractionTypes.GENERIC: pass
		Player.InteractionTypes.WEAPONSMITHING: interaction_speed = player.get_attribute(Player.Attributes.CRAFTING_SPEED)+player.get_attribute(Player.Attributes.WEAPONSMITHING_SPEED)
		Player.InteractionTypes.ARMORSMITHING: interaction_speed = player.get_attribute(Player.Attributes.CRAFTING_SPEED)+player.get_attribute(Player.Attributes.ARMORSMITHING_SPEED)
		Player.InteractionTypes.GOLDSMITHING: interaction_speed = player.get_attribute(Player.Attributes.CRAFTING_SPEED)+player.get_attribute(Player.Attributes.GOLDSMITHING_SPEED)
		Player.InteractionTypes.ALCHEMY: interaction_speed = player.get_attribute(Player.Attributes.CRAFTING_SPEED)+player.get_attribute(Player.Attributes.ALCHEMY_SPEED)
		Player.InteractionTypes.COOKING: interaction_speed = player.get_attribute(Player.Attributes.CRAFTING_SPEED)+player.get_attribute(Player.Attributes.COOKING_SPEED)
		Player.InteractionTypes.ENSORCELLING: interaction_speed = player.get_attribute(Player.Attributes.CRAFTING_SPEED)+player.get_attribute(Player.Attributes.ENSORCELLING_SPEED)
		Player.InteractionTypes.GATHERING: interaction_speed = player.get_attribute(Player.Attributes.GATHERING_SPEED)
		Player.InteractionTypes.MINING: interaction_speed = player.get_attribute(Player.Attributes.MINING_SPEED)
		Player.InteractionTypes.FISHING: interaction_speed = player.get_attribute(Player.Attributes.FISHING_SPEED)

func end_state():
	if player.progress_bar.value != 100:
		player.progress_bar.cancel_progress()
	else:
		if current_interaction_type in [Player.InteractionTypes.MINING, Player.InteractionTypes.GATHERING, Player.InteractionTypes.FISHING]:
			player.latest_interactable.on_harvest()
		elif current_interaction_type == Player.InteractionTypes.GENERIC:
			pass
		player.progress_bar.visible = false
		player.progress_bar.value = 0

func update(_delta: float):
	print(interaction_speed)
	player.progress_bar.add_value(interaction_speed)
	if player.progress_bar.value == 100:
		state_machine.change_state("idle")
	if player.input_vector:
		state_machine.change_state("run")
	
		
