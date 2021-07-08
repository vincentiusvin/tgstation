/** 
 * A toxins experiment datum. What gives the science in the first place. Also what shows up in the debriefer.
 * A disk should contain several of these in a list. Only one should get picked for the final paper.
 */
/datum/experiment/toxins
	name = "Toxin Research"
	description = "An experiment conducted in the toxins subdepartment."
	exp_tag = "Toxins"
	performance_hint = "Perform or purchase research experiments dictated by the bomb processor in the toxins lab."
	/// Whether this experiment has been purchased or not.
	var/experiment_data_path
	var/list/last_techweb_published_data = list()

// If any tier of experiment is completed, give the discounts
/datum/experiment/toxins/is_complete()
	for (var/published_data in last_techweb_published_data)
		if (istype(published_data, experiment_data_path))
			return TRUE
	return FALSE
		
/datum/experiment/toxins/check_progress()
	var/status_message = "You must publish or purchase a paper on [name]"
	. += EXPERIMENT_PROG_BOOL(status_message, is_complete())

/datum/experiment/toxins/perform_experiment_actions(techweb_scipaper_explosion)
	return is_complete()

/datum/experiment/toxins/actionable(datum/component/experiment_handler/experiment_handler)
	return !is_complete()
