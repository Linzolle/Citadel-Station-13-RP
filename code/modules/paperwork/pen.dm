/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = ITEMSIZE_TINY
	throw_speed = 7
	throw_range = 15
	matter = list(DEFAULT_WALL_MATERIAL = 10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2


/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/pen/fountain
	desc = "A well made fountain pen."
	icon_state = "pen_fountain"

/obj/item/pen/multi
	desc = "It's a pen with multiple colors of ink!"
	var/selectedColor = 1
	var/colors = list("black","blue","red")

/obj/item/pen/multi/attack_self(mob/user)
	if(++selectedColor > 3)
		selectedColor = 1

	colour = colors[selectedColor]

	if(colour == "black")
		icon_state = "pen"
	else
		icon_state = "pen_[colour]"

	to_chat(user, "<span class='notice'>Changed color to '[colour].'</span>")

/obj/item/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/click
	desc = "It's a black ink pen. It urges you to click it."

/obj/item/pen/click/attack_self(mob/user as mob)
	if(user.a_intent == INTENT_HELP)
		user.visible_message("<span class='notice'><b>\The [user]</b> clicks [src] idly.</span>","<span class='notice'>You click [src] idly.</span>")
		playsound(user, 'sound/weapons/flipblade.ogg', 20, 1)
	else if (user.a_intent == I_HURT)
		user.visible_message("<span class='warning'><b>\The [user]</b> clicks [src] angrily!</span>","<span class='warning'>You click [src] angrily!</span>")
		playsound(user, 'sound/weapons/flipblade.ogg', 20, 1)
	else if (user.a_intent == INTENT_GRAB)
		user.visible_message("<span class='warning'><b>\The [user]</b> spins [src] in their fingers!</span>","<span class='warning'>You spin [src] in your fingers!</span>")
	else
		user.visible_message("<span class='notice'><b>\The [user]</b> clicks [src] rhythmically.</span>","<span class='notice'>You click [src] rhythmically.</span>")
		playsound(user, 'sound/weapons/flipblade.ogg', 20, 1)

/*
 * Reagent pens
 */

/obj/item/pen/reagent
	flags = OPENCONTAINER
	origin_tech = list(TECH_MATERIAL = 2, TECH_ILLEGAL = 5)

/obj/item/pen/reagent/New()
	..()
	create_reagents(30)

/obj/item/pen/reagent/attack(mob/living/M as mob, mob/user as mob)

	if(!istype(M))
		return

	. = ..()

	if(M.can_inject(user,1))
		if(reagents.total_volume)
			if(M.reagents)
				var/contained = reagents.get_reagents()
				var/trans = reagents.trans_to_mob(M, 30, CHEM_BLOOD)
				add_attack_logs(user,M,"Injected with [src.name] containing [contained], trasferred [trans] units")

/*
 * Sleepy Pens
 */
/obj/item/pen/reagent/sleepy
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	origin_tech = list(TECH_MATERIAL = 2, TECH_ILLEGAL = 5)

/obj/item/pen/reagent/sleepy/New()
	..()
	reagents.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N


/*
 * Parapens
 */
/obj/item/pen/reagent/paralysis
	origin_tech = list(TECH_MATERIAL = 2, TECH_ILLEGAL = 5)

/obj/item/pen/reagent/paralysis/New()
	..()
	reagents.add_reagent("zombiepowder", 5)
	reagents.add_reagent("cryptobiolin", 10)

/*
 * Chameleon pen
 */
/obj/item/pen/chameleon
	var/signature = ""

/obj/item/pen/chameleon/attack_self(mob/user as mob)
	/*
	// Limit signatures to official crew members
	var/personnel_list[] = list()
	for(var/datum/data/record/t in data_core.locked) //Look in data core locked.
		personnel_list.Add(t.fields["name"])
	personnel_list.Add("Anonymous")

	var/new_signature = input("Enter new signature pattern.", "New Signature") as null|anything in personnel_list
	if(new_signature)
		signature = new_signature
	*/
	signature = sanitize(input("Enter new signature. Leave blank for 'Anonymous'", "New Signature", signature))

/obj/item/pen/proc/get_signature(var/mob/user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/pen/chameleon/get_signature(var/mob/user)
	return signature ? signature : "Anonymous"

/obj/item/pen/chameleon/verb/set_colour()
	set name = "Change Pen Colour"
	set category = "Object"

	var/list/possible_colours = list ("Yellow", "Green", "Pink", "Blue", "Orange", "Cyan", "Red", "Invisible", "Black")
	var/selected_type = input("Pick new colour.", "Pen Colour", null, null) as null|anything in possible_colours

	if(selected_type)
		switch(selected_type)
			if("Yellow")
				colour = COLOR_YELLOW
			if("Green")
				colour = COLOR_LIME
			if("Pink")
				colour = COLOR_PINK
			if("Blue")
				colour = COLOR_BLUE
			if("Orange")
				colour = COLOR_ORANGE
			if("Cyan")
				colour = COLOR_CYAN
			if("Red")
				colour = COLOR_RED
			if("Invisible")
				colour = COLOR_WHITE
			else
				colour = COLOR_BLACK
		to_chat(usr, "<span class='info'>You select the [lowertext(selected_type)] ink container.</span>")


/*
 * Crayons
 */

/obj/item/pen/crayon
	name = "crayon"
	desc = "A colourful crayon. Please refrain from eating it or putting it in your nose."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = ITEMSIZE_TINY
	attack_verb = list("attacked", "coloured")
	colour = "#FF0000" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes

/obj/item/pen/crayon/suicide_act(mob/user)
	var/datum/gender/TU = gender_datums[user.get_visible_gender()]
	viewers(user) << "<font color='red'><b>[user] is jamming the [src.name] up [TU.his] nose and into [TU.his] brain. It looks like [TU.he] [TU.is] trying to commit suicide.</b></font>"
	return (BRUTELOSS|OXYLOSS)

/obj/item/pen/crayon/New()
	name = "[colourName] crayon"

/obj/item/pen/crayon/marker
	name = "marker"
	desc = "A chisel-tip permanent marker. Hopefully non-toxic."
	icon_state = "markerred"

/obj/item/pen/crayon/marker/New()
	name = "[colourName] marker"
