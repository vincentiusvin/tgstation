/// View possible explosions, test if a bomb will succeed.
/obj/machinery/scipaper_bombprocessor
	name = "Bomb processor"
	desc = "Runs explosion calculation to try and predict explosive effects."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"

	// Input informations
	var/obj/item/transfer_valve/inserted_valve
	var/datum/gas_mixture/first_gasmix
	var/datum/gas_mixture/second_gasmix
	/// Combined result of the first two tanks.
	var/datum/gas_mixture/combined_gasmix

	var/list/all_scipaper_explosion = list()

	/// Here for the UI, tracks the amounts of reaction that has occured. 1 means valve opened but not reacted.
	var/reaction_increment = 0

/obj/machinery/scipaper_bombprocessor/Initialize()
	. = ..()
	for (var/experiment_data_path in subtypesof(/datum/toxins_experiment_data))
		// Initialized just to check if its an experiment proper.
		var/datum/toxins_experiment_data/experiment_data_initialized = new experiment_data_path
		if (experiment_data_initialized.experiment_proper)
			all_scipaper_explosion += experiment_data_path
		
/obj/machinery/scipaper_bombprocessor/attackby(obj/item/transfer_valve/ttv)
	. = ..()
	if(!istype(ttv))
		return
	reset_stored_gasmixes()
	inserted_valve = ttv
	register_gasmixes()

/obj/machinery/scipaper_bombprocessor/proc/register_gasmixes()
	var/obj/item/tank/tank_one = inserted_valve.tank_one
	var/obj/item/tank/tank_two = inserted_valve.tank_two
	first_gasmix = tank_one?.return_air()
	second_gasmix = tank_two?.return_air()

/obj/machinery/scipaper_bombprocessor/proc/simulate_valve()	

	if(reaction_increment == 0)
		combined_gasmix = new(70)
		combined_gasmix.volume = first_gasmix.volume + second_gasmix.volume
		combined_gasmix.merge(first_gasmix.copy())
		combined_gasmix.merge(second_gasmix.copy())
	else
		combined_gasmix.react()
	
	reaction_increment += 1

/obj/machinery/scipaper_bombprocessor/proc/reset_stored_gasmixes()
	qdel(combined_gasmix)
	qdel(first_gasmix)
	qdel(second_gasmix)
	qdel(inserted_valve)
	reaction_increment = 0

/obj/machinery/scipaper_bombprocessor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BombProcessor")
		ui.open()


/obj/machinery/scipaper_bombprocessor/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("react")
			simulate_valve()
		if("eject")
			return


/obj/machinery/scipaper_bombprocessor/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	/** GAS PARSING STRUCTURE
	 * - parsed_gasmixes (l)
	 * -- gasmix (d)
	 * --- name (str)
	 * --- gases (l)
	 * ---- individual gases (d)
	 * ----- gas name (str)
	 * ----- gas moles (int)
	 * --- temperature (int)
	 * --- volume (int)
	 * --- pressure (int)
	 */
	var/list/parsed_gasmixes = list()
	for(var/datum/gas_mixture/gasmix as anything in list(first_gasmix,second_gasmix, combined_gasmix))
		var/singular_gasmix_data = list()
		var/gases = list()
		for(var/gas_id in gasmix?.gases)
			var/list/singular_gas = list()
			singular_gas["gas_name"] = gasmix.gases[gas_id][GAS_META][META_GAS_NAME]
			singular_gas["gas_mole"] = gasmix.gases[gas_id][MOLES]
			gases += list(singular_gas)
		singular_gasmix_data["total_moles"] = gasmix?.total_moles()
		singular_gasmix_data["gases"] = gases 
		singular_gasmix_data["temperature"] = gasmix?.temperature
		singular_gasmix_data["volume"] = gasmix?.volume
		singular_gasmix_data["pressure"] = gasmix?.return_pressure()
		parsed_gasmixes += list(singular_gasmix_data)

	parsed_gasmixes[1]["name"] = "Tank One"
	parsed_gasmixes[2]["name"] = "Tank Two"
	parsed_gasmixes[3]["name"] = "Combined Gasmix"

	data["tank_gasmixes"] += list(parsed_gasmixes[1], parsed_gasmixes[2])
	data["combined_gasmix"] += parsed_gasmixes[3]

	data["reaction_increment"] = reaction_increment
	
	return data
	
