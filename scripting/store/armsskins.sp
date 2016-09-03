enum ArmsSkin
{
	String:szArms[PLATFORM_MAX_PATH],
	iTeam
}

new g_eArmsSkins[STORE_MAX_ITEMS][ArmsSkin];

new g_iArmsSkins = 0;
public ArmsSkins_OnPluginStart()
{
		
	//LoadTranslations("store.phrases");
	
	Store_RegisterHandler("armsskin", "arms", ArmsSkins_OnMapStart, ArmsSkins_Reset, ArmsSkins_Config, ArmsSkins_Equip, ArmsSkins_Remove, true);
	
	HookEvent("player_spawn", ArmsSkins_PlayerSpawn);
}


public ArmsSkins_OnMapStart()
{
	for(new i=0;i<g_iArmsSkins;++i)
	{

		if(g_eArmsSkins[i][szArms][0]!=0)
		{
			PrecacheModel2(g_eArmsSkins[i][szArms], true);
			Downloader_AddFileToDownloadsTable(g_eArmsSkins[i][szArms]);
		}
	}
}

public ArmsSkins_Reset()
{
	g_iArmsSkins = 0;
}

public ArmsSkins_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, g_iArmsSkins);
	
	KvGetString(kv, "arms", g_eArmsSkins[g_iArmsSkins][szArms], PLATFORM_MAX_PATH);
	g_eArmsSkins[g_iArmsSkins][iTeam] = KvGetNum(kv, "team");
	
	if(FileExists(g_eArmsSkins[g_iArmsSkins][szArms], true))
	{
		++g_iArmsSkins;
		return true;
	}
	
	return false;
}

public ArmsSkins_Equip(client, id)
{
	if(Store_IsClientLoaded(client))
		Chat(client, "%t", "PlayerSkins Settings Changed");

	return g_eArmsSkins[Store_GetDataIndex(id)][iTeam]-2;
}

public ArmsSkins_Remove(client, id)
{
	if(Store_IsClientLoaded(client))
		Chat(client, "%t", "PlayerSkins Settings Changed");
	return g_eArmsSkins[Store_GetDataIndex(id)][iTeam]-2;
}

public Action:ArmsSkins_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || !(2<=GetClientTeam(client)<=3))
		return Plugin_Continue;
		
	new m_iEquipped = Store_GetEquippedItem(client, "armsskin", 2);
	if(m_iEquipped < 0)
		m_iEquipped = Store_GetEquippedItem(client, "armsskin", GetClientTeam(client)-2);
	if(m_iEquipped >= 0)
	{
		decl m_iData;

		m_iData = Store_GetDataIndex(m_iEquipped);
		//PrintToChat(client, "you have %s", g_eArmsSkins[m_iData][szArms]);
		SetEntPropString(client, Prop_Send, "m_szArmsModel", g_eArmsSkins[m_iData][szArms]);
	}
	return Plugin_Continue;
}