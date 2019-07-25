//Marine jobs. All marines are genericized when they first log in, then it auto assigns them to squads.

/datum/job/marine
	department_flag = ROLEGROUP_MARINE_SQUAD_MARINES
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	total_positions = 8
	spawn_positions = 8
	allow_additional = 1
	minimal_player_age = 3

/datum/job/marine

	generate_entry_message(mob/living/carbon/human/H)
		if(H.assigned_squad)
			. = "You have been assigned to: <b><font size=3 color=[squad_colors[H.assigned_squad.color]]>[lowertext(H.assigned_squad.name)] squad</font></b>.[flags_startup_parameters & ROLE_ADD_TO_MODE ? " Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room." : ""]"

	generate_entry_conditions(mob/living/carbon/human/H)
		. = ..()
		if(flags_startup_parameters & ROLE_ADD_TO_MODE) H.nutrition = rand(60,250) //Start hungry for the default marine.

/datum/job/marine/leader
	title = "Squad Leader"
	flag = ROLE_MARINE_LEADER
	total_positions = 4
	spawn_positions = 4
	supervisors = "the acting commanding officer"
	minimal_player_age = 7
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Squad Leader"

	generate_entry_message()
		. = ..() + {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."}

/datum/job/marine/leader/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/marine/engineer
	title = "Squad Engineer"
	total_positions = 12
	spawn_positions = 12
	allow_additional = 1
	flag = ROLE_MARINE_ENGINEER
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Squad Engineer"

	generate_entry_message()
		. = ..() + {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."}

	get_total_positions(var/latejoin=0)
		var/slots = engi_slot_formula(get_total_marines())
		if(latejoin)
			for(var/datum/squad/sq in RoleAuthority.squads)
				if(sq)
					sq.max_engineers = slots
		return (slots*4)

/datum/job/marine/engineer/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/marine/medic
	title = "Squad Medic"
	total_positions = 16
	spawn_positions = 16
	allow_additional = 1
	flag = ROLE_MARINE_MEDIC
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Squad Medic"

	generate_entry_message()
		. = ..() + {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."}

	get_total_positions(var/latejoin=0)
		var/slots = medic_slot_formula(get_total_marines())
		if(latejoin)
			for(var/datum/squad/sq in RoleAuthority.squads)
				if(sq)
					sq.max_medics = slots
		return (slots*4)

/datum/job/marine/medic/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD

/datum/job/marine/specialist
	title = "Squad Specialist"
	flag = ROLE_MARINE_SPECIALIST
	total_positions = 4
	spawn_positions = 4
	allow_additional = 1
	minimal_player_age = 7
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Squad Specialist"

	generate_entry_message()
		. = ..() + {"\nYou are the very rare and valuable weapon expert, trained to use special equipment.
You can serve a variety of roles, so choose carefully."}

/datum/job/marine/specialist/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD


/datum/job/marine/smartgunner
	title = "Squad Smartgunner"
	flag = ROLE_MARINE_SMARTGUN
	total_positions = 4
	spawn_positions = 4
	allow_additional = 1
	minimal_player_age = 7
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Smartgunner"

	generate_entry_message()
		. = ..() + {"\nYou are the smartgunner. Your job is to provide heavy weapons support."}


/datum/job/marine/smartgunner/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD


/datum/job/marine/standard
	title = "Squad Marine"
	flag = ROLE_MARINE_STANDARD
	department_flag = ROLEGROUP_MARINE_SQUAD_MARINES
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	minimal_player_age = 0
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Squad Marine (PFC)"

	generate_entry_message()
		. = ..() + {"\nYou are a rank-and-file soldier of the USCM, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"}

/datum/job/marine/standard/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD
