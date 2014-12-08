/*** Created by 0verHeaT ***/
private ["_nearplayers","_friends"];
lbClear 5204;
lbClear 5205;
_nearplayers = player nearEntities ["CAManBase", 10];

GarageNearHumans = [];
{
	private ["_name","_puid"];
	if (_x isKindOf "Man" && !(_x isKindOf "zZombie_base")) then {
		_name = name  _x;
		_puid = getPlayerUID _x;
		GarageNearHumans set [count GarageNearHumans,[_puid,_name]];
		lbAdd [5204,_name];
	};
} forEach _nearplayers;

_friends = VirtualGarage getVariable ["GarageFriends",[]];

{
	lbAdd [5205,(_x select 1)];
} forEach _friends;
