/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	appearance_flags = TILE_BOUND|PIXEL_SCALE|NO_CLIENT_COLOR
	layer = LAYER_HUD_BASE
	plane = PLANE_PLAYER_HUD
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.

/obj/screen/Destroy()
	master = null
	return ..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480


/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/storage))
			var/obj/item/storage/S = master
			S.close(usr)
	return 1


/obj/screen/item_action
	var/obj/item/owner

/obj/screen/item_action/Destroy()
	. = ..()
	owner = null

/obj/screen/item_action/Click()
	if(!usr || !owner)
		return 1
	if(!usr.canClick())
		return

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return 1

	if(!(owner in usr))
		return 1

	owner.ui_action_click()
	return 1

/obj/screen/grab
	name = "grab"

/obj/screen/grab/Click()
	var/obj/item/grab/G = master
	G.s_click(src)
	return 1

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return


/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click()
	if(!usr.canClick())
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			usr.ClickOn(master)
	return 1

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_TORSO

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = BP_R_FOOT
				if(17 to 22)
					selecting = BP_L_FOOT
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = BP_R_LEG
				if(17 to 22)
					selecting = BP_L_LEG
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = BP_R_HAND
				if(12 to 20)
					selecting = BP_GROIN
				if(21 to 24)
					selecting = BP_L_HAND
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = BP_R_ARM
				if(12 to 20)
					selecting = BP_TORSO
				if(21 to 24)
					selecting = BP_L_ARM
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = BP_HEAD
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = O_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = O_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = O_EYES

	if(old_selecting != selecting)
		update_icon()
	return 1

/obj/screen/zone_sel/proc/set_selected_zone(bodypart)
	var/old_selecting = selecting
	selecting = bodypart
	if(old_selecting != selecting)
		update_icon()

/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")


/obj/screen/Click(location, control, params)
	if(!usr)	return 1
	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()

		if("mov_intent")
			if(isliving(usr))
				if(iscarbon(usr))
					var/mob/living/carbon/C = usr
					if(C.legcuffed)
						to_chat(C, "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>")
						C.m_intent = "walk"	//Just incase
						C.hud_used.move_intent.icon_state = "walking"
						return 1
				var/mob/living/L = usr
				switch(L.m_intent)
					if("run")
						L.m_intent = "walk"
						L.hud_used.move_intent.icon_state = "walking"
					if("walk")
						L.m_intent = "run"
						L.hud_used.move_intent.icon_state = "running"
		if("m_intent")
			if(!usr.m_int)
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("Reset Machine")
			usr.unset_machine()
		if("internal")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.stat && !C.stunned && !C.paralysis && !C.restrained())
					if(C.internal)
						C.internal = null
						to_chat(C, "<span class='notice'>No longer running on internals.</span>")
						if(C.internals)
							C.internals.icon_state = "internal0"
					else

						var/no_mask
						if(!(C.wear_mask && C.wear_mask.item_flags & AIRTIGHT))
							var/mob/living/carbon/human/H = C
							if(!(H.head && H.head.item_flags & AIRTIGHT))
								no_mask = 1

						if(no_mask)
							to_chat(C, "<span class='notice'>You are not wearing a suitable mask or helmet.</span>")
							return 1
						else
							var/list/nicename = null
							var/list/tankcheck = null
							var/breathes = "oxygen"    //default, we'll check later
							var/list/contents = list()
							var/from = "on"

							if(ishuman(C))
								var/mob/living/carbon/human/H = C
								breathes = H.species.breath_type
								nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
								tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)
							else
								nicename = list("right hand", "left hand", "back")
								tankcheck = list(C.r_hand, C.l_hand, C.back)

							// Rigs are a fucking pain since they keep an air tank in nullspace.
							if(istype(C.back,/obj/item/rig))
								var/obj/item/rig/rig = C.back
								if(rig.air_supply && !rig.offline)
									from = "in"
									nicename |= "hardsuit"
									tankcheck |= rig.air_supply

							for(var/i=1, i<tankcheck.len+1, ++i)
								if(istype(tankcheck[i], /obj/item/tank))
									var/obj/item/tank/t = tankcheck[i]
									if (!isnull(t.manipulated_by) && t.manipulated_by != C.real_name && findtext(t.desc,breathes))
										contents.Add(t.air_contents.total_moles)	//Someone messed with the tank and put unknown gasses
										continue					//in it, so we're going to believe the tank is what it says it is
									switch(breathes)
																		//These tanks we're sure of their contents
										if("nitrogen") 							//So we're a bit more picky about them.

											if(t.air_contents.gas["nitrogen"] && !t.air_contents.gas["oxygen"])
												contents.Add(t.air_contents.gas["nitrogen"])
											else
												contents.Add(0)

										if ("oxygen")
											if(t.air_contents.gas["oxygen"] && !t.air_contents.gas["phoron"])
												contents.Add(t.air_contents.gas["oxygen"])
											else
												contents.Add(0)

										// No races breath this, but never know about downstream servers.
										if ("carbon dioxide")
											if(t.air_contents.gas["carbon_dioxide"] && !t.air_contents.gas["phoron"])
												contents.Add(t.air_contents.gas["carbon_dioxide"])
											else
												contents.Add(0)

										// And here's for the Vox
										if ("phoron")
											if(t.air_contents.gas["phoron"] && !t.air_contents.gas["oxygen"])
												contents.Add(t.air_contents.gas["phoron"])
											else
												contents.Add(0)


								else
									//no tank so we set contents to 0
									contents.Add(0)

							//Alright now we know the contents of the tanks so we have to pick the best one.

							var/best = 0
							var/bestcontents = 0
							for(var/i=1, i <  contents.len + 1 , ++i)
								if(!contents[i])
									continue
								if(contents[i] > bestcontents)
									best = i
									bestcontents = contents[i]


							//We've determined the best container now we set it as our internals

							if(best)
								to_chat(C, "<span class='notice'>You are now running on internals from [tankcheck[best]] [from] your [nicename[best]].</span>")
								C.internal = tankcheck[best]


							if(C.internal)
								if(C.internals)
									C.internals.icon_state = "internal1"
							else
								to_chat(C, "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>")
		if("act_intent")
			usr.a_intent_change("right")
		if(INTENT_HELP)
			usr.a_intent = INTENT_HELP
			usr.hud_used.action_intent.icon_state = "intent_help"
		if(I_HURT)
			usr.a_intent = I_HURT
			usr.hud_used.action_intent.icon_state = "intent_harm"
		if(INTENT_GRAB)
			usr.a_intent = INTENT_GRAB
			usr.hud_used.action_intent.icon_state = "intent_grab"
		if(INTENT_DISARM)
			usr.a_intent = INTENT_DISARM
			usr.hud_used.action_intent.icon_state = "intent_disarm"

		if("pull")
			usr.stop_pulling()
		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			if(usr.client)
				usr.client.drop_item()

		if("module")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
//				if(R.module)
//					R.hud_used.toggle_show_robot_modules()
//					return 1
				R.pick_module()

		if("inventory")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.hud_used.toggle_show_robot_modules()
					return 1
				else
					to_chat(R, "You haven't selected a module yet.")

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.uneq_active()
					R.hud_used.update_robot_modules_display()
				else
					to_chat(R, "You haven't selected a module yet.")

		if("module1")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(1)

		if("module2")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(2)

		if("module3")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(3)

		if("AI Core")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.view_core()

		if("Show Camera List")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/camera = input(AI) in AI.get_camera_list()
				AI.ai_camera_list(camera)

		if("Track With Camera")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/target_name = input(AI) in AI.trackable_mobs()
				AI.ai_camera_track(target_name)

		if("Toggle Camera Light")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.toggle_camera_light()

		if("Crew Monitoring")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.subsystem_crew_monitor()

		if("Show Crew Manifest")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_roster()

		if("Show Alerts")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.subsystem_alarm_monitor()

		if("Announcement")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_announcement()

		if("Call Emergency Shuttle")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_call_shuttle()

		if("State Laws")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_checklaws()

		if("PDA - Send Message")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.aiPDA.cmd_send_pdamesg(usr)

		if("PDA - Show Message Log")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.aiPDA.cmd_show_message_log(usr)

		if("Take Image")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.take_image()

		if("View Images")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.view_images()
		else
			return attempt_vr(src,"Click_vr",list(location,control,params)) //VOREStation Add - Additional things.
	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(!usr.canClick())
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
	return 1

// Hand slots are special to handle the handcuffs overlay
/obj/screen/inventory/hand
	var/image/handcuff_overlay

/obj/screen/inventory/hand/update_icon()
	..()
	if(!hud)
		return
	if(!handcuff_overlay)
		var/state = (hud.l_hand_hud_object == src) ? "l_hand_hud_handcuffs" : "r_hand_hud_handcuffs"
		handcuff_overlay = image("icon"='icons/mob/screen_gen.dmi', "icon_state"=state)
	overlays.Cut()
	if(hud.mymob && iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			overlays |= handcuff_overlay
