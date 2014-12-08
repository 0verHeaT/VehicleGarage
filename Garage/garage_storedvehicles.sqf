/*** Created by 0verHeaT ***/
private ["_storedvehicles","_maxstorage"];
_storedvehicles = VirtualGarage getVariable ["StoredVehicles",[]];
_maxstorage = 10; //Number of max stored vehicles
((uiNamespace getVariable "GarageDialog") displayCtrl 5203) ctrlSetStructuredText parseText format["<t align='right'>Vehicles Stored (%1/%2)</t>",(count _storedvehicles),_maxstorage];

lbClear 5201;

VehStoredList = [];
{
	private ["_class","_vehname","_index","_clr1","_clr2","_cid","_fuel","_dmg","_inv","_hit","_data","_key","_keyname"];
	_class = _x select 0;
	_cid = _x select 1;
	_clr1 = _x select 2;
	_clr2 = _x select 3;
	_inv = _x select 4;
	_fuel = _x select 5;
	_dmg = _x select 6;
	_hit = _x select 7;
	_cid = parsenumber _cid;
	if (_cid == 0) then {_key = ""};
	if ((_cid > 0) && (_cid <= 2500)) then {_key = format["ItemKeyGreen%1",_cid];};
	if ((_cid > 2500) && (_cid <= 5000)) then {_key = format["ItemKeyRed%1",_cid-2500];};
	if ((_cid > 5000) && (_cid <= 7500)) then {_key = format["ItemKeyBlue%1",_cid-5000];};
	if ((_cid > 7500) && (_cid <= 10000)) then {_key = format["ItemKeyYellow%1",_cid-7500];};
	if ((_cid > 10000) && (_cid <= 12500)) then {_key = format["ItemKeyBlack%1",_cid-10000];};
	_vehname = getText(configFile >> "cfgVehicles" >> _class >> "displayName");
	_keyname = getText(configFile >> "CfgWeapons" >> _key >> "displayName");
	_index = lbAdd[5201,format["%1 (%2)",_vehname,_keyname]];
	_data = [[_class,_cid,_clr1,_clr2,_inv,_fuel,_dmg,_hit],_key];
	VehStoredList set[count VehStoredList,_data];
} count _storedvehicles;
