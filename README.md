# HL Restore Map API

![Author](https://img.shields.io/badge/Author-rtxA-red) ![Version](https://img.shields.io/badge/Version-0.6-red) ![Last Update](https://img.shields.io/badge/Last%20Update-04/12/2020-red) [![Source Code](https://img.shields.io/badge/GitHub-Source%20Code-blueviolet)](https://github.com/rtxa/HL-Restore-Map)

## ☉ Description

With this API you can restore map stuff as they were at the start. It's easy to use and it doesn't require to download any other module.

Now you can use this to restore stuff in maps of some game modes like Deathrun, Zombie Escape, etc.

## ☰ Natives

```php
/** 
 * Associates an entity class name with a function that handles restoring.
 */
native hl_restore_register(const classname[], const handler[]);

/** 
 * Restores an entity to like it was at the beggining of the map.
 */
native hl_restore_ent(ent);

/** 
 * Restores all entities with the provided class name just like they were
 * at the beggining of the map.
 */
native hl_restore_by_class(const classname[]);

/** 
 * Restores all entities just like they were at the beggining of the map.
 */
native hl_restore_all();
```

## ☰ Available classes for restoring

- ambient_generic
- env_explosion
- env_render
- env_laser
- env_beam
- func_breakable
- func_pushable
- func_door
- func_door_rotating
- func_water
- func_button
- func_rot_button
- func_train
- func_tracktrain
- func_rotating
- func_wall_toggle
- func_healthcharger
- func_recharge
- light
- light_spot
- multi_manager
- multisource
- trigger_auto
- trigger_once
- trigger_multiple
- trigger_push
- trigger_hurt

## ☰ Debug Commands

Requires admin with immunity flag to use them.

- restore_all - Restores all entities.
- restore_by_class \<classname\> - Restores all entities by class name.
- restore_ent \<entid\> - Restores an entity.
- restore_info \<entid\> - Shows useful debug info from an entity.

## ⛭ Requirements

- [Last AMXX 1.9](https://www.amxmodx.org/downloads-new.php) or newer.

## ⚙ Installation

1. __Download__ the attached files and __extract__ them in your AMX Mod X folder.
2. __Compile__ all the *restore_xxx.sma* files and save them in your plugins folder.
3. In your plugin's code, type *#include \<restore_map\>*.

Now you are __ready__ to use the natives of the API.

## ⛏ To Do

- ☑ Add restoring of ambient_generic.
- ☑ Add restoring of trigger_multiple.
- ☑ Add restoring of env_render, env_beam and env_laser.
- ☑ Add restoring of light and light_spot.
- ☐ Add restoring of env_spark.
- ☐ Add restoring of cycler_sprite.
- ☐ (On Discuss) Add restoring of momentary_door, momentary_rot_button and func_pendulum. 
- ☐ (On Discuss) Add restoring of items and weapons by using a wildcard. Example: hl_restore_register("weapon_*", "RestoreItem").

## ☉ Preview

[youtube]iblUy8oeQus[/youtube]

## ☘ Plugins using this API:

- [HL Zombie Escape](https://forums.alliedmods.net/showthread.php?p=2711023)
- [HL Deathrun](https://forums.alliedmods.net/showthread.php?p=2652062)
- [MiniVS](https://forums.alliedmods.net/showthread.php?p=2707036)

## ☆ Thanks to:

- [ReGameDLL Team](https://github.com/s1lentq/ReGameDLL_CS) for most of the code they use for restart stuff in CS 1.6, saved me a lot of time.
- The-822 for figure out how to block ent deleting in some entities (breakables, pushables).
- [KlyPPy](https://forums.alliedmods.net/member.php?u=228599) for ideas to improve the API. Improved a lot the simplicity and safety of the plugin.
- [HamletEagle](https://forums.alliedmods.net/member.php?u=237107) for stock to get strings stored in GoldSrc way.

## ♨ Notes

- Some entities depends from others to work as expected (e.g., func_train starts only with a trigger_auto). I recommend to restore all to avoid any issues unless you know what you are doing.
- If you are experiencing any issues, please link the name of the map (with a download link if you don't mind) and the entity you want to restore, so I can find the problem more fast and fix it.
