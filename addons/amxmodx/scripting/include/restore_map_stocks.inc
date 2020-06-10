#if defined _restore_map_stocks_included
	#endinput
#endif
#define _restore_map_stocks_included

#include <amxmodx>
#include <fakemeta>

stock get_string_int(offset, const string[], const size) {
	if (size != 0)
		global_get(glb_pStringBase, offset, string, size);
}

stock SetMovedir(ent) {
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

stock AxisDir(ent) {
	if (pev(ent, pev_spawnflags) & SF_DOOR_ROTATE_Z) {
		set_pev(ent, pev_movedir, Float:{0.0, 0.0, 1.0});
	} else if (pev(ent, pev_spawnflags) & SF_DOOR_ROTATE_X) {
		set_pev(ent, pev_movedir, Float:{1.0, 0.0, 0.0});
	} else {
		set_pev(ent, pev_movedir, Float:{0.0, 1.0, 0.0});
	}
}

stock get_skill_cvar_string(const name[], output[], len) {
	new skill = clamp(get_cvar_num("skill"), 1, 3);
	get_cvar_string(fmt("%s%d", name, skill), output, len);
}

stock get_skill_cvar_num(const name[]) {
	new value[32];
	get_skill_cvar_string(name, value, charsmax(value));
	return str_to_num(value);
}