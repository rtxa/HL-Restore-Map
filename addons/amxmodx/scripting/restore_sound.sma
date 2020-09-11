#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Sound"
#define VERSION "0.6"
#define AUTHOR  "rtxA"

// missing in hlsdk_const.inc
#define AMBIENT_SOUND_STATIC			0	// medium radius attenuation
#define AMBIENT_SOUND_EVERYWHERE		1
#define AMBIENT_SOUND_SMALLRADIUS		2
#define AMBIENT_SOUND_MEDIUMRADIUS		4
#define AMBIENT_SOUND_LARGERADIUS		8
#define AMBIENT_SOUND_START_SILENT		16
#define AMBIENT_SOUND_NOT_LOOPING		32

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

	// silent sound
	if ((pev(ent, pev_spawnflags) & AMBIENT_SOUND_START_SILENT)) {
		// stop ambient sound and restore
		engfunc(EngFunc_EmitAmbientSound, ent, origin, soundFile, 0, 0, SND_STOP, 0);
		ExecuteHamB(Ham_Spawn, ent);
	} else {
		// make think sound is silent before spawn to avoid emit sound with SND_SPAWNING flag
		set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | AMBIENT_SOUND_START_SILENT);

		// stop ambient sound
		engfunc(EngFunc_EmitAmbientSound, ent, origin, soundFile, 0, 0, SND_STOP, 0);

		// restore and force play sound
		ExecuteHamB(Ham_Spawn, ent);
		ExecuteHamB(Ham_Use, ent, 0, 0, USE_TOGGLE, 0.0);

		// set back to his previous flag
		set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) & ~AMBIENT_SOUND_START_SILENT);
	}


}
