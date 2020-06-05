#include <amxmisc>
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#define PLUGIN  "Restore Train"
#define VERSION "0.1"
#define AUTHOR  "rtxA"

#define DEBUG 1

#define Pev_SavedThinkAdress 	pev_iuser4
#define Pev_FirstTarget 		pev_iuser3
#define Pev_StartPos			pev_oldorigin

public plugin_precache() {
	RegisterHam(Ham_Activate, "func_train", "OnTrainActivate_Pre");
	RegisterHam(Ham_Activate, "func_train", "OnTrainActivate_Post", true);
	RegisterHam(Ham_Spawn, "func_tracktrain", "OnTrackTrainSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if defined DEBUG
	register_concmd("train_rentid", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_train", "native_restore_train");
	register_native("hl_restore_tracktrain", "native_restore_tracktrain");
}

#if defined DEBUG
public CmdRestoreEntId(id) {
	new ent = read_argv_int(1);

	if (!ent) {
		RestoreAllTrackTrain();
		RestoreAllTrain();
	} else {
		if (pev_valid(ent) != 2) {
			console_print(id, "Invalid entity: %d", ent);
			return PLUGIN_HANDLED;
		}

		new classname[32];
		pev(ent, pev_classname, classname, charsmax(classname));

		if (equal(classname, "func_tracktrain"))
			RestoreTrackTrain(ent);
	}

	return PLUGIN_HANDLED;
}
#endif

// warning: do not try to get first target at ::Spawn(), there's a big chance
// that the path_corner that is the first target hasn't spawned yet
public OnTrainActivate_Pre(ent) {
	if (!get_ent_data(ent, "CFuncTrain", "m_activated")) {
		new target[32];
		pev(ent, pev_target, target, charsmax(target));

		// save first target for future restore
		new firstTarget = find_ent_by_tname(0, target);
		set_pev(ent, Pev_FirstTarget, firstTarget);
	}
	return HAM_IGNORED;
}

public OnTrainActivate_Post(ent) {
	if (get_ent_data(ent, "CFuncTrain", "m_activated")) {
		// save start position for future restore
		new Float:origin[3];
		pev(ent, pev_origin, origin);
		set_pev(ent, Pev_StartPos, origin);
	}
}

RestoreTrain(ent) {
	new Float:speed;
	pev(ent, pev_speed, speed)
	if (speed == 0.0)
		set_pev(ent, pev_speed, 0.0);

	new Float:dmg;
	pev(ent, pev_dmg, dmg);
	if (dmg == 0.0)
		set_pev(ent, pev_dmg, 2.0);
	
	set_pev(ent, pev_movetype, MOVETYPE_PUSH);
	
	// restore ent to his original position
	new Float:startPos[3];
	pev(ent, Pev_StartPos, startPos);
	engfunc(EngFunc_SetOrigin, ent, startPos);
	
	if (get_ent_data_float(ent, "CBasePlatTrain", "m_volume") == 0.0)
		set_ent_data_float(ent, "CBasePlatTrain", "m_volume", 0.85);
	
	// restore ent target to his first target
	new firstTarget = pev(ent, Pev_FirstTarget);

	if (firstTarget != FM_NULLENT) {
		new target[32];
		pev(firstTarget, pev_targetname, target, charsmax(target));
		set_pev(ent, pev_target, target);
	}

	set_ent_data_entity(ent, "CFuncTrain", "m_pevCurrentTarget", firstTarget);

	// cancel any movement being done
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseToggle", "m_pfnCallWhenMoveDone", 0);
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0});
	set_pev(ent, pev_avelocity, Float:{0.0, 0.0, 0.0});

	set_ent_data(ent, "CFuncTrain", "m_activated", false);
	ExecuteHam(Ham_Activate, ent);
}

RestoreAllTrain() {
	new ent;
	while ((ent = find_ent_by_class(ent, "func_train"))) {
		RestoreTrain(ent);
	}
}

public OnTrackTrainSpawn_Post(ent) {
	set_pev(ent, Pev_SavedThinkAdress, get_ent_data(ent, "CBaseEntity", "m_pfnThink"));	
}

RestoreTrackTrain(ent) {	
	ResetPosTrackTrain(ent);

	// return back entity think
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", pev(ent, Pev_SavedThinkAdress));
	new Float:ltime;
	pev(ent, pev_ltime, ltime);
	set_pev(ent, pev_nextthink, ltime + 0.1);
}

ResetPosTrackTrain(ent) {
	// cancel any movement being done
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseToggle", "m_pfnCallWhenMoveDone", 0);

	set_pev(ent, pev_speed, 0);
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0});
	set_pev(ent, pev_avelocity, Float:{0.0, 0.0, 0.0});
	set_pev(ent, pev_impulse, floatround(get_ent_data_float(ent, "CFuncTrackTrain", "m_speed"), floatround_tozero));

	set_ent_data_float(ent, "CFuncTrackTrain", "m_dir", 1.0);

	// return ent to his origina pos
	new Float:oldorigin[3];
	pev(ent, pev_oldorigin, oldorigin);
	engfunc(EngFunc_SetOrigin, ent, oldorigin);
}

RestoreAllTrackTrain() {
	new ent;
	while ((ent = find_ent_by_class(ent, "func_tracktrain"))) {
		RestoreTrackTrain(ent);
	}
}

public native_restore_train(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllTrain();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreTrain(ent);

	return true;
}

public native_restore_tracktrain(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllTrackTrain();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreTrackTrain(ent);

	return true;
}
