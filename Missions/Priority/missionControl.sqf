/*
Author: 

	Quiksilver

Last modified: 

	4/02/2016

Description:

	Priority Mission control

To do:

______________________________________________*/

private ["_mission","_currentMission","_nextMission","_delay","_loopTimeout","_playerCount","_minPlayerCount"];

_delay = 1500 + (random 600);
_loopTimeout = 10 + (random 10);

prioMissionList = [
	"Priorityarty",
	"Priorityarty",
	"Priorityarty",
	"priorityAA",
	"priorityreinforceAO"
];

PRIO_SWITCH = true; 
publicVariable "PRIO_SWITCH";
	
while { true } do {

	_players = allPlayers - entities "B_Helipilot_F";
	_playerCount = count _players;
	_minPlayerCount = 8 + floor (random 4);
	
	if (PRIO_SWITCH && (_playerCount >= _minPlayerCount)) then {
	
		_mission = selectRandom prioMissionList;
		_currentMission = execVM format ["missions\Priority\%1.sqf", _mission];
	
		waitUntil {
			sleep 5;
			scriptDone _currentMission
		};
	
		sleep _delay;
		
		PRIO_SWITCH = true; publicVariable "PRIO_SWITCH";
	};
	sleep _loopTimeout;
};
