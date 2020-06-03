#if defined _restore_map_included
	#endinput
#endif
#define _restore_map_included

/** 
 * Restore a func_breakable entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_breakable entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_breakables(ent = 0, bool:all = false);

/** 
 * Restore a func_pushable entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_pushable entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_pushables(ent = 0, bool:all = false);