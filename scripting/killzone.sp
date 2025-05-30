#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools_functions>
#include <mapzonelib>
#include <smlib>

// You can change it to whatever Admin flag you want
#define ADMIN_FLAG ADMFLAG_CONVARS

// You can change it to whatever color you want
// Red Green Blue Alpha
// 0 - 255
#define ZONE_COLOR { 255, 0, 0, 255 }

ConVar g_hCVEnabled;
ConVar g_hCVDebug;

public Plugin myinfo =
{
    name        = "Kill Zone",
    author      = "heapy",
    description = "Kills players when they walk into a zone.",
    url         = "https://github.com/heapyxyz/kill-zone"
};

public void OnPluginStart()
{
    RegAdminCmd("sm_killzone", Command_Menu, ADMIN_FLAG);
    RegAdminCmd("sm_killzone_edit", Command_Edit, ADMIN_FLAG);

    g_hCVEnabled = CreateConVar("sm_killzone_enabled", "1", "Enable Kill Zone?", _, true, 0.0, true, 1.0);
    g_hCVDebug = CreateConVar("sm_killzone_debug", "0", "Show debug messages?", _, true, 0.0, true, 1.0);
    AutoExecConfig(true, "killzone");

    PrintToServer("[Kill Zone] Hello, World!");
}

public void OnAllPluginsLoaded()
{
    MapZone_RegisterZoneGroup("killzone");
    MapZone_SetZoneDefaultColor("killzone", ZONE_COLOR);

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] Registered zone group \"killzone\".");
}

//////////////
// COMMANDS //
//////////////
public Action Command_Menu(int client, int args)
{
    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N ran: sm_killzone", client);

    if (args >= 2)
    {
        char arg[64];
        GetCmdArg(1, arg, sizeof(arg));

        char argToLower[64];
        String_ToLower(arg, argToLower, sizeof(argToLower));

        if (StrEqual(argToLower, "edit"))
        {
            char zoneName[MAX_ZONE_NAME];
            GetCmdArg(2, zoneName, sizeof(zoneName));

            if (g_hCVDebug.BoolValue)
                PrintToServer("[Kill Zone] %N ran: sm_killzone_edit \"%s\"", client, zoneName);

            if (!MapZone_ZoneExists("killzone", zoneName))
            {
                PrintToChat(client, "[Kill Zone] Zone with provided name doesn't exist!");
                return Plugin_Handled;
            }

            MapZone_ShowZoneEditMenu(client, "killzone", zoneName);
            return Plugin_Handled;
        }
    }

    MapZone_ShowMenu(client, "killzone");
    return Plugin_Handled;
}

public Action Command_Edit(int client, int args)
{
    char zoneName[MAX_ZONE_NAME];
    GetCmdArg(1, zoneName, sizeof(zoneName));

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N ran: sm_killzone_edit \"%s\"", client, zoneName);

    if (!MapZone_ZoneExists("killzone", zoneName))
    {
        PrintToChat(client, "[Kill Zone] Zone with provided name doesn't exist!");
        return Plugin_Handled;
    }

    MapZone_ShowZoneEditMenu(client, "killzone", zoneName);
    return Plugin_Handled;
}

//////////////
// FORWARDS //
//////////////
public void MapZone_OnZonesLoaded()
{
    PrintToServer("[Kill Zone] Zones loaded!");
}

public void MapZone_OnClientEnterZone(int client, const char[] groupName, const char[] zoneName)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N entered zone \"%s\".", client, zoneName);

    if (g_hCVEnabled.BoolValue && IsPlayerAlive(client))
        ForcePlayerSuicide(client);
}

public void MapZone_OnClientLeaveZone(int client, const char[] groupName, const char[] zoneName)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N left zone \"%s\".", client, zoneName);
}

public void MapZone_OnZoneCreated(const char[] groupName, const char[] zoneName, MapZoneType zoneType, int client)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N created zone \"%s\".", client, zoneName);

    MapZone_SetZoneColor(groupName, zoneName, ZONE_COLOR);
}

public void MapZone_OnZoneRemoved(const char[] groupName, const char[] zoneName, MapZoneType zoneType, int client)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N removed zone \"%s\".", client, zoneName);
}

public void MapZone_OnZoneAddedToCluster(const char[] groupName, const char[] zoneName, const char[] clusterName, int client)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N added zone \"%s\" to cluster \"%s\".", client, zoneName, clusterName);
}

public void MapZone_OnZoneRemovedFromCluster(const char[] groupName, const char[] zoneName, const char[] clusterName, int client)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N removed zone \"%s\" from cluster \"%s\".", client, zoneName, clusterName);
}

public void MapZone_OnClientTeleportedToZone(int client, const char[] groupName, const char[] zoneName)
{
    if (!StrEqual(groupName, "killzone"))
        return;

    if (g_hCVDebug.BoolValue)
        PrintToServer("[Kill Zone] %N teleported to zone \"%s\".", client, zoneName);
}