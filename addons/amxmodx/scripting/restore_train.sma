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

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_tracktrain", "OnTrackTrainSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if defined DEBUG
	register_concmd("tt_rentid", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_tracktrain", "native_restore_tracktrain");
}

#if defined DEBUG
public CmdRestoreEntId(id) {
	new ent = read_argv_int(1);

	if (!ent) {
		RestoreAllTrackTrain();
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

public OnTrackTrainSpawn_Post(ent) {
	set_pev(ent, Pev_SavedThinkAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
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
