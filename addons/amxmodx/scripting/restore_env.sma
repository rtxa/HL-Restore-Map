#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Environment"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

new g_SprModelIndexSmoke;

#define Pev_Triggered pev_iuser4

public plugin_precache() {
	g_SprModelIndexSmoke = precache_model("sprites/steam1.spr");

	RegisterHam(Ham_Think, "env_explosion", "OnEnvExplosionThink_Pre");
	RegisterHam(Ham_Use, "env_explosion", "OnEnvExplosionUse_Pre");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("env_explosion", "RestoreEnvExplosion");
}

// ================= env_explosion ===========================

public RestoreEnvExplosion(ent) {
	set_pev(ent, Pev_Triggered, false);
}

public OnEnvExplosionUse_Pre(ent) {
	if (!(pev(ent, pev_spawnflags) & SF_ENVEXPLOSION_REPEATABLE)) {
		if (pev(ent, Pev_Triggered)) {
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public OnEnvExplosionThink_Pre(ent) {
	if (!(pev(ent, pev_spawnflags) & SF_ENVEXPLOSION_REPEATABLE)) {
		// block code that removes the entity
		set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
		
		// but make it unusable until restore is called
		set_pev(ent, Pev_Triggered, true);

		// also we need to recreate the smoke
		new Float:origin[3];
		pev(ent, pev_origin, origin);

		if (!(pev(ent, pev_spawnflags) & SF_ENVEXPLOSION_NOSMOKE)) {
			message_begin_f(MSG_PAS, SVC_TEMPENTITY, origin);
			write_byte(TE_SMOKE);
			write_coord_f(origin[0]);
			write_coord_f(origin[1]);
			write_coord_f(origin[2]);
			write_short(g_SprModelIndexSmoke);
			write_byte(get_ent_data(ent, "CEnvExplosion", "m_spriteScale")); // scale * 10
			write_byte(12); // framerate
			message_end();
		}

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

