/*** Created by 0verHeaT ***/
private ["_index","_helipads","_helipadsnear","_nearestpad","_veh","_vehicle","_key","_vehname","_position","_checkkey","_sign"];
_index = _this select 0;
if (_index < 0) exitWith {cutText["\n\nNo Vehicle selected!","PLAIN DOWN"]};

_veh = VehStoredList select _index;
_vehicle = _veh select 0;
_key = _veh select 1;

_vehname = getText(configFile >> "cfgVehicles" >> (_vehicle select 0) >> "displayName");

_helipads = ["HeliH","HeliHCivil","HeliHRescue","MAP_Heli_H_army","MAP_Heli_H_cross"];

_helipadsnear = nearestObjects [(getPosATL player),_helipads,30];
if ((count _helipadsnear) < 1) exitWith {cutText["\n\nYou need a Helipad witin 30 meters to spawn a vehicle!","PLAIN DOWN"]};

_nearestpad = _helipadsnear select 0;
_position = getPosATL _nearestpad;

_checkkey = [player,_key] call BIS_fnc_invAdd;
if (!(_checkkey)) exitWith {cutText [(localize "str_epoch_player_107"),"PLAIN DOWN"]};

_sign = createVehicle ["Sign_arrow_down_large_EP1",_position,[],0,"CAN_COLLIDE"];

PVDZE_veh_spawn = [player,_vehicle,_sign,VirtualGarage];
publicVariableServer "PVDZE_veh_spawn";

cutText [format["\n\nYou have successfully spawned a %1, %2 has been added to your toolbelt.",_vehname,getText(configFile >> "CfgWeapons" >> _key >> "displayName")],"PLAIN DOWN"];

sleep 2;
call garage_getnearVeh;
call garage_getstoredVeh;
