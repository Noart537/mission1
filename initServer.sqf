/*
Author:

	BACONMOP
Edited by:
S0zi0p4th
Ryko
Stanhope
LostBullet
McKillen
Description:

	Things that may run on the server.
	
last edited: 12/08/2017 by stanhope

edited: derp event handler
*/

//=========declairing and setting stuff==========
missionActive = true;
enableSaving false;
artySorcher allowDamage False;
artyMLRS allowDamage False;
artySorcher allowFleeing 0;
artyMLRS allowFleeing 0;

controlledZones = [];
publicVariable "controlledZones";

CVN_CIWS_Active = false;
CVN_CIWS_Cooldown = false;

adminCurators = allCurators;
enableEnvironment FALSE;

//=======for jets from the radiotower
jetCounter = 0;
for [ {_i = 0;}, {_i < count(paramsArray);}, {_i = _i + 1;} ] do {
	call compile format
	[
		"PARAMS_%1 = %2",
		(configName ((missionConfigFile >> "Params") select _i)),
		(paramsArray select _i)
	];
};

//some params
AW_PARAM_MainEnemyFaction = "MainEnemyFaction" call BIS_fnc_getParamValue;
AW_PARAM_SecondaryEnemyFaction = "SecondaryEnemyFaction" call BIS_fnc_getParamValue;
[] call AW_fnc_factionDefine;

//for some scripts
_mapSize = [configfile >> "cfgworlds" >> "Altis","mapSize"] call bis_fnc_returnConfigEntry;
_mapHalf = _mapSize / 2;
mapCent = [_mapHalf,_mapHalf,0];
publicVariable "mapCent";


addMissionEventHandler ["HandleDisconnect", 
	{
		_this params ["_unit", "", "", "_name"];
		if ("derp_revive" in (getMissionConfigValue "respawnTemplates")) then {
			_unit setVariable ["derp_revive_downed", false, true];
		};
		false
	}
];

//arsenal restricitons
#include "defines\arsenalDefines.hpp"
[ArsenalBoxes, ("ArsenalFilter" call BIS_fnc_getParamValue)] call derp_fnc_VA_filter; // Init arsenal boxes.

//hide some stuff:
{hideObjectGlobal _x} foreach nearestTerrainObjects [(getMarkerPos "marker_deletepad"),[],5]; 

_toHide = [];

_allStuff = (getMarkerPos "term_pl_res") nearObjects 250;
_fobStuff = _allStuff - nearestTerrainObjects [(getMarkerPos "term_pl_res"), [], 250, false];
_toHide = _toHide + _fobStuff;

_allStuff = (getMarkerPos "aac_pl_res") nearObjects 250;
_fobStuff = _allStuff - nearestTerrainObjects [(getMarkerPos "aac_pl_res"), [], 250, false];
_toHide = _toHide + _fobStuff;

_allStuff = (getMarkerPos "sdm_pl_res") nearObjects 250;
_fobStuff = _allStuff - nearestTerrainObjects [(getMarkerPos "sdm_pl_res"), [], 250, false];
_toHide = _toHide + _fobStuff;

_allStuff = (getMarkerPos "mol_pl_res") nearObjects 250;
_fobStuff = _allStuff - nearestTerrainObjects [(getMarkerPos "mol_pl_res"), [], 250, false];
_toHide = _toHide + _fobStuff;

{_x hideObjectGlobal true;} forEach _toHide;

//let's start this baby up
sleep 5;
mainObjScript = [] execVM "Missions\Main\Main_Machine.sqf";				// Main Aos
prioObjScript = [] execVM "Missions\Priority\MissionControl.sqf";		// Priority Missions
sideObjScript = [] execVM "Missions\Side\MissionControl.sqf";			// Side Missions
execVM "scripts\misc\airbaseDefense.sqf";								// Airbase air defense
execVM "scripts\misc\cleanup.sqf";										// cleanup
execVM "scripts\misc\zeusupdater.sqf";									// zeus updater


//======================Zeus Modules

zeusModules = [zeus_1, zeus_2, zeus_3];

// get local Zeus info
//#include "\arma3_readme.txt";

//======================Zeus Acces and welcome msg

initiateZeusByUID = {
	params ["_player"];
	
	private ["_uid", "_zeusUIDs", "_zeusModuleNumber", "_zeusModule"];
	_uid = getPlayerUID _player;

	if !( isNil {_player getVariable 'zeusModule'} ) then
	{	unassignCurator (zeusModules select (_player getVariable 'zeusModule')); };
	_player setVariable ["zeusModule", nil];
	_player setVariable ["isAdmin", false, true];
    _player setVariable ["isZeus", false, true];

	_zeusUIDs = zeusAdminUIDs + zeusModeratorUIDs + zeusSpartanUIDs;
	
	_zeusModuleNumber = _zeusUIDs find _uid;
	
	if ( _zeusModuleNumber == -1 ) exitWith
	{	[parseText format ["<t align='center' font='PuristaBold' ><t size='1.6'>%1</t><br /> 
<t size='1.2'>Welcome %2</t><br /><t size='0.8' font='PuristaMedium'>Ensure you are familiar with our server rules:<br /> www.ahoyworld.net/index/rules</t>", "INVADE AND ANNEX", name _player], true, nil, 12, 0.3, 0.3] remoteExec ["BIS_fnc_textTiles", _player]; };
	
	if ( (zeusModeratorUIDs find _uid) > -1 ) exitWith
	{	[parseText format ["<br /><t align='center' font='PuristaBold' ><t size='1.6'>%1</t><br /> 
<t size='1.2'>Welcome %2</t>", "AWE MODERATOR: ZEUS NOT ASSIGNED", name _player], true, nil, 12, 0.3, 0.3] remoteExec ["BIS_fnc_textTiles", _player]; };
	
	_zeusModule = zeusModules select _zeusModuleNumber;
	unassignCurator _zeusModule;
	_player assignCurator _zeusModule;
	_player setVariable ["zeusModule", _zeusModuleNumber];
	[_zeusModule,[-1,-2,0]] call BIS_fnc_setCuratorVisionModes;
	adminChannelID radioChannelAdd [_player];

	if ( (zeusSpartanUIDs find _uid) > -1 ) then
	{	_player setVariable ["isZeus", true, true];
		diag_log format ['Zeus (spartan) assigned on %1', name _player];
		[parseText format ["<br /><t align='center' font='PuristaBold' ><t size='1.6'>%1</t><br /> 
<t size='1.2'>Welcome %2</t>", "ZEUS (SPARTAN) ASSIGNED", name _player], true, nil, 12, 0.3, 0.3] remoteExec ["BIS_fnc_textTiles", _player];
	};

	if ( (zeusAdminUIDs find _uid) > -1 ) then
	{	_player setVariable ["isAdmin", true, true];
		_player setVariable ["isZeus", true, true];
		diag_log format ['Zeus (admin) assigned on %1', name _player];
		[parseText format ["<br /><t align='center' font='PuristaBold' ><t size='1.6'>%1</t><br /> 
<t size='1.2'>Welcome %2</t>", "ZEUS (PUBLIC MOD) ASSIGNED", name _player], true, nil, 12, 0.3, 0.3] remoteExec ["BIS_fnc_textTiles", _player];
	};
};