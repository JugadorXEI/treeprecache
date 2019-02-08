#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "v1.0"
#define TREE_PATH "models/props_foliage/tree_pine_small.mdl"

public Plugin myinfo =
{
	name = "Tree Precache",
	author = "JugadorXEI",
	description = "Literally just precaches a tree",
	version = PLUGIN_VERSION,
	url = "https://github.com/JugadorXEI",
}

ConVar g_bIsEnabled; // Do we really want to precache this tree? Probably.
ConVar g_cSequoiaMap; // Sequoia map string.
ConVar g_cMissionName; // Mission name string.
ConVar g_bLogTree; // Log if tree was precached.

public void OnPluginStart()
{
	g_bIsEnabled = CreateConVar("sm_mvmtree_precachetree", "1",
	"Enables/Disables the plugin. Default = 1, 0 to disable",
	FCVAR_PROTECTED, true, 0.0, true, 1.0);
	
	g_cSequoiaMap = CreateConVar("sm_mvmtree_sequoianame", "mvm_sequoia",
	"Name of the map where we want to precache a tree on.", FCVAR_PROTECTED);
	
	g_cMissionName = CreateConVar("sm_mvmtree_missionname", "int_extended_deadline",
	"Name of the mission where we want to precache a mission on.", FCVAR_PROTECTED);
	
	g_bLogTree = CreateConVar("sm_mvmtree_logtree", "0",
	"Log if the tree has been precached. Default = 0, 1 to enable", FCVAR_PROTECTED);
	
	AddCommandListener(OnPopFileChanged, "tf_mvm_popfile");
}

public Action OnPopFileChanged(int iClient, const char[] cCommand, int iArgCount)
{
	// If the plugin's enabled
	if (g_bIsEnabled.BoolValue && iArgCount >= 1)
	{	
		// We try to get the map's current name
		char cMapName[128], cMapDisplayName[64];
		GetCurrentMap(cMapName, sizeof(cMapName));
		
		// We get their display name (only relevant for workshop maps but you never know!)
		if (GetMapDisplayName(cMapName, cMapDisplayName, sizeof(cMapDisplayName)) == true)
		{
			char cSequoiaMap[64];
			g_cSequoiaMap.GetString(cSequoiaMap, sizeof(cSequoiaMap));
			
			// Is it sequoia? We do a StrContains to account for older or newer versions.
			if (StrContains(cMapDisplayName, cSequoiaMap, false) != -1)
			{	
				char cMissionSet[128], cMissionName[64];
				g_cMissionName.GetString(cMissionName, sizeof(cMissionName));
			
				GetCmdArg(1, cMissionSet, sizeof(cMissionSet));
			
				// Is it Extended Deadline?
				if (StrContains(cMissionSet, cMissionName, false) != -1)
				{
					// Is the tree precached? If not, we precache it.
					if (!IsModelPrecached(TREE_PATH))
					{
						if (PrecacheModel(TREE_PATH) != 0)
						{
							if (g_bLogTree.BoolValue)
								LogMessage("Tree %s has been precached.", TREE_PATH);
						}
					}
				}
			}
		}
	}
}
