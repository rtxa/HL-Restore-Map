#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>

#define PLUGIN  "Restore Map"
#define VERSION "0.4"
#define AUTHOR  "rtxA"

// the trie stores classnames with the corresponding forward for restoring
new Trie:g_TrieRestoreFw;

public plugin_natives() {
	register_native("hl_restore_register", "native_restore_register");
	register_native("hl_restore_ent", "native_restore_ent");
	register_native("hl_restore_by_class", "native_restore_by_class");
	register_native("hl_restore_all", "native_restore_all");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_TrieRestoreFw = TrieCreate();

	// debug cmds
	register_concmd("restore_all", "CmdRestoreAll", ADMIN_IMMUNITY);
	register_concmd("restore_by_class", "CmdRestoreByClass", ADMIN_IMMUNITY);
	register_concmd("restore_ent", "CmdRestoreEnt", ADMIN_IMMUNITY);  
	register_concmd("restore_info", "CmdRestoreInfo", ADMIN_IMMUNITY);
}

public plugin_end() {
	new TrieIter:iterHandle = TrieIterCreate(g_TrieRestoreFw);
	
	// first destroy all the forwards
	new fwHandle;
	while (!TrieIterEnded(iterHandle)) {
		TrieIterGetCell(iterHandle, fwHandle);
		DestroyForward(fwHandle);
		TrieIterNext(iterHandle);
	}
	TrieIterDestroy(iterHandle);

	// now we're able to destroy the trie
	TrieDestroy(g_TrieRestoreFw);
}

// restore_info <entid>
public CmdRestoreInfo(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new ent = read_argv_int(1);

	if (pev_valid(ent) != 2) {
		console_print(id, "Invalid entity: %d", ent);
		return PLUGIN_HANDLED;
	}

	new classname[MAX_NAME_LENGTH], Float:flNextThink;
	pev(ent, pev_classname, classname, charsmax(classname));
	pev(ent, pev_nextthink, flNextThink);

	console_print(id, "Ent: %i (%s) - SOLID_NOT: %i - NODRAW: %i flNextThink %f", ent, classname, pev(ent, pev_solid) == SOLID_NOT, pev(ent, pev_effects) == EF_NODRAW, flNextThink);
	console_print(id, "  m_pfnThink: 0x%x m_pfnTouch: 0x%x m_pfnUse: 0x%x", get_ent_data(ent, "CBaseEntity", "m_pfnThink"), get_ent_data(ent, "CBaseEntity", "m_pfnTouch"), get_ent_data(ent, "CBaseEntity", "m_pfnUse"));

	return PLUGIN_HANDLED;
}

public CmdRestoreAll(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	hl_restore_all();
	return PLUGIN_HANDLED;
}

// restore_ent <entid>
public CmdRestoreEnt(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new ent = read_argv_int(1);

	if (pev_valid(ent) != 2) {
		console_print(id, "Invalid entity: %d", ent);
		return PLUGIN_HANDLED;
	}

	hl_restore_ent(ent);
	
	return PLUGIN_HANDLED;
}

// restore_by_class <classname>
public CmdRestoreByClass(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new classname[32];
	read_argv(1, classname, charsmax(classname));

	hl_restore_by_class(classname);

	return PLUGIN_HANDLED;
}

public native_restore_register(plugin_id, argc) {
	if (argc < 2)
		return false;

	new classname[32]; 
	get_string(1, classname, charsmax(classname)); // get callback function name

	new funcName[64]; 
	get_string(2, funcName, charsmax(funcName)); // get callback function name

	new handler = CreateOneForward(plugin_id, funcName, FP_CELL);

	if (handler == -1)
		return false;

	// now add function to trie list
	if (TrieSetCell(g_TrieRestoreFw, classname, handler))
		return true;

	// if the forward can't be stored in the trie, destroy it
	DestroyForward(handler);

	return false;
}

public native_restore_all(plugin_id, argc) {
	new TrieIter:iterHandle = TrieIterCreate(g_TrieRestoreFw);

	new classname[32];
	while (!TrieIterEnded(iterHandle)) {
		TrieIterGetKey(iterHandle, classname, charsmax(classname));
		hl_restore_by_class(classname);
		TrieIterNext(iterHandle);
	}
	TrieIterDestroy(iterHandle);

	return true;
}

public native_restore_by_class(plugin_id, argc) {
	if (argc < 1)
		return false;

	new classname[32]; 
	get_string(1, classname, charsmax(classname)); // get callback function name

	new handler;
	if (!TrieGetCell(g_TrieRestoreFw, classname, handler))
		return false;

	new ent;
	while ((ent = find_ent_by_class(ent, classname))) {
		if (pev_valid(ent) == 2) {
			ExecuteForward(handler, _, ent);
		}
	}
	
	return true;
}

public native_restore_ent(plugin_id, argc) {
	if (argc < 1)
		return false;

	new ent = get_param(1);

	new classname[32]; 
	pev(ent, pev_classname, classname, charsmax(classname));

	new handler;
	if (!TrieGetCell(g_TrieRestoreFw, classname, handler))
		return false;

	if (pev_valid(ent) == 2) {
		ExecuteForward(handler, _, ent);
	}

	return true;
}
