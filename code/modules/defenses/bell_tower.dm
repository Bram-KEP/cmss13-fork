#define BELL_TOWER_RANGE 4
#define BELL_TOWER_EFFECT 6
#define BELL_TOWER_COOLDOWN 1.5 SECONDS
#define BELL_TOWER_CLOAKER_ALPHA 10

#define IMP_SLOWDOWN_TIME 3

/obj/structure/machinery/defenses/bell_tower
	name = "\improper R-1NG bell tower"
	icon = 'icons/obj/structures/machinery/defenses/bell_tower.dmi'
	desc = "A tactical advanced version of a normal alarm. Designed to trigger an old instinct ingrained in humans when they hear a wake-up alarm, for fast response."
	var/list/tripwires_placed = list()
	var/mob/last_mob_activated
	var/bell_cooldown = 0 //cooldown between BING BONG BING BONGs
	var/image/flick_image
	handheld_type = /obj/item/defenses/handheld/bell_tower

	can_be_near_defense = TRUE


/obj/structure/machinery/defenses/bell_tower/Initialize()
	. = ..()

	if(turned_on)
		setup_tripwires()
	update_icon()

/obj/structure/machinery/defenses/bell_tower/update_icon()
	..()

	overlays.Cut()
	if(stat == DEFENSE_DAMAGED)
		overlays += "[defense_type] bell_tower_destroyed"
		return

	overlays += "[defense_type] bell_tower"

/obj/structure/machinery/defenses/bell_tower/power_on_action()
	clear_tripwires()
	setup_tripwires()
	visible_message("[icon2html(src, viewers(src))] [SPAN_NOTICE("The [name] gives a short ring, as it comes alive.")]")

/obj/structure/machinery/defenses/bell_tower/power_off_action()
	clear_tripwires()
	visible_message("[icon2html(src, viewers(src))] [SPAN_NOTICE("The [name] gives a beep and powers down.")]")

/obj/structure/machinery/defenses/bell_tower/proc/clear_tripwires()
	for(var/obj/effect/bell_tripwire/FE in tripwires_placed)
		qdel(FE)

/obj/structure/machinery/defenses/bell_tower/proc/setup_tripwires()
	clear_tripwires()
	for(var/turf/T in orange(BELL_TOWER_RANGE, loc))
		if(T.density)
			continue

		var/obj/effect/bell_tripwire/FE = new /obj/effect/bell_tripwire(T, faction_group)
		FE.linked_bell = src
		tripwires_placed += FE

/obj/structure/machinery/defenses/bell_tower/proc/clear_last_mob_activated()
	last_mob_activated = null

/obj/structure/machinery/defenses/bell_tower/proc/mob_crossed(var/mob/M)
	playsound(loc, 'sound/misc/bell.ogg', 50, 0, 50)

/obj/structure/machinery/defenses/bell_tower/Destroy()
	if(last_mob_activated)
		last_mob_activated = null
	if(flick_image)
		flick_image = null
	clear_tripwires()
	return ..()


/obj/effect/bell_tripwire
	name = "flag effect"
	anchored = TRUE
	mouse_opacity = 0
	invisibility = 101
	unacidable = TRUE
	var/obj/structure/machinery/defenses/bell_tower/linked_bell
	var/faction = FACTION_LIST_MARINE

/obj/effect/bell_tripwire/New(var/turf/T, var/faction = null)
	..(T)
	if(faction)
		src.faction = faction

/obj/effect/bell_tripwire/Destroy()
	if(linked_bell)
		linked_bell.tripwires_placed -= src
		linked_bell = null
	. = ..()

/obj/effect/bell_tripwire/Crossed(var/atom/movable/A)
	if(!linked_bell)
		qdel(src)
		return

	if(!iscarbon(A))
		return

	var/mob/living/carbon/M = A
	if(M.get_target_lock(faction))
		return

	if(linked_bell.last_mob_activated == M)
		return

	if(linked_bell.bell_cooldown > world.time)
		return

	linked_bell.last_mob_activated = M

	// Clear last mob after 4 times the length of the cooldown timer, about 6 seconds
	addtimer(CALLBACK(linked_bell, /obj/structure/machinery/defenses/bell_tower.proc/clear_last_mob_activated), 4 * BELL_TOWER_COOLDOWN, TIMER_UNIQUE|TIMER_OVERRIDE)

	if(!linked_bell.flick_image)
		linked_bell.flick_image = image(linked_bell.icon, icon_state = "[linked_bell.defense_type] bell_tower_alert")
	linked_bell.flick_image.flick_overlay(linked_bell, 11)
	linked_bell.mob_crossed(M)
	M.AdjustSuperslowed(BELL_TOWER_EFFECT)
	to_chat(M, SPAN_DANGER("The frequency of the noise slows you down!"))
	linked_bell.bell_cooldown = world.time + BELL_TOWER_COOLDOWN //1.5s cooldown between RINGS

/obj/item/device/motiondetector/internal
	name = "internal motion detector"
	detector_range = 7 //yeah no offscreen bs with this

	var/obj/structure/machinery/defenses/bell_tower/md/linked_tower

/obj/item/device/motiondetector/internal/apply_debuff(mob/target)
	var/mob/living/to_apply = target

	if(istype(to_apply))
		to_apply.SetSuperslowed(2)
		to_chat(to_apply, SPAN_WARNING("You feel very heavy."))
		sound_to(to_apply, 'sound/items/detector.ogg')

/obj/structure/machinery/defenses/bell_tower/md
	name = "R-1NG motion detector tower"
	desc = "A tactical advanced version of the motion detector. Has an increased range, disrupts the activity of hostiles nearby."
	handheld_type = /obj/item/defenses/handheld/bell_tower/md
	var/obj/item/device/motiondetector/internal/md
	defense_type = "MD"

/obj/structure/machinery/defenses/bell_tower/md/setup_tripwires()
	md = new(src)
	md.linked_tower = src
	md.iff_signal = LAZYACCESS(faction_group, 1)
	md.toggle_active(null, FALSE)

	if(!md.iff_signal)
		md.iff_signal = FACTION_MARINE

/obj/structure/machinery/defenses/bell_tower/md/clear_tripwires()
	if(md)
		md.linked_tower = null
		QDEL_NULL(md)



/obj/structure/machinery/defenses/bell_tower/cloaker
	name = "camouflaged R-1NG bell tower"
	desc = "A tactical advanced version of a normal alarm. Designed to trigger an old instinct ingrained in humans when they hear a wake-up alarm, for fast response. This one is camouflaged and reinforced."
	handheld_type = /obj/item/defenses/handheld/bell_tower/cloaker
	var/cloak_alpha = BELL_TOWER_CLOAKER_ALPHA
	density = FALSE
	health = 250
	health_max = 250
	defense_type = "Cloaker"

/obj/structure/machinery/defenses/bell_tower/cloaker/Initialize()
	. = ..()
	animate(src, alpha = cloak_alpha, time = 2 SECONDS, easing = LINEAR_EASING)



/obj/item/storage/backpack/imp
	name = "IMP frame mount"
	icon = 'icons/obj/items/clothing/backpacks.dmi'
	icon_state = "bell_backpack"
	max_storage_space = 10
	worn_accessible = TRUE
	w_class = SIZE_LARGE
	flags_equip_slot = SLOT_BACK
	var/slowdown_amount = IMP_SLOWDOWN_TIME
	var/area_range = 7 //stretches 3 tiles away in all directions


/obj/item/storage/backpack/imp/equipped(mob/user, slot)
	. = ..()
	if(slot == WEAR_BACK)
		START_PROCESSING(SSobj, src)

/obj/item/storage/backpack/imp/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/storage/backpack/imp/process()
	if(!ismob(loc))
		STOP_PROCESSING(SSobj, src)
		return

	var/mob/M = loc

	if(M.back != src)
		STOP_PROCESSING(SSobj, src)
		return

	if(M.stat == DEAD || (!M.x && !M.y && !M.z))
		STOP_PROCESSING(SSobj, src)
		return

	var/list/targets = SSquadtree.players_in_range(RECT(M.x, M.y, area_range, area_range), M.z, QTREE_SCAN_MOBS | QTREE_EXCLUDE_OBSERVER)
	if(!targets)
		return

	for(var/mob/living/carbon/Xenomorph/X in targets)
		to_chat(X, SPAN_XENOWARNING("Augh! You are slowed by the incessant ringing!"))
		X.SetSuperslowed(slowdown_amount)
		playsound(X, 'sound/misc/bell.ogg', 25, 0, 13)

#undef IMP_SLOWDOWN_TIME
#undef BELL_TOWER_RANGE
#undef BELL_TOWER_EFFECT
#undef BELL_TOWER_COOLDOWN
#undef BELL_TOWER_CLOAKER_ALPHA
