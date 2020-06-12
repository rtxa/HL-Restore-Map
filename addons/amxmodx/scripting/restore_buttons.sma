#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>
#include <xs>

#define PLUGIN  "Restore Buttons"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

#define Pev_SavedUseAdress 	    pev_iuser2
#define Pev_SavedThinkAdress  	pev_iuser3
#define Pev_SavedTouchAdress 	pev_iuser4

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_button", "OnButtonSpawn_Post", true);
	RegisterHam(Ham_Spawn, "func_rot_button", "OnRotButtonSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("func_button", "RestoreButton")
	hl_restore_register("func_rot_button", "RestoreRotButton")
}

// ================= func_button ===========================

public OnButtonSpawn_Post(ent) {
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
	set_pev(ent, Pev_SavedUseAdress, get_ent_data(ent, "CBaseEntity", "m_pfnUse"));
	set_pev(ent, Pev_SavedThinkAdress, get_ent_data(ent, "CBaseEntity", "m_pfnThink"));
}

public RestoreButton(ent) {
	set_ent_data_entity(ent, "CBaseToggle", "m_hActivator", FM_NULLENT);
	SetMovedir(ent);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
	
	ButtonResetPos(ent);

	set_pev(ent, pev_frame, 0.0);

	if (pev(ent, pev_spawnflags) & SF_BUTTON_SPARK_IF_OFF) {
		set_ent_data(ent, "CBaseEntity", "m_pfnThink", pev(ent, Pev_SavedThinkAdress));
		set_pev(ent, pev_nextthink, get_gametime() + 0.5);
	}

	if (pev(ent, pev_spawnflags) & SF_BUTTON_TOUCH_ONLY) {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", pev(ent, Pev_SavedTouchAdress));
	} else {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", 0);
		set_ent_data(ent, "CBaseEntity", "m_pfnUse", pev(ent, Pev_SavedUseAdress));        
	}
}

ButtonResetPos(ent) {
	// cancel any movement being done
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
	set_ent_data(ent, "CBaseToggle", "m_pfnCallWhenMoveDone", 0);
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0});

	// set to his original position
	new Float:pos1[3];
	get_ent_data_vector(ent, "CBaseToggle", "m_vecPosition1", pos1);
	engfunc(EngFunc_SetOrigin, ent, pos1);
}

// ================= func_rot_button ===========================

public OnRotButtonSpawn_Post(ent) {
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
	set_pev(ent, Pev_SavedUseAdress, get_ent_data(ent, "CBaseEntity", "m_pfnUse"));	
}

public RestoreRotButton(ent) {
	AxisDir(ent);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
	
	RotButtonResetPos(ent);

	set_pev(ent, pev_frame, 0.0);

	if (pev(ent, pev_spawnflags) & SF_BUTTON_TOUCH_ONLY) {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", pev(ent, Pev_SavedTouchAdress));
	} else {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", 0);
		set_ent_data(ent, "CBaseEntity", "m_pfnUse", pev(ent, Pev_SavedUseAdress));        
	}
}

RotButtonResetPos(ent) {
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
		set_pev(ent, pev_speed, 40.0);

	new Float:angle1[3];
	get_ent_data_vector(ent, "CBaseToggle", "m_vecAngle1", angle1);
	set_pev(ent, pev_angles, angle1);
}
