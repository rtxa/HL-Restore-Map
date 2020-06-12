#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Breakables"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

enum { 
	matGlass = 0,
	matWood,
	matMetal,
	matFlesh,
	matCinderBlock,
	matCeilingTile,
	matComputer,
	matUnbreakableGlass,
	matRocks,
	matNone,
	matLastMaterial
}

#define Pev_SpawnHealth 		pev_fuser4
#define Pev_SpawnTargetName 	pev_message
#define Pev_SpawnTouchAdress 	pev_iuser4

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_breakable", "OnBreakableSpawn_Post", true);
	RegisterHam(Ham_Spawn, "func_pushable", "OnPushableSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("func_breakable", "RestoreBreakable");
	hl_restore_register("func_pushable", "RestorePushable");

	// breakable
	RegisterHam(Ham_Think, "func_breakable", "OnBreakableThink_Pre");
	RegisterHam(Ham_Killed, "func_breakable", "OnBreakableKilled_Post", true);

	// pushable
	RegisterHam(Ham_Think, "func_pushable", "OnPushableThink_Pre");
	RegisterHam(Ham_Killed, "func_pushable", "OnPushableKilled_Post", true);
}

public OnBreakableSpawn_Post(ent) {
	SaveDataBreakable(ent);
}

// we always save data that can be loss when the entity is destroyed (destroyed, not removed...)
SaveDataBreakable(ent) {
	new Float:health;
	pev(ent, pev_health, health);

	// save spawn health 
	set_pev(ent, Pev_SpawnHealth, health);

	// save targetname
	new targetname[32];
	pev(ent, pev_targetname, targetname, charsmax(targetname));
	set_pev(ent, Pev_SpawnTargetName, targetname);
	
	// save CBreakable::Touch adress
	set_pev(ent, Pev_SpawnTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
}

public OnBreakableThink_Pre(ent) {
	// Block CBreakable::Die() code that removes the entity
	set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);

	BreakableDestroy(ent);

	return HAM_SUPERCEDE;
}

public OnBreakableKilled_Post(ent) {
	// remove kill flag, this is the reason why entity think doesn't work even when it should
	// Block too UTIL_Remove from CBaseEntity::Killed()
	set_pev(ent, pev_flags, pev(ent, pev_flags) & ~FL_KILLME);
}

public RestoreBreakable(ent) {
	set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);
	set_pev(ent, pev_solid, SOLID_BSP);
	set_pev(ent, pev_movetype, MOVETYPE_PUSH);
	set_pev(ent, pev_deadflag, DEAD_NO);

	if (pev(ent, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY)
		set_pev(ent, pev_takedamage, DAMAGE_NO);
	else
		set_pev(ent, pev_takedamage, DAMAGE_YES);

	// restore health
	new Float:health;
	pev(ent, Pev_SpawnHealth, health);
	set_pev(ent, pev_health, health);

	// restore targetname
	new targetname[32];
	pev(ent, Pev_SpawnTargetName, targetname, charsmax(targetname));
	set_pev(ent, pev_targetname, targetname);

	// restore angles
	new Float:angles[3];
	pev(ent, pev_angles, angles);
	set_ent_data_float(ent, "CBreakable", "m_angle", angles[1]); // coord y
	angles[1] = 0.0;
	set_pev(ent, pev_angles, angles);

	// restore touch adress
	set_ent_data(ent, "CBaseEntity", "m_pfnTouch", pev(ent, Pev_SpawnTouchAdress));

	if (pev(ent, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY) {
		set_ent_data(ent, "CBaseEntity", "m_pfnTouch", 0);
	}
	
	if (!IsBreakable(ent) && pev(ent, pev_rendermode) != kRenderNormal) {
		set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_WORLDBRUSH);
	}

	// fixes collision in some cases (dr_barbie_csbr)
	new model[16];
	pev(ent, pev_model, model, charsmax(model));
	engfunc(EngFunc_SetModel, ent, model);

	// remove entity spawned by the breakable by checking his owner
	new ofsSpawnObject = get_ent_data(ent, "CBreakable", "m_iszSpawnObject");
	if (ofsSpawnObject) {
		new objectName[32];
		get_string_int(ofsSpawnObject, objectName, charsmax(objectName));

		new entid;
		while ((entid = find_ent_by_class(entid, objectName))) {
			// this object is from the func_breakable?
			if (pev(entid, pev_owner) == ent) {
				remove_entity(entid);
			}
		}
	}
}

BreakableDestroy(ent) {
	set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW);
}

IsBreakable(ent) {
	return get_ent_data(ent, "CBreakable", "m_Material") != matUnbreakableGlass;
}

public OnPushableSpawn_Post(ent) {
	if (pev(ent, pev_spawnflags) & SF_PUSH_BREAKABLE) {
		SaveDataBreakable(ent);
	}

	// save spawn origin
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	set_pev(ent, pev_oldorigin, origin);
}

public OnPushableThink_Pre(ent) {
	if (pev(ent, pev_spawnflags) & SF_PUSH_BREAKABLE) {
		// Block CBreakable::Die() code that removes the entity
		set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
		BreakableDestroy(ent);
	}

	return HAM_SUPERCEDE;
}

public OnPushableKilled_Post(ent) {
	// remove kill flag, this is the reason why entity think doesn't work even when it should
	// Block too UTIL_Remove from CBaseEntity::Killed()
	if (pev(ent, pev_spawnflags) & SF_PUSH_BREAKABLE) {
		set_pev(ent, pev_flags, pev(ent, pev_flags) & ~FL_KILLME);
	}
}

public RestorePushable(ent) {
	if (pev(ent, pev_spawnflags) & SF_PUSH_BREAKABLE) {
		RestoreBreakable(ent);
	}

	set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP);	
	set_pev(ent, pev_solid, SOLID_BBOX);
	
	if (pev(ent, pev_friction) > 399)
		set_pev(ent, pev_friction, 399);

	set_ent_data_float(ent, "CPushable", "m_soundTime", 0.0);
	set_ent_data_float(ent, "CPushable", "m_maxSpeed", 400.0 - pev(ent, pev_friction));

	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_FLOAT);
	set_pev(ent, pev_friction, 0); // why is resetted? this doesn't makes sense
	
	// remove any velocity
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0}); 

	// fix breakable not getting visible if it was destroyed by a func_train
	new model[16]; // bsp models follows the next format: "*number"
	pev(ent, pev_model, model, charsmax(model));
	engfunc(EngFunc_SetModel, ent, model);

	new Float:oldorigin[3];
	pev(ent, pev_oldorigin, oldorigin);
	engfunc(EngFunc_SetOrigin, ent, oldorigin); // warning: don't use set_pev(), doesn't work right...
}
