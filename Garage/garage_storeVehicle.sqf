/*** Created by 0verHeaT ***/
private ["_index","_veh","_vehicle","_key","_stored","_maxstorage","_vehname"];
_index = _this select 0;
if (_index < 0) exitWith {cutText["\n\nNo Vehicle selected!","PLAIN DOWN"]};

_stored = VirtualGarage getVariable ["StoredVehicles",[]];
_maxstorage = 10; //store limit
if ((count _stored) >= _maxstorage) exitWith {cutText["\n\nThe store limit of your Virtual Garage has been reached!","PLAIN DOWN"]};

_veh = VehNearbyList select _index;
_vehicle = _veh select 0;
_key = _veh select 1;
_vehname = getText(configFile >> "cfgVehicles" >> (typeOf _vehicle) >> "displayName");

if (_key == "") exitWith {cutText["\n\nYou can only store lockable vehicles!","PLAIN DOWN"]};

if(!(_key in weapons player)) exitWith {cutText["\n\nYou have to have the key for the vehicle in your inventory!","PLAIN DOWN"]};

player removeWeapon _key;

PVDZE_veh_store = [player,_vehicle,VirtualGarage];
publicVariableServer "PVDZE_veh_store";

cutText [format["\n\nYou have successfully stored your %1, %2 has been removed from your toolbelt.",_vehname,getText(configFile >> "CfgWeapons" >> _key >> "displayName")],"PLAIN DOWN"];

sleep 2;
call garage_getnearVeh;
call garage_getstoredVeh;
