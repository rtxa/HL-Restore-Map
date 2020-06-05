#if defined _restore_map_included
	#endinput
#endif
#define _restore_map_included

/** 
 * Restores a func_breakable entity.
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
 * Restores a func_pushable entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_pushable entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_pushables(ent = 0, bool:all = false);

/** 
 * Restores a func_door entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_door entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_doors(ent = 0, bool:all = false);

/** 
 * Restores a func_door_rotating entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_door_rotating entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_rot_doors(ent = 0, bool:all = false);

/** 
 * Restores a func_train entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_train entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_train(ent = 0, bool:all = false);

/** 
 * Restores a func_tracktrain entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set true to restore all func_tracktrain entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_tracktrain(ent = 0, bool:all = false);
