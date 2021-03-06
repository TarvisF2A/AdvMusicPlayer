/******************************************************************/
/*                                                                */
/*                     Advanced Music Player                      */
/*                                                                */
/*                                                                */
/*  File:          global.sp                                      */
/*  Description:   An advance music player in source engine game. */
/*                                                                */
/*                                                                */
/*  Copyright (C) 2017  Kyle   https://ump45.moe                  */
/*  2017/12/30 22:06:14                                           */
/*                                                                */
/*  This code is licensed under the MIT License (MIT).            */
/*                                                                */
/******************************************************************/



ConVar g_cvarSEARCH;
ConVar g_cvarLYRICS;
ConVar g_cvarPLAYER;
ConVar g_cvarCACHED;
ConVar g_cvarECACHE;
ConVar g_cvarCREDIT;
ConVar g_cvarPROXYS;

void Global_CreateConVar()
{
    /* register console variables*/

    // url
    g_cvarSEARCH = CreateConVar("amp_url_search", "https://music.ump45.moe/api/search.php?s=",  "url for searching music");
    g_cvarLYRICS = CreateConVar("amp_url_lyrics", "https://music.ump45.moe/api/lyrics.php?id=", "url for downloading lyric");
    g_cvarPLAYER = CreateConVar("amp_url_player", "https://music.ump45.moe/api/player.php?id=", "url of motd player");
    g_cvarCACHED = CreateConVar("amp_url_cached", "https://music.ump45.moe/api/cached.php?id=", "url for caching music");
    
    // others
    g_cvarECACHE = CreateConVar("amp_url_cached_enable",   "0",   "enable music cached in your web server (0 = disabled, 1 = enabled). In some areas, player can not direct connect to server. use ur web server to cache music", _, true, 0.0, true, 1.0);
    g_cvarCREDIT = CreateConVar("amp_cost_factor",         "2.0", "how much for broadcasting song (if store is availavle). song length(sec) * this value = cost credits.", _, true, 0.0, true, 100.0);
    g_cvarPROXYS = CreateConVar("amp_player_proxy_enable", "0",   "In some areas, if your web server can not direct connect to music server. enable this to use proxy (proxy server: https://music.ump45.moe)", _, true, 0.0, true, 1.0);

    // hook cvars
    HookConVarChange(g_cvarSEARCH, Global_OnConVarChanged);
    HookConVarChange(g_cvarLYRICS, Global_OnConVarChanged);
    HookConVarChange(g_cvarPLAYER, Global_OnConVarChanged);
    HookConVarChange(g_cvarCACHED, Global_OnConVarChanged);
    HookConVarChange(g_cvarECACHE, Global_OnConVarChanged);
    HookConVarChange(g_cvarCREDIT, Global_OnConVarChanged);
    HookConVarChange(g_cvarPROXYS, Global_OnConVarChanged);
    
    if(g_bCoreLib || g_bMGLibrary)
        return;
    
    AutoExecConfig(true, "com.kxnrl.amp.config");
}

public void Global_OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if(g_bCoreLib || g_bMGLibrary)
        return;

    // get cvars value
    g_cvarSEARCH.GetString(g_urlSearch, 192);
    g_cvarLYRICS.GetString(g_urlLyrics, 192);
    g_cvarPLAYER.GetString(g_urlPlayer, 192);
    g_cvarCACHED.GetString(g_urlCached, 192);
    
    g_iEnableCache = g_cvarECACHE.IntValue;
    g_iEnableProxy = g_cvarPROXYS.IntValue;
    g_fFactorCredits = g_cvarCREDIT.FloatValue;
    
#if defined DEBUG
    UTIL_DebugLog("Global_OnConVarChanged -> amp_url_search -> %s", g_urlSearch);
    UTIL_DebugLog("Global_OnConVarChanged -> amp_url_lyrics -> %s", g_urlLyrics);
    UTIL_DebugLog("Global_OnConVarChanged -> amp_url_player -> %s", g_urlPlayer);
    UTIL_DebugLog("Global_OnConVarChanged -> amp_url_cached -> %s", g_urlCached);
    
    UTIL_DebugLog("Global_OnConVarChanged -> amp_url_cached_enable -> %d", g_iEnableCache);
    UTIL_DebugLog("Global_OnConVarChanged -> amp_player_proxy_enable -> %s", g_iEnableProxy);
    UTIL_DebugLog("Global_OnConVarChanged -> amp_cost_factor -> %.2f", g_fFactorCredits);
#endif
}

void Global_CheckLibrary()
{
    // check library availavle
    g_bCoreLib = LibraryExists("core") && (GetFeatureStatus(FeatureType_Native, "CG_ShowHiddenMotd") == FeatureStatus_Available);
    g_bStoreLib = LibraryExists("store") && (GetFeatureStatus(FeatureType_Native, "Store_GetClientCredits") == FeatureStatus_Available);
    g_bMotdEx = LibraryExists("MotdEx") && (GetFeatureStatus(FeatureType_Native, "MotdEx_ShowHiddenMotd") == FeatureStatus_Available);
    g_bMapMusic = LibraryExists("MapMusic") && (GetFeatureStatus(FeatureType_Native, "MapMusic_SetStatus") == FeatureStatus_Available);
    g_bMGLibrary = LibraryExists("mg-motd") && (GetFeatureStatus(FeatureType_Native, "MG_Motd_ShowHiddenMotd") == FeatureStatus_Available);
    g_bSystem2 = (GetFeatureStatus(FeatureType_Native, "System2_DownloadFile") == FeatureStatus_Available);
    if(!g_bSystem2 && GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") != FeatureStatus_Available)
        SetFailState("Why you not install System2 or SteamWorks?");
    
#if defined DEBUG
    UTIL_DebugLog("Global_CheckLibrary -> g_bCoreLib -> %s", g_bCoreLib ? "Loaded" : "Failed");
    UTIL_DebugLog("Global_CheckLibrary -> g_bStoreLib -> %s", g_bStoreLib ? "Loaded" : "Failed");
    UTIL_DebugLog("Global_CheckLibrary -> g_bMotdEx -> %s", g_bMotdEx ? "Loaded" : "Failed");
    UTIL_DebugLog("Global_CheckLibrary -> g_bMapMusic -> %s", g_bMapMusic ? "Loaded" : "Failed");
    UTIL_DebugLog("Global_CheckLibrary -> g_bMGLibrary -> %s", g_bMGLibrary ? "Loaded" : "Failed");
    UTIL_DebugLog("Global_CheckLibrary -> g_bSystem2 -> %s", g_bSystem2 ? "Loaded" : "Failed");
#endif
}