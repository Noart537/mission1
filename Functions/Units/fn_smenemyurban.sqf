/*
Author: 

	Stanhope, based off of Quiksilvers fn_smenemyeast.sqf script.
	
Last modified:

	6/09/2017
	
Modified:

	group naming, general stuff
	
Description:

	Spawn OPFOR enemy around side objectives both in and out buildings.
	Enemy should have backbone of garrisoned enemies + random patrol inf + vehicle.
	
*/

private ["_i","_randomPos","_enemiesArray","_infteamPatrol","_faction","_civs","_civkilled","_civgroup",
"_side","_infteams","_Randomvehicle","_vehicletype","_vehicle1","_Vehiclegroup1","_infunits","_infbuildingpos","_GarrisonedBuildings",
"_buildingposcount","_unittype","_groupSide","_garrisongroup","_infBuildingAmount","_infBuildingArray","_unit","_Garrisonpos","_infBuilding"];


_enemiesArray = [grpNull];
_i = 0;

//======selecting side & faction:======

_side = selectrandom [East,Independent,Independent,Independent];

if (_side ==East) then{
  _faction = "OPF_F";
  _groupSide = "East";
};
if (_side ==Independent) then{
  _faction = selectrandom ["IND_C_F","IND_C_F","IND_F"];
  _groupSide = "Indep";
};

//=============civs==============

_civs = ["C_man_1","C_man_polo_1_F_euro","C_man_polo_2_F_euro","C_man_polo_2_F","C_man_polo_3_F","C_man_polo_4_F","C_man_polo_6_F","C_man_shorts_4_F_asia"];

//=====defining inf groups=======
if (_faction =="OPF_F") then{
_infteams = ["OI_reconPatrol","OI_reconTeam","OIA_InfAssault","OIA_InfSquad","OIA_InfSquad_Weapons","OIA_InfTeam","OIA_InfTeam_AT","OIA_InfTeam_AA"];
};
if (_faction =="IND_C_F") then{
_infteams = ["BanditCombatGroup","BanditFireTeam","BanditShockTeam","ParaCombatGroup","ParaFireTeam","ParaShockTeam"];
};
if (_faction =="IND_F") then{
_infteams = ["HAF_InfSquad","HAF_InfSquad_Weapons","HAF_InfTeam","HAF_InfTeam_AA","HAF_InfTeam_AT"];
};
sleep 0.1;

//=====defining vehicles=========
_Randomvehicle = ["I_G_Offroad_01_armed_F","O_G_Offroad_01_armed_F"];	
sleep 0.1;

//=====defining inf units=======
if (_faction =="OPF_F") then{
_infunits = ["O_Soldier_F","O_Soldier_lite_F","O_Soldier_GL_F","O_Soldier_AR_F","O_soldier_M_F","O_Soldier_LAT_F","O_medic_F","O_engineer_F"];
};
if (_faction =="IND_C_F") then{
_infunits = ["I_C_Soldier_Para_1_F","I_C_Soldier_Para_2_F","I_C_Soldier_Para_3_F","I_C_Soldier_Para_4_F","I_C_Soldier_Para_5_F","I_C_Soldier_Para_6_F","I_C_Soldier_Para_7_F","I_C_Soldier_Para_8_F","I_C_Soldier_Bandit_1_F","I_C_Soldier_Bandit_3_F"];
};
if (_faction =="IND_F") then{
_infunits = ["I_soldier_F","I_Soldier_lite_F","I_Soldier_GL_F","I_Soldier_AR_F","I_Soldier_M_F","I_medic_F","I_Soldier_repair_F","I_Soldier_exp_F","I_engineer_F"];
};
sleep 0.1;

//---------- INFANTRY RANDOM
private _patrolgroupamount = 0;

for "_i" from 0 to (2 + (random 2)) do {
	_randomPos = [[[getPos sideObj, 300],[]],["water","out"]] call BIS_fnc_randomPos;
	_infteamPatrol = createGroup _side;
	_infteamPatrol = [_randomPos, _side, (configfile >> "CfgGroups" >> _groupSide >> _faction >> "Infantry" >> selectRandom _infteams )] call BIS_fnc_spawnGroup;
	_patrolgroupamount = _patrolgroupamount + 1;
	_infteamPatrol setGroupIdGlobal [format ['Side-Patrolinf-%1', _patrolgroupamount]];
	[_infteamPatrol, getPos sideObj, 100] call BIS_fnc_taskPatrol;
	_enemiesArray = _enemiesArray + (units _infteamPatrol);
	[(units _infteamPatrol)] call AW_fnc_setSkill2;	
	{_x addCuratorEditableObjects [units _infteamPatrol, false];} foreach allCurators;
	sleep 0.1;
};

	
//---------- RANDOM VEHICLE  1
private _vehpatrolgroupamount = 0;

_randomPos = [[[getPos sideObj, 300],[]],["water","out"]] call BIS_fnc_randomPos;

_Vehiclegroup1 = createGroup _side;
_vehicletype = selectRandom _Randomvehicle;
_vehicle1 = _vehicletype createVehicle _randomPos;

createvehiclecrew _vehicle1;
(crew _vehicle1) join _Vehiclegroup1;
_vehpatrolgroupamount = _vehpatrolgroupamount + 1;
_Vehiclegroup1 setGroupIdGlobal [format ['Side-VehPatrol-%1', _vehpatrolgroupamount]];
_vehicle1 lock 3;
[_Vehiclegroup1, getPos sideObj, 100] call BIS_fnc_taskPatrol;
{_x addCuratorEditableObjects [[_vehicle1], false];} foreach allCurators;
{_x addCuratorEditableObjects [units _Vehiclegroup1, false];} foreach allCurators;
_enemiesArray = _enemiesArray + (units _Vehiclegroup1) + [_vehicle1];


//-----------enemies in buildings
private _garrisongroupamount = 0;

_infBuildingArray = nearestObjects [sideObj, ["house","building"], 200];
_infBuildingAmount = count _infBuildingArray;

if (_infBuildingAmount > 0) then {

	if (_infBuildingAmount < 21 ) then {_GarrisonedBuildings = _infBuildingAmount;};
	if (_infBuildingAmount > 20 ) then {_GarrisonedBuildings = _infBuildingAmount*3/4;};
	if (_infBuildingAmount > 40 ) then {_GarrisonedBuildings = _infBuildingAmount/2;};
	if (_infBuildingAmount > 60 ) then {_GarrisonedBuildings = 30;};

	for "_i" from 0 to _GarrisonedBuildings do {
		_garrisongroup = createGroup _side;
		_garrisongroupamount = _garrisongroupamount + 1;
		_garrisongroup setGroupIdGlobal [format ['Side-GarrisonGroup-%1', _garrisongroupamount]];
		_infBuilding = selectRandom _infBuildingArray;
		_infBuildingArray = _infBuildingArray - [_infBuilding];
		_infbuildingpos = _infBuilding buildingPos -1;
		
		_buildingposcount = count _infbuildingpos;
		_Garrisonpos = _buildingposcount/2;
		
		for "_i" from 1 to _Garrisonpos do {
			_unitpos = selectRandom _infbuildingpos;
			_infbuildingpos = _infbuildingpos - _unitpos;
			_unittype = selectRandom _infunits;
			_unit = _garrisongroup createUnit [_unittype, _unitpos, [], 0, "CAN_COLLIDE"];
			_unit disableAI "PATH";
			sleep 0.1;
		};
		_enemiesArray = _enemiesArray + (units _garrisongroup);
		{_x addCuratorEditableObjects [units _garrisongroup, false];} foreach allCurators;
	};
};


//-------------civs
private _civgroupamount = 0;

for "_i" from 1 to 4 do {
	_randomPos = [[[getPos sideObj, 250],[]],["water","out"]] call BIS_fnc_randomPos;
	_unittype = selectRandom _civs;
	_civgroup = createGroup Civilian;
	_civgroupamount = _civgroupamount + 1;
	_civgroup setGroupIdGlobal [format ['Side-CivGroup-%1', _civgroupamount]];
	
	for "_i" from 1 to (2+ random 2) do {
		_unit = _civgroup createUnit [_unittype, _randomPos, [], 0, "CAN_COLLIDE"];
		_unit addEventHandler ["Killed",{
			params ["_unit","","_killer"];
			_name = name _killer;
			if !(_name == "Error: No vehicle") then{
			_civkilled = format["<t align='center'><t size='2.2'>%1 killed a civilian!</t><br/>____________________<br/>High command doesn't like civilian casualties.  DO NOT kill civilians</t>",_name];
			[_civkilled] remoteExec ["AW_fnc_globalHint",0,false];
			};
		}];
	};
	[_civgroup, getPos sideObj, 150] call BIS_fnc_taskPatrol;
	_enemiesArray = _enemiesArray + (units _civgroup);
	{_x addCuratorEditableObjects [units _civgroup, false];} foreach allCurators;
	sleep 0.1;
};

	
_enemiesArray