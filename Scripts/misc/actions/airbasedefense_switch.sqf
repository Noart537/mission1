if (AIRBASEDEFENSE_SWITCH) exitWith {
	[parseText format ["<br /><t align='center' font='PuristaBold' size='1.4'>Air-defense unavailable.</t>"], true, nil, 3, 1, 0.3] spawn BIS_fnc_textTiles;	
};

//[[player,"AinvPercMstpSrasWrflDnon_Putdown_AmovPercMstpSrasWrflDnon"],"QS_fnc_switchMoveMP",nil,false] spawn BIS_fnc_MP;

//-------------------- Wait for player to action

sleep 1;

//-------------------- Send hint to player that he's planted the bomb

[parseText format ["<br /><t align='center' font='PuristaBold' size='1.4'>Activating air-defense ...</t>"], true, nil, 3, 1, 0.3] spawn BIS_fnc_textTiles;	

sleep 3;

//---------- Send notice to all players that charge has been set.

AIRBASEDEFENSE_SWITCH = true; 
publicVariable "AIRBASEDEFENSE_SWITCH";