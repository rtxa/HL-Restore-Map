#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Lights"
#define VERSION "0.5"
#define AUTHOR  "rtxA"

#define Pev_StartedOff pev_iuser4

public plugin_precache() {
	RegisterHam(Ham_Spawn, "light", "OnLightSpawn_Post", true);
	RegisterHam(Ham_Spawn, "light_spot", "OnLightSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("light", "RestoreLight");
	hl_restore_register("light_spot", "RestoreLight");
}

// ================= light and light_spot ===========================

public OnLightSpawn_Post(ent) {
	// lights without target name are deleted
	if (pev_valid(ent) == 2)
		set_pev(ent, Pev_StartedOff, pev(ent, pev_spawnflags) & SF_LIGHT_START_OFF ? true : false);
}

public RestoreLight(ent) {
	new style = get_ent_data(ent, "CLight", "m_iStyle");
	if (style >= 32) {
		if (pev(ent, Pev_StartedOff)) {
			set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_LIGHT_START_OFF);
			engfunc(EngFunc_LightStyle, style, "a");
		} else {
			set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) & ~SF_LIGHT_START_OFF);

			new pattern[32];
			get_string_int(get_ent_data(ent, "CLight", "m_iszPattern"), pattern, charsmax(pattern));

			if (pattern[0])
				engfunc(EngFunc_LightStyle, style, pattern);
			else
				engfunc(EngFunc_LightStyle, style, "m");
		}
	}
}