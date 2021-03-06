#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <restore_map>
#include <restore_map_stocks>

#define PLUGIN  "Restore Environment"
#define VERSION "0.6"
#define AUTHOR  "rtxA"

new g_SprModelIndexSmoke;

#define Pev_Triggered 	pev_iuser4
#define Pev_SavedThink 	pev_iuser3

new Trie:g_RenderGroups;

public plugin_precache() {
	
	// env_explosion
	g_SprModelIndexSmoke = precache_model("sprites/steam1.spr");
	RegisterHam(Ham_Think, "env_explosion", "OnEnvExplosionThink_Pre");
	RegisterHam(Ham_Use, "env_explosion", "OnEnvExplosionUse_Pre");

	// env_render
	g_RenderGroups = TrieCreate();
	RegisterHam(Ham_Use, "env_render", "OnEnvRenderUse_Pre");
	register_forward(FM_OnFreeEntPrivateData, "OnFreeEntPrivateData_Pre");

	// env_beam
	RegisterHam(Ham_Spawn, "env_beam", "OnBeamSpawn_Post", true);
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	hl_restore_register("env_explosion", "RestoreEnvExplosion");
	hl_restore_register("env_render", "RestoreEnvRender");
	hl_restore_register("env_laser", "RestoreEnvLaser");
	hl_restore_register("env_beam", "CLightning_Restore");
}

public plugin_end() {
	if (!g_RenderGroups)
		return;
	RenderGroups_Destroy(g_RenderGroups);
}

public OnFreeEntPrivateData_Pre(ent) {
	// destroy saved entity data of the ent modified by a env_render, no needed anymore
	if (g_RenderGroups)
		RenderGroups_Delete(g_RenderGroups, ent);
}

// ================= env_render ===========================

public OnEnvRenderUse_Pre(ent, activator, caller, useType, Float:value) {
	new target[32];
	pev(ent, pev_target, target, charsmax(target));

	if (!target[0])
		return HAM_IGNORED;

	if (!g_RenderGroups)
		return HAM_IGNORED;

	// save entity state before env_render modifies it
	new entTarget;
	while ((entTarget = find_ent_by_tname(entTarget, target))) {

		if (RenderGroups_Find(g_RenderGroups, entTarget))
			continue;

		new DataPack:renderGroup = CreateDataPack();

		if (!renderGroup)
			continue;
		
		new Float:renderColor[3];
		pev(entTarget, pev_rendercolor, renderColor);

		WritePackCell(renderGroup, pev(entTarget, pev_rendermode));
		WritePackCell(renderGroup, pev(entTarget, pev_renderfx));
		WritePackFloat(renderGroup, entity_get_float(entTarget, EV_FL_renderamt));
		WritePackVector(renderGroup, renderColor);

		RenderGroups_Insert(g_RenderGroups, entTarget, renderGroup);
	}

	return HAM_IGNORED;
}

public RestoreEnvRender(ent) {
	new target[32];
	pev(ent, pev_target, target, charsmax(target));

	if (!target[0])
		return;

	if (!g_RenderGroups)
		return;

	// restore entities affected by env_render
	new entTarget;
	while ((entTarget = find_ent_by_tname(entTarget, target))) {
		new renderMode, renderFx, Float:renderAmt, Float:renderColor[3];

		new DataPack:renderGroup = RenderGroups_Find(g_RenderGroups, entTarget);

		if (!renderGroup)
			continue;

		ResetPack(renderGroup);
		renderMode = ReadPackCell(renderGroup);
		renderFx = ReadPackCell(renderGroup);
		renderAmt = ReadPackFloat(renderGroup);
		ReadPackVector(renderGroup, renderColor);

		if (!(pev(entTarget, pev_spawnflags) & SF_RENDER_MASKFX))
			set_pev(entTarget, pev_renderfx, renderFx);

		if (!(pev(entTarget, pev_spawnflags) & SF_RENDER_MASKAMT))
			set_pev(entTarget, pev_renderamt, renderAmt);

		if (!(pev(entTarget, pev_spawnflags) & SF_RENDER_MASKMODE))
			set_pev(entTarget, pev_rendermode, renderMode);

		if (!(pev(entTarget, pev_spawnflags) & SF_RENDER_MASKCOLOR))
			set_pev(entTarget, pev_rendercolor, renderColor);
	}
}

// ================= env_explosion ===========================

public RestoreEnvExplosion(ent) {
	set_pev(ent, Pev_Triggered, false);
}

public OnEnvExplosionUse_Pre(ent) {
	if (!(pev(ent, pev_spawnflags) & SF_ENVEXPLOSION_REPEATABLE)) {
		if (pev(ent, Pev_Triggered)) {
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public OnEnvExplosionThink_Pre(ent) {
	if (!(pev(ent, pev_spawnflags) & SF_ENVEXPLOSION_REPEATABLE)) {
		// block code that removes the entity
		set_ent_data(ent, "CBaseEntity", "m_pfnThink", 0);
		
		// but make it unusable until restore is called
		set_pev(ent, Pev_Triggered, true);

		// also we need to recreate the smoke
		new Float:origin[3];
		pev(ent, pev_origin, origin);

		if (!(pev(ent, pev_spawnflags) & SF_ENVEXPLOSION_NOSMOKE)) {
			message_begin_f(MSG_PAS, SVC_TEMPENTITY, origin);
			write_byte(TE_SMOKE);
			write_coord_f(origin[0]);
			write_coord_f(origin[1]);
			write_coord_f(origin[2]);
			write_short(g_SprModelIndexSmoke);
			write_byte(get_ent_data(ent, "CEnvExplosion", "m_spriteScale")); // scale * 10
			write_byte(12); // framerate
			message_end();
		}

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

// =================================== env_laser ==================================

public RestoreEnvLaser(ent) {
	// Remove model & collisions
	set_pev(ent, pev_solid, SOLID_NOT);
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_CUSTOMENTITY);

	//if (m_pSprite) {
	//	m_pSprite->SetTransparency(kRenderGlow, pev->rendercolor.x, pev->rendercolor.y, pev->rendercolor.z, pev->renderamt, pev->renderfx);
	//}

	new target[32];
	pev(ent, pev_targetname, target, charsmax(target));
	if (target[0] && !(pev(ent, pev_spawnflags) & SF_BEAM_STARTON))
		CLaser_TurnOff(ent);
	else
		CLaser_TurnOn(ent);
}

CLaser_TurnOff(ent) {
	set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW);
	set_pev(ent, pev_nextthink, 0.0);

	new pSprite = get_ent_data_entity(ent, "CLaser", "m_pSprite");

	if (pSprite != FM_NULLENT)
		SpriteTurnOff(pSprite);
}

CLaser_TurnOn(ent) {
	set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);

	new pSprite = get_ent_data_entity(ent, "CLaser", "m_pSprite");
	
	if (pSprite != FM_NULLENT)
		SpriteTurnOn(pSprite);

	set_pev(ent, pev_dmgtime, get_gametime());
	set_pev(ent, pev_nextthink, get_gametime());
}

SpriteTurnOff(ent) {
	set_pev(ent, pev_effects, EF_NODRAW);
	set_pev(ent, pev_nextthink, 0.0);
}

SpriteTurnOn(ent) {
	set_pev(ent, pev_effects, 0);

	if ((entity_get_float(ent, EV_FL_framerate) && get_ent_data(ent, "CSprite", "m_maxFrame") > 1) || (pev(ent, pev_spawnflags) & SF_SPRITE_ONCE)) {	
		// quizas no lo necesite por ahora, ya q si empezo on, ya se activo el think, no hay  encesidad de agregar eso...
		//SetThink(&CSprite::AnimateThink);
		set_pev(ent, pev_nextthink, get_gametime());
		set_ent_data_float(ent, "CSprite", "m_lastTime", get_gametime());
	}

	set_pev(ent, pev_frame, 0.0);
}

// =================================== env_beam and env_lightning ===============================================

public OnBeamSpawn_Post(ent) {
	set_pev(ent, Pev_SavedThink, get_ent_data(ent, "CBaseEntity", "m_pfnThink"));
}

public CLightning_Restore(ent) {
	// Remove model & collisions
	set_pev(ent, pev_solid, SOLID_NOT);
	set_pev(ent, pev_dmgtime, get_gametime());

	if (CLightning_ServerSide(ent)) {
		//SetThink(nullptr);
		if (entity_get_float(ent, EV_FL_dmg) > 0) {
			//SetThink(&CLightning::DamageThink);
			set_pev(ent, pev_nextthink, get_gametime() + 0.1);
		}

		if (pev(ent, pev_targetname)) {
			if (!(pev(ent, pev_spawnflags) & SF_BEAM_STARTON)) {
				set_ent_data(ent, "CLightning", "m_active", false);
				set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW);
				set_pev(ent, pev_nextthink, 0.0);
			} else {
				set_ent_data(ent, "CLightning", "m_active", true);
			}

			//SetUse(&CLightning::ToggleUse);
		}
	} else {
		set_ent_data(ent, "CLightning", "m_active", false);
		
		new target[32];
		pev(ent, pev_targetname, target, charsmax(target));
		
		if (target[0]) {
			//SetUse(&CLightning::StrikeUse);
		}

		if (!target[0] || (pev(ent, pev_spawnflags) & SF_BEAM_STARTON)) {
			//SetThink(&CLightning::StrikeThink);
			set_pev(ent, pev_nextthink, get_gametime() + 1.0);
		}
	}

	set_ent_data(ent, "CBaseEntity", "m_pfnThink", pev(ent, Pev_SavedThink));
}

bool:CLightning_ServerSide(ent) {
	if (!get_ent_data_float(ent, "CLightning", "m_life") && !(pev(ent, pev_spawnflags) & SF_BEAM_RING))
		return true;
	return false;
}

// ================= useful stocks for env_render ===========================

// returns 0 if entity doesn't exist
stock DataPack:RenderGroups_Find(Trie:handle, entid) {
	new key[16];
	num_to_str(entid, key, charsmax(key));
	new DataPack:value;
	TrieGetCell(handle, key, value)
	return value;
}

stock RenderGroups_Insert(Trie:handle, entid, DataPack:value) {
	new key[16];
	num_to_str(entid, key, charsmax(key));
	TrieSetCell(handle, key, value);
}

stock RenderGroups_Delete(Trie:handle, entid) {
	new key[16];
	num_to_str(entid, key, charsmax(key));

	new DataPack:value;
	if (TrieGetCell(handle, key, value)) {
		DestroyDataPack(value);
		TrieDeleteKey(handle, key);
	}
}

stock RenderGroups_Destroy(&Trie:handle) {
	new DataPack:value;

	new TrieIter:iter = TrieIterCreate(handle);
	while (!TrieIterEnded(iter)) {
		if (TrieIterGetCell(iter, value))
			DestroyDataPack(value);
		TrieIterNext(iter);
	}
	TrieIterDestroy(iter);

	TrieDestroy(handle);
	handle = Invalid_Trie;
}

stock WritePackVector(DataPack:pack, const Float:vector[3]) {
	for (new i; i < 3; i++)
		WritePackFloat(pack, vector[i]);
}

stock ReadPackVector(DataPack:pack, Float:vector[3]) {
	for (new i; i < 3; i++)
		vector[i] = ReadPackFloat(pack);
}
