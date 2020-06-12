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
	RegisterHam(Ham_Spawn, "multi_manager", "OnMultiManagerSpawn_Post", true);
	RegisterHam(Ham_Spawn, "trigger_once", "OnTriggerOnceSpawn_Post", true);
	RegisterHam(Ham_Think, "trigger_once", "OnTriggerOnceThink_Pre");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("multi_manager", "RestoreMultiManager");
	hl_restore_register("trigger_auto", "RestoreTriggerAuto");
	hl_restore_register("trigger_once", "RestoreTriggerOnce");
	hl_restore_register("trigger_push", "RestoreTriggerPush");
	hl_restore_register("trigger_hurt", "RestoreTriggerHurt");
}

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

public RestoreTriggerPush(ent) {
	// is it required to restore movedir? no idea but regamedll does this for a reason
	new Float:movedir[3];
	pev(ent, pev_movedir, movedir);
	ExecuteHam(Ham_Spawn, ent);
	set_pev(ent, pev_movedir, movedir);
}

public RestoreTriggerHurt(ent) {
	new Float:mins[3], Float:maxs[3];

	pev(ent, pev_mins, mins);
	pev(ent, pev_maxs, maxs);

	// InitTrigger() is about to destroy the size
	ExecuteHam(Ham_Spawn, ent);

	engfunc(EngFunc_SetSize, ent, mins, maxs);
}

public RestoreTriggerAuto(ent) {
	set_pev(ent, pev_nextthink, get_gametime() + 0.1);
}

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
