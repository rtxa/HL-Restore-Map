#include <amxmisc>
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
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
	register_concmd("chargers_rentid", "CmdRestoreEntId");
#endif
}

public plugin_natives() {
	register_native("hl_restore_health_charger", "native_restore_health_charger");
	register_native("hl_restore_armor_charger", "native_restore_armor_charger");
}

#if defined DEBUG
public CmdRestoreEntId(id) {
	new ent = read_argv_int(1);

	if (!ent) {
		RestoreAllHealthChargers();
		RestoreAllArmorChargers();
	} else {
		if (pev_valid(ent) != 2) {
			console_print(id, "Invalid entity: %d", ent);
			return PLUGIN_HANDLED;
		}
	}

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

// ======================== useful stocks ============================================

stock get_skill_cvar_string(const name[], output[], len) {
	new skill = clamp(get_cvar_num("skill"), 1, 3);
	get_cvar_string(fmt("%s%d", name, skill), output, len);
}

stock get_skill_cvar_num(const name[]) {
	new value[32];
	get_skill_cvar_string(name, value, charsmax(value));
	return str_to_num(value);
}

stock get_string_int(offset, const string[], const size) {
	if (size != 0)
		global_get(glb_pStringBase, offset, string, size);
}
