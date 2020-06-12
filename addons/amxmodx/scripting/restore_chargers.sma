#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Chargers"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

new g_HealthChargerCapacity;
new g_ArmorChargerCapacity;

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_healthcharger", "OnHealthChargerSpawn_Post", true);
	RegisterHam(Ham_Spawn, "func_recharge", "OnArmorChargerSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("func_healthcharger", "RestoreHealthCharger");
	hl_restore_register("func_recharge", "RestoreArmorCharger");
}

public OnHealthChargerSpawn_Post(ent) {
	g_HealthChargerCapacity = get_ent_data(ent, "CWallHealth", "m_iJuice");
}

public OnArmorChargerSpawn_Post(ent) {
	g_ArmorChargerCapacity = get_ent_data(ent, "CRecharge", "m_iJuice");
}

public RestoreArmorCharger(ent) {
	set_ent_data(ent, "CRecharge", "m_iJuice", g_ArmorChargerCapacity);
	set_pev(ent, pev_frame, 0);
	set_pev(ent, pev_nextthink, 0);
}

public RestoreHealthCharger(ent) {
	set_ent_data(ent, "CWallHealth", "m_iJuice", g_HealthChargerCapacity);
	set_pev(ent, pev_frame, 0);
	set_pev(ent, pev_nextthink, 0);
}
