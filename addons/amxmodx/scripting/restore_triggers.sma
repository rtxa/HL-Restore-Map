#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>
#include <xs>

#define PLUGIN  "Restore Triggers"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

#define Pev_SavedUseAdress pev_iuser4

public plugin_precache() {
	// multi_manager
	RegisterHam(Ham_Spawn, "multi_manager", "OnMultiManagerSpawn_Post", true);

	// trigger_once
	RegisterHam(Ham_Spawn, "trigger_once", "OnTriggerOnceSpawn_Post", true);
	RegisterHam(Ham_Think, "trigger_once", "OnTriggerOnceThink_Pre");

	// trigger_multiple
	RegisterHam(Ham_Spawn, "trigger_multiple", "OnTriggerMultipleSpawn_Post", true);
	RegisterHam(Ham_Think, "trigger_multiple", "OnTriggerMultipleThink_Pre");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("multi_manager", "RestoreMultiManager");
	hl_restore_register("multisource", "RestoreMultiSource");
	hl_restore_register("trigger_auto", "RestoreTriggerAuto");
	hl_restore_register("trigger_once", "RestoreTriggerOnce");
	hl_restore_register("trigger_push", "RestoreTriggerPush");
	hl_restore_register("trigger_hurt", "RestoreTriggerHurt");
	hl_restore_register("trigger_multiple", "RestoreTriggerMultiple");
}

// ================= trigger_multiple ===========================

// note: i didn't feel the need to restore this but map
// deathrun_barbie_csbr uses a trigger_multiple in a unexpected way
// it sets the wait time to less than 0, acting like a trigger_once
// so it needs to get restored too
public OnTriggerMultipleSpawn_Post(ent) {
	if (get_ent_data_float(ent, "CBaseToggle", "m_flWait") <= 0)
		set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
}

public OnTriggerMultipleThink_Pre(ent) {
	if (get_ent_data_float(ent, "CBaseToggle", "m_flWait") == -2.0) {
		set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public RestoreTriggerMultiple(ent) {
	set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
	dllfunc(DLLFunc_Spawn, ent);
}

// ================= trigger_once ===========================

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

public RestoreTriggerOnce(ent) {
    // set to -2.0, this way we can make sure the entity isn't deleted
    set_ent_data_float(ent, "CBaseToggle", "m_flWait", -2.0)
    dllfunc(DLLFunc_Spawn, ent);
}

// ================= trigger_push ===========================

public RestoreTriggerPush(ent) {
	// is it required to restore movedir? no idea but regamedll does this for a reason
	new Float:movedir[3];
	pev(ent, pev_movedir, movedir);
	ExecuteHam(Ham_Spawn, ent);
	set_pev(ent, pev_movedir, movedir);
}

// ================= trigger_hurt ===========================

public RestoreTriggerHurt(ent) {
	new Float:mins[3], Float:maxs[3];

	pev(ent, pev_mins, mins);
	pev(ent, pev_maxs, maxs);

	// InitTrigger() is about to destroy the size
	ExecuteHam(Ham_Spawn, ent);

	engfunc(EngFunc_SetSize, ent, mins, maxs);
}

// ================= trigger_auto ===========================

public RestoreTriggerAuto(ent) {
	set_pev(ent, pev_nextthink, get_gametime() + 0.1);
}

// ================= multi_manager ===========================

public OnMultiManagerSpawn_Post(ent) {
	set_pev(ent, Pev_SavedUseAdress, get_ent_data(ent, "CBaseEntity", "m_pfnUse"));
}

public RestoreMultiManager(ent) {
	if (IsClone(ent)) {
		remove_entity(ent);
		return;
	}

	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseEntity", "m_pfnUse", pev(ent, Pev_SavedUseAdress));
	set_ent_data(ent, "CMultiManager", "m_index", 0);
}

IsClone(ent) {
	return pev(ent, pev_spawnflags) & SF_MULTIMAN_CLONE ? true : false;
}

// ================= multisource ===========================

public RestoreMultiSource(ent) {
	new size = get_ent_data_size("CMultiSource", "m_rgTriggered");
	for (new i; i < size; i++) {
		set_ent_data(ent, "CMultiSource", "m_rgTriggered", 0, i);
	}
	ExecuteHam(Ham_Spawn, ent);
}
