#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map_stocks>
#include <xs>

#define PLUGIN  "Restore Triggers"
#define VERSION "0.3"
#define AUTHOR  "rtxA"

#define DEBUG 1

#define Pev_SavedUseAdress pev_iuser4

public plugin_precache() {
	RegisterHam(Ham_Spawn, "multi_manager", "OnMultiManagerSpawn_Post", true);
	RegisterHam(Ham_Spawn, "trigger_once", "OnTriggerOnceSpawn_Post", true);
	RegisterHam(Ham_Think, "trigger_once", "OnTriggerOnceThink_Pre");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if defined DEBUG
	register_concmd("triggers_restore", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_multi_manager", "native_restore_multi_manager");
	register_native("hl_restore_trigger_auto", "native_restore_trigger_auto");
	register_native("hl_restore_trigger_once", "native_restore_trigger_once");
	register_native("hl_restore_trigger_push", "native_restore_trigger_push");
}

#if defined DEBUG
public CmdRestoreEntId(id) {
	RestoreAllTriggerOnce();
	RestoreAllMultiManager();
	RestoreAllTriggerPush();

	return PLUGIN_HANDLED;
}
#endif

public OnTriggerOnceSpawn_Post(ent) {
    // set to -2.0, this way we can make sure the entity isn't deleted
    set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
}

public OnTriggerOnceThink_Pre(ent) {
    if (get_ent_data_float(ent, "CBaseToggle", "m_flWait") == -2.0) {
        set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
        return HAM_SUPERCEDE;
    }
    return HAM_IGNORED;
}

RestoreTriggerOnce(ent) {
    // set to -2.0, this way we can make sure the entity isn't deleted
    set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
    dllfunc(DLLFunc_Spawn, ent);
}

RestoreAllTriggerOnce() {
	new ent;
	while ((ent = find_ent_by_class(ent, "trigger_once"))) {
        RestoreTriggerOnce(ent);
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

RestoreTriggerAuto(ent) {
	set_pev(ent, pev_nextthink, get_gametime() + 0.1);
}

RestoreAllTriggerAuto() {
	new ent;
	while ((ent = find_ent_by_class(ent, "trigger_auto"))) {
        RestoreTriggerAuto(ent);
	}
}

public OnMultiManagerSpawn_Post(ent) {
	set_pev(ent, Pev_SavedUseAdress, get_ent_data(ent, "CBaseEntity", "m_pfnUse"));
}

RestoreMultiManager(ent) {
	if (IsClone(ent)) {
		remove_entity(ent);
		return;
	}

	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseEntity", "m_pfnUse", pev(ent, Pev_SavedUseAdress));
	set_ent_data(ent, "CMultiManager", "m_index", 0);
}

RestoreAllMultiManager() {
	new ent;
	while ((ent = find_ent_by_class(ent, "multi_manager"))) {
        RestoreMultiManager(ent);
	}
}

IsClone(ent) {
	return pev(ent, pev_spawnflags) & SF_MULTIMAN_CLONE ? true : false;
}

public native_restore_trigger_once(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllTriggerOnce();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreTriggerOnce(ent);

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

public native_restore_trigger_auto(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllTriggerAuto();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreTriggerAuto(ent);

	return true;
}

public native_restore_multi_manager(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllMultiManager();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreMultiManager(ent);

	return true;
}
