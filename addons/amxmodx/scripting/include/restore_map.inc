#if defined _restore_map_included
	#endinput
#endif
#define _restore_map_included

// where `handler` is `public handler(ent)`
native hl_restore_register(const classname[], const handler[]);

// Restores a single entity
native hl_restore_ent(ent);

// Search by classname
native hl_restore_by_class(const classname[]);

// Restore all entities
native hl_restore_all();