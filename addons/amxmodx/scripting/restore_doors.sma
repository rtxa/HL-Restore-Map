#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>
#include <xs>

#define PLUGIN  "Restore Doors"
#define VERSION "0.7"
#define AUTHOR  "rtxA"

#define Pev_SavedTouchAdress 	pev_iuser4

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_door", "OnDoorSpawn_Post", true);
	RegisterHam(Ham_Spawn, "func_door_rotating", "OnRotDoorSpawn_Post", true);
	RegisterHam(Ham_Spawn, "func_water", "OnDoorSpawn_Post", true); // it's just another door
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("func_door", "RestoreDoor");
	hl_restore_register("func_door_rotating", "RestoreRotDoor");
	hl_restore_register("func_water", "RestoreDoor"); // it's just another door
}

// ================= func_door ===========================

public OnDoorSpawn_Post(ent) {
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
}

public RestoreDoor(ent) {
	SetMovedir(ent);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
	
	DoorResetPos(ent);

	CallDoorTargets(ent);

	if (pev(ent, pev_spawnflags) & SF_DOOR_USE_ONLY) {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", 0);
	} else {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", pev(ent, Pev_SavedTouchAdress));
	}
}

DoorResetPos(ent) {
	// cancel any movement being done
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseToggle", "m_pfnCallWhenMoveDone", 0);
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0});

	// set to his original position
	new Float:pos1[3];
	get_ent_data_vector(ent, "CBaseToggle", "m_vecPosition1", pos1);
	engfunc(EngFunc_SetOrigin, ent, pos1);
}

// ================= func_door_rotating ===========================

public OnRotDoorSpawn_Post(ent) {
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
}

public RestoreRotDoor(ent) {
	AxisDir(ent);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
	
	RotDoorResetPos(ent);

	CallDoorTargets(ent);

	if (pev(ent, pev_spawnflags) & SF_DOOR_USE_ONLY) {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", 0);
	} else {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", pev(ent, Pev_SavedTouchAdress));
	}
}

RotDoorResetPos(ent) {
	// cancel any movement being done
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseToggle", "m_pfnCallWhenMoveDone", 0);
	set_pev(ent, pev_avelocity, Float:{0.0, 0.0, 0.0});

	if (pev(ent, pev_spawnflags) & SF_DOOR_ROTATE_BACKWARDS) {
		new Float:movedir[3];
		set_pev(ent, pev_movedir, movedir)
		xs_vec_mul_scalar(movedir, -1.0, movedir);
		set_pev(ent, pev_movedir, movedir);
	}

	if (pev(ent, pev_speed) == 0)
		set_pev(ent, pev_speed, 100);

	new Float:angle1[3];
	get_ent_data_vector(ent, "CBaseToggle", "m_vecAngle1", angle1);
	set_pev(ent, pev_angles, angle1);
}

// ================= Private functions ===========================

CallDoorTargets(ent) {
	new activator = get_ent_data_entity(ent, "CBaseToggle", "m_hActivator");
	if (activator == FM_NULLENT)
		activator = 0;

	// this isn't finished	
	if (pev(ent, pev_spawnflags) & SF_DOOR_START_OPEN) {
		SUB_UseTargets(ent, activator, USE_TOGGLE, 0.0);
	}
	
	new netname[32];
	pev(ent, pev_netname, netname, charsmax(netname));

	// Fire the close target (if startopen is set, then "top" is closed) - netname is the close target
	if (netname[0] && pev(ent, pev_spawnflags) & SF_DOOR_START_OPEN) {
		FireTargets(netname, get_ent_data_entity(ent, "CBaseToggle", "m_hActivator"), ent, USE_TOGGLE, 0.0);
	}
}