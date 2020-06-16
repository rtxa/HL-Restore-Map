#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Sound"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("ambient_generic", "RestoreAmbientGeneric");
}

// ================= ambient_generic ===========================

public RestoreAmbientGeneric(ent) {
	new soundFile[128];
	pev(ent, pev_message, soundFile, charsmax(soundFile));
	
	new Float:origin[3];
	pev(ent, pev_origin, origin);

	// stop ambient sound
	engfunc(EngFunc_EmitAmbientSound, ent, origin, soundFile, 0, 0, SND_STOP, 0);

	ExecuteHamB(Ham_Spawn, ent);
}
