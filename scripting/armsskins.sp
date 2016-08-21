#include <sourcemod>
#include <sdktools>

#include <store>
#include <zephstocks>

enum PlayerSkin
{
	String:szArms[PLATFORM_MAX_PATH],
	iTeam
}

new g_ePlayerSkins[STORE_MAX_ITEMS][PlayerSkin];

new g_iPlayerSkins = 0;
public OnPluginStart()
{
		
	LoadTranslations("store.phrases");
	
	Store_RegisterHandler("armsskin", "arms", PlayerSkins_OnMapStart, PlayerSkins_Reset, PlayerSkins_Config, PlayerSkins_Equip, PlayerSkins_Remove, true);
	
	HookEvent("player_spawn", PlayerSkins_PlayerSpawn);
}


public PlayerSkins_OnMapStart()
{
	for(new i=0;i<g_iPlayerSkins;++i)
	{

		if(g_ePlayerSkins[i][szArms][0]!=0)
		{
			PrecacheModel2(g_ePlayerSkins[i][szArms], true);
			Downloader_AddFileToDownloadsTable(g_ePlayerSkins[i][szArms]);
		}
	}
}

public PlayerSkins_Reset()
{
	g_iPlayerSkins = 0;
}

public PlayerSkins_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, g_iPlayerSkins);
	
	KvGetString(kv, "arms", g_ePlayerSkins[g_iPlayerSkins][szArms], PLATFORM_MAX_PATH);
	g_ePlayerSkins[g_iPlayerSkins][iTeam] = KvGetNum(kv, "team");
	
	if(FileExists(g_ePlayerSkins[g_iPlayerSkins][szArms], true))
	{
		++g_iPlayerSkins;
		return true;
	}
	
	return false;
}

public PlayerSkins_Equip(client, id)
{
	if(Store_IsClientLoaded(client))
		Chat(client, "%t", "PlayerSkins Settings Changed");

	return g_ePlayerSkins[Store_GetDataIndex(id)][iTeam]-2;
}

public PlayerSkins_Remove(client, id)
{
	if(Store_IsClientLoaded(client))
		Chat(client, "%t", "PlayerSkins Settings Changed");
	return g_ePlayerSkins[Store_GetDataIndex(id)][iTeam]-2;
}

public Action:PlayerSkins_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
			
	new m_iEquipped = Store_GetEquippedItem(client, "armsskin", 2);
	if(m_iEquipped < 0)
		m_iEquipped = Store_GetEquippedItem(client, "armsskin", GetClientTeam(client)-2);
	if(m_iEquipped >= 0)
	{
		decl m_iData;

		m_iData = Store_GetDataIndex(m_iEquipped);
		
		SetEntPropString(client, Prop_Send, "m_szArmsModel", g_ePlayerSkins[m_iData][szArms]);
	}
	return Plugin_Continue;
}