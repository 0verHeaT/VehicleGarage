/*** Created by 0verHeaT ***/
private ["_nearvehicles"];
_nearvehicles = nearestObjects [(getPosATL player),["LandVehicle","Air"],30];
((uiNamespace getVariable "GarageDialog") displayCtrl 5202) ctrlSetStructuredText parseText format["<t align='left'>Vehicles Nearby (%1/30m)</t>",(count _nearvehicles)];

lbClear 5200;

VehNearbyList = [];
{
	private ["_vehname","_index","_id","_key","_keyname"];
	_id = _x getVariable["CharacterID","0"];
	_id = parsenumber _id;
	if (_id == 0) then {_key = ""};
	if ((_id > 0) && (_id <= 2500)) then {_key = format["ItemKeyGreen%1",_id];};
	if ((_id > 2500) && (_id <= 5000)) then {_key = format["ItemKeyRed%1",_id-2500];};
	if ((_id > 5000) && (_id <= 7500)) then {_key = format["ItemKeyBlue%1",_id-5000];};
	if ((_id > 7500) && (_id <= 10000)) then {_key = format["ItemKeyYellow%1",_id-7500];};
	if ((_id > 10000) && (_id <= 12500)) then {_key = format["ItemKeyBlack%1",_id-10000];};
	_vehname = getText(configFile >> "cfgVehicles" >> (typeOf _x) >> "displayName");
	_keyname = getText(configFile >> "CfgWeapons" >> _key >> "displayName");
	_index = lbAdd[5200,format["%1 (%2)",_vehname,_keyname]];
	VehNearbyList set[count VehNearbyList,[_x,_key]];
} count _nearvehicles;
