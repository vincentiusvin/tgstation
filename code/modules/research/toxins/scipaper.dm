/// Scientific paper datum for retrieval and re-reading. A lot of the variables are there for fluff & flavor.
/datum/scientific_paper
	/// The title of our paper.
	var/title
	/// The principal author of our paper.
	var/author
	/// Whether this paper is co-authored or not.
	var/et_alia = FALSE
	/// Abstract.
	var/abstract
	/// The renown, cooperation, or funding gains from the paper.
	var/list/gains = list("renown" = 0, "cooperation" = 0, "funding" = 0)
	/// The class of a specific paper. Extra bonus from chaining multiple data points will get tracked here.
	var/rank = 0
	/// The references to scipaper_explosion datums. Unique.
	var/list/experiment_data

/// Various informations on companies/scientific programs/journals etc that the players can sign on to.
/datum/scipaper_programs
	/// Brief explanation of the associated company. Here for worldbuilding.
	var/flufftext
	/// The associated bonus of signing with the program. Is multiplicative rather than additive.
	var/list/bonus = list("renown" = 0, "cooperation" = 0, "funding" = 0)
	/// Extra bonus that comes from signing on. E.G. A specific company focusing in one specific field.
	var/datum/extra_bonus

/datum/toxins_experiment_data
	/** 
	 * Projected gain from an experiment. 
	 * In list form, indexed corresponding to the tier of the experiment.
	 * This is one single variable, meaning that the gains across every aspect is the same.
	 */
	var/list/gain
	/** 
	 * The variable that tracks and further influences the gain. This should be the focal point of a specific explosion.
	 * The formula for gain*tracked variable should be a logistic curve.
	 * The ideal amount of whatever influences this variable should also be visible to the player.
	 */
	var/tracked_variable
	/// The variable that influences the point equation; focal point of the experiment. In list form, indexed corresponding to the tier of the experiment.
	var/list/midpoint_amount
	/// The highest tier attainable from one experiment. Check this to see if we actually ran it.
	var/tier = 0
	/// Whether this data was purchased or not.
	var/purchased = FALSE
	/// The path to a corresponding experiment in experi-sci
	var/relevant_experiment
	/// A list will be created for experiments by the bombprocessor. This var is to indicate whether this path is a fully fledged experiment or just a functionality grouping.
	var/experiment_proper = FALSE

/**
 * Gain calculation follows a sigmoid curve.
 * f(x) = L / (1+e^(-k(x-xo)))
 * L is the upper limit. This should be the gain variable * 2.
 * k is the steepness. We keep this at an exact L/10000
 * x0 is the midpoint.
 * x is our tracked variable.
 */
/datum/scientific_paper/proc/calculate_gains_and_rank()
	// Reset and recount
	rank = 0
	
	for (var/each_gain in gains)
		gains[each_gain] = 0

	for (var/datum/toxins_experiment_data/data_point in experiment_data)
		var/gain = data_point.gain[data_point.tier]
		var/tracked_variable = data_point.tracked_variable[data_point.tier]
		var/midpoint_amount = data_point.midpoint_amount[data_point.tier]
		var/modified_gain = gain*2 / (1+NUM_E**(-(gain*2/10000)*(tracked_variable-midpoint_amount)))
		for (var/each_gain in gains)
			gains[each_gain] += modified_gain
		
	// Simple bonus, in the increment of .25 for each research data published.
	var/n_number = length(experiment_data)
	var/bonus = list(1,1.25,1.5,1.75,2)
	for (var/each_gain in gains)
		gains[each_gain] *= bonus[n_number]

	rank = n_number
