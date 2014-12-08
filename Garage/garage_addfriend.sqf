/*** Created by 0verHeaT ***/
private ["_index","_toadd","_friends","_inList"];
_index = _this select 0;
if (_index < 0) exitWith {cutText["\n\nNo Player selected!","PLAIN DOWN"]};

_toadd = GarageNearHumans select _index;
_friends = VirtualGarage getVariable ["GarageFriends",[]];

_inList = false;
{ 
	if ((_x  select 0) == (_toadd select 0)) exitWith { 
		_inList = true; 
	}; 
} count _friends;
if (_inList) exitWith { cutText ["\n\nThis Player is already in your friend list!", "PLAIN DOWN"]; };

VirtualGarage setVariable ["GarageFriends",_friends + [_toadd],true];

call garage_fillplayers;

sleep 2;
PVDZE_veh_Update = [VirtualGarage,"damage"];
publicVariableServer "PVDZE_veh_Update";
