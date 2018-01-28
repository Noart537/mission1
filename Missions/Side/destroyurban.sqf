/*
@file: destroyUrban.sqf
Initial authors:
	Quiksilver, 
	Jester [AW] for initial build,
	chucky [allFPS] for initial help with addAction,	
	BangaBob [EOS] for EOS
	
Rewritten for I&A 3.2 by stanhope
	
Last modified: 

	5/09/2017
	
Modified:

	forgot to add something to delete that hintcircle that's not a cirlce, fixed now
	
Description:

	Objective appears in urban area, with selection of OPFOR Uinfantry, and civilians.
	Inf spawn in foot patrols and randomly placed in and around buildings.
	Vehicle spawning can be unstable and the veh can spawn into buildings.
	Good CQB mission and players seem to enjoy it.

_____________________________________________________________________*/


private ["_RandomTownPosition","_cacheBuildingLocationFinal"];

private _noSpawning =  BaseArray + [currentAO];
private _noSpawningRange = 2500;

//-------------------- PREPARE MISSION. SELECT OBJECT, POSITION AND MESSAGES FROM ARRAYS

private _towns = nearestLocations [(getMarkerPos "Base"), ["NameCity","NameCityCapital"], 25000];

private _accepted = false;
while {!_accepted} do {
	_RandomTownPosition = position (selectRandom _towns);	
	_accepted = true;
	{
		private _NearBaseLoc = _RandomTownPosition distance (getMarkerPos _x);
		if (_NearBaseLoc < _noSpawningRange) then {_accepted = false;};
	} forEach _noSpawning;
};
	
//-------------------- move obj to the AO

	private _objective = selectRandom ["Box_NATO_AmmoVeh_F","Box_East_AmmoVeh_F"];
	
	private _cacheBuildingArray = nearestObjects [_RandomTownPosition, ["house","building"], 300];
	private _cacheBuildingArrayAmount = count _cacheBuildingArray;
	
	if (_cacheBuildingArrayAmount > 0) then {
	_accepted = false;
	
		while {!_accepted} do {
			private _cacheBuilding = selectRandom _cacheBuildingArray;
			_cacheBuildingLocationFinal = selectRandom (_cacheBuilding buildingPos -1);
			
			if !(_cacheBuildingLocationFinal isEqualTo [0,0,0]) then {
				sideObj = createVehicle [_objective, _cacheBuildingLocationFinal, [], 0, "CAN_COLLIDE"];
				sideObj allowDamage false;
				_accepted = true;
			};
		};
	};
	/*Todo: error handeling for: no building found, and no final pos found*/

	[sideObj,"Plant charges",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\use_ca.paa",
    "_target distance _this <= 5","_target distance _this <= 5",
    {   hint "Planting charges ...";
         params ["","_hero"];
        if ( currentWeapon _hero != "" ) then
        {	_hero action ["SwitchWeapon", _hero, _hero, 99]; };
        _hero playMoveNow "AinvPknlMstpSnonWnonDnon_medic3";
    },{},{execVM "missions\side\actions\sabotage.sqf"},
    {   hint "You stopped planting charges.";
        private _unit = _this select 1;
        _unit playMoveNow "";
    },[], 8, 0,true,false] remoteExecCall ["BIS_fnc_holdActionAdd", 0, true];

    sideObj addEventHandler ["Killed",{
        params ["","","_killer"];
        _name = name _killer;
        if !(_name == "Error: No vehicle") then{
       private _sidecompleted = format["<t align='center'><t size='2.2'>Side-mission update</t><br/>____________________<br/>%1 has destroyed the cache, good job everyone!</t>",_name];
       [_sidecompleted] remoteExec ["AW_fnc_globalHint",0,false];
        };
    }];
	
//-------------------- SPAWN GUARDS and CIVILIANS
	private _enemiesArray = [sideObj] call AW_fnc_smenemyurban;
	
//-------------------- BRIEFING
	//smaller cirle to make it a tad easier
	private _objectivepos = getPos sideObj;
	private _fuzzyPos = [((_objectivepos select 0) - 50) + (random 100),((_objectivepos select 1) - 50) + (random 100),0];
	private _hintCircle = createMarker ["hintCircle",_fuzzyPos];
	"hintCircle" setMarkerShape "RECTANGLE";
	"hintCircle" setMarkerBrush "BDiagonal";
	"hintCircle" setMarkerSize [100, 100];

	{ _x setMarkerPos _RandomTownPosition; } forEach ["sideMarker", "sideCircle"];
	sideMarkerText = "Destroy Weapons Shipment";
	"sideMarker" setMarkerText "Side Mission: Destroy Weapons Shipment";
    [west,["urbancacheTask"],[
    "Enemy forces have moved a cache with advanced weapons into a town and are planning on handing those out to hostile guerrilla forces.  Find the cache and destroy it.  The cache will be in the village marked on the map, and is in all likelihood in the square marked with diagonal lines.  The cache will look similar to this one: <br/><br/><img image='Media\Briefing\urbanCache.jpg' width='300' height='150'/>"
    ,"Side Mission: Destroy Weapons Shipment","sideCircle"],(getMarkerPos "sideCircle"),
    "Created",0,true,"search",true] call BIS_fnc_taskCreate;
	
	sideMissionSpawnComplete = true;
	publicVariableServer "sideMissionSpawnComplete";

//--------------------- WAIT UNTIL OBJECTIVE COMPLETE: Sent to sabotage.sqf to wait for SM_SUCCESS var.
	sideMissionUp = true;
	SM_SUCCESS = false;
	sideObj allowDamage true;
	
	waitUntil { sleep 5; SM_SUCCESS || !sideMissionUp || !alive sideObj };

//--------------------- BOOM
if (alive sideObj) then {
    sleep 30;			// ghetto bomb timer
    deleteVehicle sideObj;
    "Bo_GBU12_LGB" createVehicle _cacheBuildingLocationFinal; 		// default "Bo_Mk82"
    sleep 4 + (random 3);
    "SmallSecondary" createVehicle (_cacheBuildingLocationFinal getPos [random 1, random 360]);
    sleep 0.2;
    "SmallSecondary" createVehicle (_cacheBuildingLocationFinal getPos [random 1, random 360]);
    sleep 2 + (random 2);
    "SmallSecondary" createVehicle (_cacheBuildingLocationFinal getPos [random 2, random 360]);
    sleep 1 + (random 2);
    "SmallSecondary" createVehicle (_cacheBuildingLocationFinal getPos [random 2, random 360]);
    sleep 0.2;
    "SmallSecondary" createVehicle (_cacheBuildingLocationFinal getPos [random 2, random 360]);
};

//-------------------- DE-BRIEFING
	sideMissionUp = false;
	[] call AW_fnc_SMhintSUCCESS;
	deleteMarker "hintCircle";
	{ _x setMarkerPos [-10000,-10000,-10000]; } forEach ["sideMarker", "sideCircle"];
	["urbancacheTask", "SUCCEEDED",true] call BIS_fnc_taskSetState;
	sleep 5;
	["urbancacheTask",west] call bis_fnc_deleteTask;
	
//--------------------- DELETE, DESPAWN, HIDE and RESET
	sleep 120;
	{ [_x] spawn AW_fnc_SMdelete } forEach [_enemiesArray];
