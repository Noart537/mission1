/*
Author: Quiksilver

Description:    Secure chopper
	
Last modified:  29/07/2017 by stanhope
	
modified:   pos finder
*/

#define CHOPPER_TYPE "O_Heli_Attack_02_black_F","O_Heli_Light_02_unarmed_F","B_Heli_Attack_01_F"
private ["_objPos","_flatPos","_accepted","_position","_randomDir","_hangar","_x","_enemiesArray","_briefing","_fuzzyPos","_unitsArray","_dummy","_object"];

private _noSpawning =  BaseArray + [currentAO];
private _noSpawningRange = 2000;

//-------------------- FIND SAFE POSITION FOR OBJECTIVE

	_flatPos = [0,0,0];
	_accepted = false;
	while {!_accepted} do {
		_position = [] call BIS_fnc_randomPos;
		_flatPos = _position isFlatEmpty [5,0,0.2,sizeOf "Land_TentHangar_V1_F",0,false];

		while {(count _flatPos) < 2} do {
			_position = [] call BIS_fnc_randomPos;
			_flatPos = _position isFlatEmpty [5,0,0.2,sizeOf "Land_TentHangar_V1_F",0,false];
		};

		_accepted = true;
		{
			_NearBaseLoc = _flatPos distance (getMarkerPos _x);
			if (_NearBaseLoc < _noSpawningRange) then {_accepted = false;};
		} forEach _noSpawning;
	};

	_objPos = [_flatPos, 25, 35, 10, 0, 0.5, 0] call BIS_fnc_findSafePos;

//-------------------- SPAWN OBJECTIVE

	_randomDir = (random 360);
	_hangar = "Land_TentHangar_V1_F" createVehicle _flatPos;
	waitUntil {!isNull _hangar};
	_hangar setPos [(getPos _hangar select 0), (getPos _hangar select 1), ((getPos _hangar select 2) - 1)];
	sideObj = (selectRandom CHOPPER_TYPE) createVehicle _flatPos;
	waitUntil {!isNull sideObj};
	{_x setDir _randomDir} forEach [sideObj,_hangar];
	sideObj lock 3;

	house = "Land_Cargo_House_V3_F" createVehicle _objPos;
	house setDir random 360;
	house allowDamage false;

	_object = selectRandom [research1,research2];
	_dummy = selectRandom [explosivesDummy1,explosivesDummy2];
	{ _x enableSimulation true } forEach [researchTable,_object];
	sleep 1;
	researchTable setPos [(getPos house select 0), (getPos house select 1), ((getPos house select 2) + 1)];
	sleep 1;
	[researchTable,_object,[0,0,0.82]] call BIS_fnc_relPosObject;

//-------------------- SPAWN FORCE PROTECTION

	_enemiesArray = [sideObj] call AW_fnc_SMenemyEAST;

//-------------------- BRIEF

	_fuzzyPos = [((_flatPos select 0) - 300) + (random 600),((_flatPos select 1) - 300) + (random 600),0];

	{ _x setMarkerPos _fuzzyPos; } forEach ["sideMarker", "sideCircle"];
	sideMarkerText = "Secure Chopper";
	"sideMarker" setMarkerText "Side Mission: Secure Chopper";
	sideMarkerText = "Secure Enemy Chopper";
    [west,["secureChopperTask"],["OPFOR forces have been provided with a new prototype attack chopper and they're keeping it in a hangar somewhere on the island.We've marked the suspected location on your map; head to the hangar, get the data and destroy the helicopter.","Side Mission: Secure Chopper","sideCircle"],(getMarkerPos "sideCircle"),"Created",0,true,"interact",true] call BIS_fnc_taskCreate;

	sideMissionUp = true;
	SM_SUCCESS = false;


while { sideMissionUp } do {

    sleep 2;

	if (!alive sideObj) exitWith {

		//-------------------- DE-BRIEFING
        ["secureChopperTask", "Failed",true] call BIS_fnc_taskSetState;
		sideMissionUp = false;
	};

	if (SM_SUCCESS) exitWith {

		//-------------------- BOOM!
		_dummy setPos [(getPos sideObj select 0), ((getPos sideObj select 1) +3), ((getPos sideObj select 2) + 0.5)];
		sleep 0.1;
		_object setPos [-10000,-10000,0];					// hide objective
		sleep 30;											// ghetto bomb timer
		"Bo_GBU12_LGB" createVehicle getPos _dummy; 		// default "Bo_Mk82"
		_dummy setPos [-10000,-10000,1];					// hide dummy
		researchTable setPos [-10000,-10000,1];				// hide research table
		sleep 0.1;

		//-------------------- DE-BRIEFING
		[] call AW_fnc_SMhintSUCCESS;
        ["secureChopperTask", "SUCCEEDED",true] call BIS_fnc_taskSetState;
		sideMissionUp = false;
	};

};

    //Cleanup
    sleep 5;
    ["secureChopperTask",west] call bis_fnc_deleteTask;
    { _x setMarkerPos [-10000,-10000,-10000]; } forEach ["sideMarker", "sideCircle"];
    { _x setPos [-10000,-10000,0]; } forEach [_object,researchTable,_dummy];			// hide objective pieces
    //--------------------- DELETE
    sleep 120;
    { deleteVehicle _x } forEach [sideObj,house];
    deleteVehicle nearestObject [_flatPos,"Land_TentHangar_V1_ruins_F"];
    [_enemiesArray] spawn AW_fnc_SMdelete;
