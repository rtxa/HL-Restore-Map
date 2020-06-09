#include <amxmisc>
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#define PLUGIN  "Restore Buttons"
#define VERSION "0.3"
#define AUTHOR  "rtxA"

#define DEBUG 1

#define Pev_SavedMaster 		pev_message
#define Pev_SavedToggleState 	pev_iuser2
#define Pev_SavedSpawnFlags  	pev_iuser3
#define Pev_SavedTouchAdress 	pev_iuser4
#define Pev_SavedUseAdress 	    pev_iuser1

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_button", "OnButtonSpawn_Post", true);
	//RegisterHam(Ham_Spawn, "func_door_rotating", "OnRotDoorSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if defined DEBUG
	register_concmd("buttons_rentid", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_buttons", "native_restore_buttons");
	//register_native("hl_restore_rot_doors", "native_restore_rot_doors");
}

#if defined DEBUG
public CmdEntId(id)
{
	new ent;
	if ((ent = read_argv_int(1)) < 1 || pev_valid(ent) < 2)
	{
		console_print(id, "Invalid entity: %d", ent);
		return PLUGIN_HANDLED;
	}

	new szClassName[MAX_NAME_LENGTH], Float:flNextThink;
	pev(ent, pev_classname, szClassName, charsmax(szClassName));
	pev(ent, pev_nextthink, flNextThink);

	console_print(id, "Ent: %i (%s) - SOLID_NOT: %i - NODRAW: %i - pev_impulse %d", ent, szClassName, pev(ent, pev_solid) == SOLID_NOT, pev(ent, pev_effects) == EF_NODRAW, pev(ent, pev_impulse));
	console_print(id, "  m_pfnThink: 0x%x", get_ent_data(ent, "CBaseEntity", "m_pfnThink"));

	return PLUGIN_HANDLED;
}

RestoreAllButtons() {
	new ent;
	while ((ent = find_ent_by_class(ent, "func_button"))) {
		RestoreButton(ent);
	}
}

public CmdRestoreEntId(id) {
	new ent = read_argv_int(1);

	if (!ent) {
		RestoreAllButtons();
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

public OnButtonSpawn_Post(ent) {
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	
	set_pev(ent, Pev_SavedUseAdress, get_ent_data(ent, "CBaseEntity", "m_pfnUse"));	
}

RestoreButton(ent) {
	set_ent_data_entity(ent, "CBaseToggle", "m_hActivator", FM_NULLENT);
	SetMovedir(ent);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
	
	ButtonResetPos(ent);

	set_pev(ent, pev_frame, 0.0);

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

SetMovedir(ent) {
	new Float:angles[3];
	pev(ent, pev_angles, angles);
	if (xs_vec_equal(angles, Float:{0.0, -1.0, 0.0})) {
		set_pev(ent, pev_movedir, Float:{0.0, 0.0, 1.0});
	} else if (xs_vec_equal(angles, Float:{0.0, -2.0, 0.0})) {
		set_pev(ent, pev_movedir, Float:{0.0, 0.0, -1.0});
	} else {
		engfunc(EngFunc_MakeVectors, angles);
		set_pev(ent, pev_angles, angles);
		new Float:v_forward[3];
		global_get(glb_v_forward, v_forward);
		set_pev(ent, pev_movedir, v_forward);
	}
	set_pev(ent, pev_angles, Float:{0.0, 0.0, 0.0});
}

public OnRotDoorSpawn_Post(ent) {
	set_pev(ent, Pev_SavedTouchAdress, get_ent_data(ent, "CBaseEntity", "m_pfnTouch"));	

	// not used but leaved just in case my method doesn't works
	set_pev(ent, Pev_SavedToggleState, get_ent_data(ent, "CBaseToggle", "m_toggle_state"));
	set_pev(ent, Pev_SavedMaster, get_ent_data(ent, "CBaseToggle", "m_sMaster"));
	set_pev(ent, Pev_SavedSpawnFlags, pev(ent, pev_spawnflags));
}

RestoreRotDoor(ent) {
	AxisDir(ent);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
	
	RotDoorResetPos(ent);

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

AxisDir(ent) {
	if (pev(ent, pev_spawnflags) & SF_DOOR_ROTATE_Z) {
		set_pev(ent, pev_movedir, Float:{0.0, 0.0, 1.0});
	} else if (pev(ent, pev_spawnflags) & SF_DOOR_ROTATE_X) {
		set_pev(ent, pev_movedir, Float:{1.0, 0.0, 0.0});
	} else {
		set_pev(ent, pev_movedir, Float:{0.0, 1.0, 0.0});
	}
}

RestoreAllRotDoors() {
	new ent;
	while ((ent = find_ent_by_class(ent, "func_door_rotating"))) {
		RestoreRotDoor(ent);
	}
}

public native_restore_buttons(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllButtons();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreButton(ent);

	return true;
}

public native_restore_rot_doors(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllRotDoors();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreRotDoor(ent);

	return true;
}

// Not used, but leaved in case my own method doesn't work well.
stock DoorGoDown(ent) {
	// hack: we need to use the function DoorGoDown
	// let's make the entity on purpose
	set_ent_data(ent, "CBaseToggle", "m_sMaster", 0);
	set_pev(ent, pev_spawnflags, SF_DOOR_NO_AUTO_RETURN);
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_TOP);
	dllfunc(DLLFunc_Use, ent, 0);

	// hack finished, restore entity previous data
	set_pev(ent, pev_spawnflags, pev(ent, Pev_SavedSpawnFlags));
	set_ent_data(ent, "CBaseToggle", "m_sMaster", pev(ent, Pev_SavedMaster));
	set_ent_data(ent, "CBaseToggle", "m_toggle_state", TS_AT_BOTTOM);
}