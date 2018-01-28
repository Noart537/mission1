/*
author:
	?
Last modified:
	19/06/2017 by stanhope
	
modified:
 Fog stuff
	
Description:
scripts that cleans up things every so many seconds

*/

private ["_canDeleteGroup","_group","_groups","_units","_i"];

while {true} do {

	sleep 360 + (random 240);
	
	{deleteVehicle _x;} count allDead;
	sleep 1;
	{deleteVehicle _x;} count (allMissionObjects "CraterLong");
	sleep 1;
	{deleteVehicle _x;} count (allMissionObjects "WeaponHolder");
	sleep 1;
	{deleteVehicle _x;} count (allMissionObjects "WeaponHolderSimulated");
	sleep 1;
	{if (!isPlayer _x) then {_x enableFatigue FALSE;};} count allUnits;
	{if ((count units _x) == 0) then {deleteGroup _x;};} count allGroups;
	sleep 1;
	
    
    _ejectionItems = [
    "B_Ejection_Seat_Plane_Fighter_01_F",
    "B_Ejection_Seat_Plane_CAS_01_F",
    "O_Ejection_Seat_Plane_CAS_02_F",
    "O_Ejection_Seat_Plane_Fighter_02_F",
    "I_Ejection_Seat_Plane_Fighter_04_F",
    "I_Ejection_Seat_Plane_Fighter_03_F",
    "plane_fighter_01_canopy_f",
    "plane_fighter_02_canopy_f",
    "plane_fighter_03_canopy_f",
    "plane_fighter_04_canopy_f",
    "Plane_CAS_01_Canopy_f",
    "Plane_CAS_02_Canopy_f"];
    {if ( speed _x == 0 ) then
        {    deleteVehicle _x; }; 
    } forEach (entities [_ejectionItems, []]);
	
	
    _fog = fogParams;
	_fogValue = _fog select 0;
	_fogDecay = _fog select 1;
	_fogBase = _fog select 2;
	if (_fogdecay != 0) then {_fogdecay = 0;};
	if (_fogBase != 0) then {_fogBase = 0;};
	0 setFog [_fogValue, _fogDecay, _fogBase];
	sleep 1;
	
	if (_fogValue > 0.7) then {
	for "_i" from 0 to 19 do {_fogValue = _fogValue - 0.035; 0 setFog [_fogValue, _fogDecay, _fogBase]; sleep 2;};
	};
	if (_fogValue > 0.4) then {
	for "_i" from 0 to 19 do {_fogValue = _fogValue - 0.02; 0 setFog [_fogValue, _fogDecay, _fogBase]; sleep 2;};
	};
	
};

