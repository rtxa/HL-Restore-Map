#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map_stocks>
#include <xs>

#define PLUGIN  "Restore Chargers"
#define VERSION "0.3"
#define AUTHOR  "rtxA"

#define DEBUG 1

new g_HealthChargerCapacity;
new g_ArmorChargerCapacity;

public plugin_precache() {
	RegisterHam(Ham_Spawn, "func_healthcharger", "OnHealthChargerSpawn_Post", true);
	RegisterHam(Ham_Spawn, "func_recharge", "OnArmorChargerSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if defined DEBUG
	register_concmd("chargers_restore", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_health_charger", "native_restore_health_charger");
	register_native("hl_restore_armor_charger", "native_restore_armor_charger");
}

#if defined DEBUG
public CmdRestoreEntId(id) {
	RestoreAllHealthChargers();
	RestoreAllArmorChargers();

	return PLUGIN_HANDLED;
}
#endif

public OnHealthChargerSpawn_Post(ent) {
	g_HealthChargerCapacity = get_ent_data(ent, "CWallHealth", "m_iJuice");
}

public OnArmorChargerSpawn_Post(ent) {
	g_ArmorChargerCapacity = get_ent_data(ent, "CRecharge", "m_iJuice");
}

RestoreArmorCharger(ent) {
	set_ent_data(ent, "CRecharge", "m_iJuice", g_ArmorChargerCapacity);
	set_pev(ent, pev_frame, 0);
	set_pev(ent, pev_nextthink, 0);
}

RestoreAllArmorChargers() {
	new ent;
	while ((ent = find_ent_by_class(ent, "func_recharge"))) {
		RestoreArmorCharger(ent);
	}
}

RestoreHealthCharger(ent) {
	set_ent_data(ent, "CWallHealth", "m_iJuice", g_HealthChargerCapacity);
	set_pev(ent, pev_frame, 0);
	set_pev(ent, pev_nextthink, 0);
}

RestoreAllHealthChargers() {
	new ent;
	while ((ent = find_ent_by_class(ent, "func_healthcharger"))) {
		RestoreHealthCharger(ent);
	}
}

public native_restore_health_charger(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllHealthChargers();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreHealthCharger(ent);

	return true;
}

public native_restore_armor_charger(plugin_id, argc) {
	if (argc < 2)
		return false;

	new ent = get_param(1);
	new all = get_param(2);

	if (all) {
		RestoreAllArmorChargers();
		return true;
	}

	if (pev_valid(ent) != 2) {
		log_amx("Invalid entity: %d", ent);
		return false;
	}

	RestoreArmorCharger(ent);

	return true;
}

