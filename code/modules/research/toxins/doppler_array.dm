#define PRINTER_TIMEOUT 40

/obj/machinery/doppler_array
	name = "doppler array"
	desc = "A highly precise directional sensor array which measures the physical parameters of an object. Configured to fixate on any item with a doppler beacon configured."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	base_icon_state = "tdoppler"
	density = TRUE
	verb_say = "states coldly"
	var/cooldown = 10
	var/next_announce = 0

/obj/machinery/doppler_array/Initialize()
	. = ..()

/obj/machinery/doppler_array/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TachyonArray", name)
		ui.open()

/obj/machinery/doppler_array/ui_data(mob/user)
	var/list/data = list()
	return data

/obj/machinery/doppler_array/ui_act(action, list/params)
	. = ..()
	if(.)
		return

/obj/machinery/doppler_array/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		if(!anchored && !isinspace())
			set_anchored(TRUE)
			to_chat(user, span_notice("You fasten [src]."))
		else if(anchored)
			set_anchored(FALSE)
			to_chat(user, span_notice("You unfasten [src]."))
		I.play_tool_sound(src)
		return
	return ..()

/obj/machinery/doppler_array/proc/sense_experiment(datum/source, turf/epicenter)
	SIGNAL_HANDLER

	if(machine_stat & NOPOWER)
		return FALSE

	var/turf/zone = get_turf(src)
	if(zone.z != epicenter.z)
		return FALSE

/obj/machinery/doppler_array/powered()
	return anchored && ..()

/obj/machinery/doppler_array/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]-broken"
		return ..()
	icon_state = "[base_icon_state][powered() ? null : "-off"]"
	return ..()

/obj/item/assembly/doppler_beacon
	name = "doppler beacon"
	desc = "A location transmitter that allows a doppler array to fixate and detect physical phenomena."
	icon_state = "freezer"