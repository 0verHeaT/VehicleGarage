/*** Created by 0verHeaT ***/
private ["_index","_toremove","_newfriends","_friends"];
_index = _this select 0;
if (_index < 0) exitWith {cutText["\n\nNo Player selected!","PLAIN DOWN"]};

_friends = VirtualGarage getVariable ["GarageFriends",[]];
_toremove = _friends select _index;

_newfriends = [];
{
	if ((_x select 0) != (_toremove select 0)) then {
		_newfriends set [count _newfriends,_x];
	};
} count _friends;

VirtualGarage setVariable ["GarageFriends",_newfriends,true];

call garage_fillplayers;

sleep 2;
PVDZE_veh_Update = [VirtualGarage,"damage"];
publicVariableServer "PVDZE_veh_Update";
