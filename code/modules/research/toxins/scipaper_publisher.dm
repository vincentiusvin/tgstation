#define SCIPAPER_RANK_ONE   100
#define SCIPAPER_RANK_TWO   200
#define SCIPAPER_RANK_THREE 300
#define SCIPAPER_RANK_FOUR  400
#define SCIPAPER_RANK_FIVE  500

/datum/computer_file/program/scipaper_program
	filename = "ntfrontier"
	filedesc = "NT Frontier"
	category = PROGRAM_CATEGORY_SCI
	extended_desc = "Scientific paper publication and navigation software. Requires a functional disk slot."
	requires_ntnet = TRUE
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet = TRUE
	size = 12
	tgui_id = "NtosScipaper"
	var/datum/techweb/linked_techweb
	
	/// Inserted research disk.
	var/disk = 1
	/// Unpublished, temporary paper datum.
	var/datum/scientific_paper/paper_to_be = new()
	/// Here for caching reasons. Corresponds to the tab in the UI.
	var/current_tab = 1

/datum/computer_file/program/scipaper_program/run_program(mob/living/user)
	. = ..()
	linked_techweb = SSresearch.science_tech

/datum/computer_file/program/scipaper_program/ui_data()
	var/list/data = get_header_data()
	// Program Headers: Current value. Disk
	data["scirenown"] = linked_techweb.scipaper_scientific_renown
	data["scicoop"] = linked_techweb.scipaper_scientific_cooperation
	data["disk"] = disk

	var/coop_rank
	var/renown_rank

	switch(linked_techweb.scipaper_scientific_cooperation)
		if(-INFINITY to (SCIPAPER_RANK_ONE - 1))
			coop_rank = "No Cooperation"
		if(SCIPAPER_RANK_ONE to (SCIPAPER_RANK_TWO -1))
			coop_rank = "Limited Cooperation"
		if(SCIPAPER_RANK_THREE to (SCIPAPER_RANK_FOUR - 1))
			coop_rank = "Moderate Cooperation"
		if(SCIPAPER_RANK_FOUR to (SCIPAPER_RANK_FIVE - 1))
			coop_rank = "Significant Cooperation"
		if(SCIPAPER_RANK_FIVE to INFINITY)
			coop_rank = "Major Cooperation"
		else
			coop_rank = "Undefined"

	switch(linked_techweb.scipaper_scientific_renown)
		if(-INFINITY to (SCIPAPER_RANK_ONE - 1))
			renown_rank = "Obscure"
		if(SCIPAPER_RANK_ONE to (SCIPAPER_RANK_TWO -1))
			renown_rank = "Competent"
		if(SCIPAPER_RANK_THREE to (SCIPAPER_RANK_FOUR - 1))
			renown_rank = "Well-known"
		if(SCIPAPER_RANK_FOUR to (SCIPAPER_RANK_FIVE - 1))
			renown_rank = "Renowned"
		if(SCIPAPER_RANK_FIVE to INFINITY)
			renown_rank = "Leading Expertise"
		else
			renown_rank = "Undefined"

	data["renown_rank"] = renown_rank
	data["coop_rank"] = coop_rank
	data["current_tab"]  = current_tab

	// First page. Form submission.
	if(current_tab == 1)
		var/list/transcripted_gains = list("renown", "cooperation", "funding")
		for (var/individual_gains in paper_to_be.gains)
			switch (paper_to_be.gains[individual_gains])
				if(-INFINITY to 0)
					transcripted_gains[individual_gains] = "None"
				if(1 to 24)
					transcripted_gains[individual_gains] = "Little"
				if(25 to 49)
					transcripted_gains[individual_gains] = "Moderate"
				if(50 to 99)
					transcripted_gains[individual_gains] = "Significant"
				if(100 to INFINITY)
					transcripted_gains[individual_gains] = "Huge"
				else
					transcripted_gains[individual_gains] = "Undefined"
		data["gains"] = transcripted_gains

		data["title"] = paper_to_be.title
		data["author"] = paper_to_be.author
		data["et_alia"] = paper_to_be.et_alia
		data["abstract"] = paper_to_be.abstract

	// Second page. View previous
	if(current_tab == 2)
		var/list/master_paper_list = linked_techweb.published_papers
		var/list/transcribed_paper_list = list()
		for (var/datum/scientific_paper/singular_paper in master_paper_list)
			/// This list stores all the necessary information for a singular paper.
			var/list/paper_info = list("title", "author", "abstract", "yield")
			paper_info["title"] = singular_paper.title
			paper_info["author"] = singular_paper.et_alia? "[singular_paper.author] et al." : singular_paper.author
			paper_info["abstract"] = singular_paper.abstract
			paper_info["yield"] = singular_paper.gains
			var/list/transcribed_paper_ranks = list("Case Study (n=1)","Analysis (n=2)", "Comprehensive Study (n=3)", "Sytematic Reviews (n=4)", "Landmark Study (n=5)")
			if (singular_paper.rank)
				paper_info["rank"] = transcribed_paper_ranks[singular_paper.rank]
			else
				paper_info["rank"] = "Undefined"
			
			transcribed_paper_list += list(paper_info)
		data["published_papers"] = transcribed_paper_list

	return data

/datum/computer_file/program/scipaper_program/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)
		if("et_alia")
			paper_to_be.et_alia = !paper_to_be.et_alia
		// Handle the publication
		if("publish")
			publish()
		// For every change in the input, we correspond it with the paper_data list and update it.
		if("rewrite")
			if(length(params))
				for (var/changed_entry in params)
					if (changed_entry == "title")
						paper_to_be.title = params[changed_entry]
					if (changed_entry == "author")
						paper_to_be.author = params[changed_entry]
					if (changed_entry == "abstract")
						paper_to_be.abstract = params[changed_entry]
		if("change_tab")
			current_tab = params["new_tab"]
	
	SStgui.update_uis(src)

/datum/computer_file/program/scipaper_program/proc/publish()
	if(!disk)
		return

	linked_techweb.scipaper_scientific_renown += paper_to_be.gains["renown"]
	linked_techweb.scipaper_scientific_cooperation += paper_to_be.gains["cooperation"]
	
	var/datum/bank_account/dept_budget = SSeconomy.get_dep_account(ACCOUNT_SCI)
	if(dept_budget)
		dept_budget.adjust_money(paper_to_be.gains["funding"])

	linked_techweb.published_papers |= paper_to_be

	paper_to_be = new
	SStgui.update_uis(src)

	return TRUE

/datum/computer_file/program/scipaper_program/proc/update_gains()
	return
