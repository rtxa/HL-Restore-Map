#if defined _restore_map_included
	#endinput
#endif
#define _restore_map_included

/** 
 * Restores a func_button entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_button entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_button(ent = 0, bool:all = false);

/** 
 * Restores a func_rot_button entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_rot_button entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_rot_button(ent = 0, bool:all = false);

/** 
 * Restores a func_breakable entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_breakable entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_breakable(ent = 0, bool:all = false);

/** 
 * Restores a func_pushable entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_pushable entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_pushable(ent = 0, bool:all = false);

/** 
 * Restores a func_door entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_door entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_door(ent = 0, bool:all = false);

/** 
 * Restores a func_door_rotating entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_door_rotating entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_rot_door(ent = 0, bool:all = false);

/** 
 * Restores a func_train entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_train entities.
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
 * @param all		Set to true to restore all func_tracktrain entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_tracktrain(ent = 0, bool:all = false);

/** 
 * Restores a trigger_once entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all trigger_once entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_trigger_once(ent = 0, bool:all = false);

/** 
 * Restores a trigger_auto entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all trigger_auto entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_trigger_auto(ent = 0, bool:all = false);

/** 
 * Restores a trigger_push entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all trigger_push entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_trigger_push(ent = 0, bool:all = false);

/** 
 * Restores a multi_manager entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all multi_manager entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_multi_manager(ent = 0, bool:all = false);

/** 
 * Restores a func_rotating entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_rotating entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_func_rotating(ent = 0, bool:all = false);

/** 
 * Restores a func_wall_toggle entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_wall_toggle entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_func_wall_toggle(ent = 0, bool:all = false);

/** 
 * Restores a func_healthcharger entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_healthcharger entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_health_charger(ent = 0, bool:all = false);

/** 
 * Restores a func_recharge entity.
 * 
 * @param ent 		Entity index.
 * @param all		Set to true to restore all func_recharge entities.
 *
 * @noreturn
 * @error           If an invalid entity index is provided, an error will be
 *                  thrown.
 */
native hl_restore_armor_charger(ent = 0, bool:all = false);
