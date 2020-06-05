#include <amxmisc>
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#define PLUGIN  "Restore Triggers"
#define VERSION "0.1"
#define AUTHOR  "rtxA"

#define DEBUG 1

public plugin_precache() {
	RegisterHam(Ham_Spawn, "trigger_once", "OnTriggerSpawn_Post", true);
	RegisterHam(Ham_Think, "trigger_once", "OnTriggerThink_Pre");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if defined DEBUG
	register_concmd("triggers_rentid", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_trigger_once", "native_restore_trigger_once");
	register_native("hl_restore_trigger_push", "native_restore_trigger_push");
}

#if defined DEBUG
public CmdRestoreEntId(id) {
	new ent = read_argv_int(1);

	if (!ent) {
		RestoreAllTriggers();
		RestoreAllTriggerPush();
	} else {
		if (pev_valid(ent) != 2) {
			console_print(id, "Invalid entity: %d", ent);
			return PLUGIN_HANDLED;
		}

		new classname[32];
		pev(ent, pev_classname, classname, charsmax(classname));

	}

	return PLUGIN_HANDLED;
}
#endif

public OnTriggerSpawn_Post(ent) {
    // set to -2.0, this way we can make sure the entity isn't deleted
    set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
}

public OnTriggerThink_Pre(ent) {
    if (get_ent_data_float(ent, "CBaseToggle", "m_flWait") == -2.0) {
        set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
        return HAM_SUPERCEDE;
    }
    return HAM_IGNORED;
}

RestoreTrigger(ent) {
    // set to -2.0, this way we can make sure the entity isn't deleted
    set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
    dllfunc(DLLFunc_Spawn, ent);
}

RestoreAllTriggers() {
	new ent;
	while ((ent = find_ent_by_class(ent, "trigger_once"))) {
        RestoreTrigger(ent);
	}
}

RestoreTriggerPush(ent) {
	// is it required to restore movedir? no idea but regamedll does this for a reason
	new Float:movedir[3];
	pev(ent, pev_movedir, movedir);
	ExecuteHam(Ham_Spawn, ent);
	set_pev(ent, pev_movedir, movedir);
}

RestoreAllTriggerPush() {
	new ent;
	while ((ent = find_ent_by_class(ent, "trigger_push"))) {
        RestoreTriggerPush(ent);
	}
}


public native_restore_trigger_once(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllTriggers();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreTrigger(ent);

	return true;
}

public native_restore_trigger_push(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllTriggerPush();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreTriggerPush(ent);

	return true;
}
