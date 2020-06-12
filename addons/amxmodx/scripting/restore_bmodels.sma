#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>
#include <xs>

#define PLUGIN  "Restore Brush Models"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

// missing in hlsdk_const.inc, a PR must be done...
#define	SF_BRUSH_ACCDCC			16	// brush should accelerate and decelerate when toggled
#define	SF_BRUSH_HURT			32	// rotating brush that inflicts pain based on rotation speed
#define	SF_ROTATING_NOT_SOLID	64	// some special rotating objects are not solid.

#define Pev_SavedThinkAdress    pev_iuser4
#define Pev_SavedUseAdress      pev_iuser3
#define Pev_SavedTouchAdress    pev_iuser2
#define Pev_SavedAngle	        pev_vuser4

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_rotating", "OnFuncRotatingSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("func_rotating", "RestoreFuncRotating");
	hl_restore_register("func_wall_toggle", "RestoreFuncWallToggle");
}

// ================= func_rotating ===========================

public OnFuncRotatingSpawn_Post(ent) {
	set_pev(ent, Pev_SavedThinkAdress, get_ent_data(ent, "CBaseEntity", "m_pfnThink"));	
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
	set_pev(ent, Pev_SavedUseAdress, get_ent_data(ent, "CBaseEntity", "m_pfnUse"));	

	new Float:angles[3];
	pev(ent, pev_angles, angles);
	set_pev(ent, Pev_SavedAngle, angles);
}

public RestoreFuncRotating(ent) {
	new noiseRunning[128];
	get_string_int(pev(ent, pev_noise3), noiseRunning, charsmax(noiseRunning));
	
	new pitch = floatround(get_ent_data_float(ent, "CFuncRotating", "m_pitch"), floatround_tozero);
	
	// stop noise sound, we're done
	emit_sound(ent, CHAN_STATIC, noiseRunning, 0.0, ATTN_NONE, SND_STOP, pitch);
	
	// restore angles
	new Float:angles[3];
	pev(ent, Pev_SavedAngle, angles);
	set_pev(ent, pev_angles, angles);
	
	// block any movement
	set_pev(ent, pev_avelocity, Float:{0.0, 0.0, 0.0});

	// some rotating objects like fake volumetric lights will not be solid.
	if (pev(ent, pev_spawnflags) & SF_ROTATING_NOT_SOLID) {
		set_pev(ent, pev_solid, SOLID_NOT);
		set_pev(ent, pev_skin, CONTENTS_EMPTY);
		set_pev(ent, pev_movetype, MOVETYPE_PUSH);
	} else {
		set_pev(ent, pev_solid, SOLID_BSP);
		set_pev(ent, pev_movetype, MOVETYPE_PUSH);
	}

	new Float:origin[3], model[128];
	pev(ent, pev_origin, origin);
	pev(ent, pev_model, model, charsmax(model));
	
	engfunc(EngFunc_SetOrigin, ent, origin);
	engfunc(EngFunc_SetModel, ent, model);

	set_ent_data(ent, "CBaseEntity", "m_pfnUse", pev(ent, Pev_SavedUseAdress));

	// did level designer forget to assign speed?
	if (entity_get_float(ent, EV_FL_speed) <= 0.0)
		set_pev(ent, pev_speed, 0.0);

	// instant-use brush?
	if (pev(ent, pev_spawnflags) & SF_BRUSH_ROTATE_INSTANT) {
		set_ent_data(ent, "CBaseEntity", "m_pfnThink", pev(ent, Pev_SavedThinkAdress));

		// leave a magic delay for client to start up
		set_pev(ent, pev_nextthink, entity_get_float(ent, EV_FL_ltime) + 0.1);
	}

	// can this brush inflict pain?
	if (pev(ent, pev_spawnflags) & SF_BRUSH_HURT) {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", pev(ent, Pev_SavedTouchAdress));
	}
}

// ================= func_wall_toggle ===========================

public RestoreFuncWallToggle(ent) {
	ExecuteHam(Ham_Spawn, ent);
	if (pev(ent, pev_spawnflags) & SF_WALL_START_OFF)
		TurnOffWallToggle(ent);
	else
		TurnOnWallToggle(ent);
}

TurnOnWallToggle(ent) {
	set_pev(ent, pev_solid, SOLID_BSP);
	set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);

	new Float:origin[3];
	pev(ent, pev_origin, origin);	
	engfunc(EngFunc_SetOrigin, ent, origin);
}

TurnOffWallToggle(ent) {
	set_pev(ent, pev_solid, SOLID_NOT);
	set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW);
	
	new Float:origin[3];
	pev(ent, pev_origin, origin);	
	engfunc(EngFunc_SetOrigin, ent, origin);
}
