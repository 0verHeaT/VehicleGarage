/* [_object,_type] spawn server_updateObject; */
private ["_object","_type","_objectID","_uid","_lastUpdate","_needUpdate","_object_position","_object_inventory","_object_damage","_isNotOk","_parachuteWest","_firstTime","_object_killed","_object_repair","_isbuildable","_garagelist"];
_object = 	_this select 0;
if(isNull(_object)) exitWith {diag_log format["Skipping Null Object: %1", _object];};
if ((typeOf _object) in DZE_Garage) then {_garagelist = _this select 2;};
_type = _this select 1;
_parachuteWest = ((typeOf _object == "ParachuteWest") || (typeOf _object == "ParachuteC"));
_isbuildable = (typeOf _object) in dayz_allowedObjects;
_isNotOk = false;
_firstTime = false;
_objectID = _object getVariable ["ObjectID","0"];
_uid = _object getVariable ["ObjectUID","0"];

if ((typeName _objectID != "string") || (typeName _uid != "string")) then { 
    diag_log(format["Non-string Object: ID %1 UID %2", _objectID, _uid]);
    _objectID = "0";
    _uid = "0";
};
if (!_parachuteWest && !(locked _object)) then {
	if (_objectID == "0" && _uid == "0") then {
		_object_position = getPosATL _object;
    	_isNotOk = true;
	};
};

if (_isNotOk && _isbuildable) exitWith {};
if (_isNotOk) exitWith { deleteVehicle _object; diag_log(format["Deleting object %1 with invalid ID at pos [%2,%3,%4]",typeOf _object,_object_position select 0,_object_position select 1, _object_position select 2]); };

_lastUpdate = _object getVariable ["lastUpdate",time];
_needUpdate = _object in needUpdate_objects;

_object_position = {
	private["_position","_worldspace","_fuel","_key","_colour","_colour2"];
	_position = getPosATL _object;
	if (_object isKindOf "AllVehicles") then {
		_colour = _object getVariable ["Colour","0"];
		_colour2 = _object getVariable ["Colour2","0"];
		_worldspace = [
			round(direction _object),
			_position,
			_colour,
			_colour2
		];
		_fuel = fuel _object;
	} else {
		_worldspace = [
			round(direction _object),
			_position
		];
		_fuel = 0;
	};
	_key = format["CHILD:305:%1:%2:%3:",_objectID,_worldspace,_fuel];
	//diag_log ("HIVE: WRITE: "+ str(_key));
	_key call server_hiveWrite;
};

_object_inventory = {
	private["_inventory","_previous","_key"];
		if ((typeOf _object) in DZE_Garage) then {
			if (isNil "_garagelist") then {
				_garagelist = _object getVariable ["StoredVehicles",[]];
			};
			if (_objectID == "0") then {
				_key = format["CHILD:309:%1:%2:",_uid,_garagelist];
			} else {
				_key = format["CHILD:303:%1:%2:",_objectID,_garagelist];
			};
			_key call server_hiveWrite;
		} else {
			_inventory = [
				getWeaponCargo _object,
				getMagazineCargo _object,
				getBackpackCargo _object
			];
			_previous = str(_object getVariable["lastInventory",[]]);
			if (str(_inventory) != _previous) then {
				_object setVariable["lastInventory",_inventory];
				if (_objectID == "0") then {
					_key = format["CHILD:309:%1:%2:",_uid,_inventory];
				} else {
					_key = format["CHILD:303:%1:%2:",_objectID,_inventory];
				};
				//diag_log ("HIVE: WRITE: "+ str(_key));
				_key call server_hiveWrite;
			};
		};
};

_object_damage = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage"];
		if ((typeOf _object) in DZE_Garage) then {
			_damage = damage _object;
			_array = _object getVariable ["GarageFriends",[]];
		} else {
			_hitpoints = _object call vehicle_getHitpoints;
			_damage = damage _object;
			_array = [];
			{
				_hit = [_object,_x] call object_getHit;
				_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
				if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
				_object setHit ["_selection", _hit];
			} count _hitpoints;
		};
	
		_key = format["CHILD:306:%1:%2:%3:",_objectID,_array,_damage];
		//diag_log ("HIVE: WRITE: "+ str(_key));
		_key call server_hiveWrite;
	_object setVariable ["needUpdate",false,true];
	};

_object_killed = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage"];
	_hitpoints = _object call vehicle_getHitpoints;
	//_damage = damage _object;
	_damage = 1;
	_array = [];
	{
		_hit = [_object,_x] call object_getHit;
		_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
		if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
		_hit = 1;
		_object setHit ["_selection", _hit];
	} count _hitpoints;
	
	if (_objectID == "0") then {
		_key = format["CHILD:306:%1:%2:%3:",_uid,_array,_damage];
	} else {
		_key = format["CHILD:306:%1:%2:%3:",_objectID,_array,_damage];
	};
	//diag_log ("HIVE: WRITE: "+ str(_key));
	_key call server_hiveWrite;
	_object setVariable ["needUpdate",false,true];
	if ((count _this) > 2) then {
		_killer = _this select 2;
		_charID = _object getVariable ['CharacterID','0'];
		_objID 	= _object getVariable['ObjectID','0'];
		_objUID	= _object getVariable['ObjectUID','0'];
		_worldSpace = getPosATL _object;
		if (getPlayerUID _killer != "") then {
			_name = if (alive _killer) then { name _killer; } else { format["OBJECT %1", _killer]; };
			diag_log format["Vehicle killed: Vehicle %1 (TYPE: %2), CharacterID: %3, ObjectID: %4, ObjectUID: %5, Position: %6, Killer: %7 (UID: %8)", _object, (typeOf _object), _charID, _objID, _objUID, _worldSpace, _name, (getPlayerUID _killer)];
		} else {
			diag_log format["Vehicle killed: Vehicle %1 (TYPE: %2), CharacterID: %3, ObjectID: %4, ObjectUID: %5, Position: %6", _object, (typeOf _object), _charID, _objID, _objUID, _worldSpace];
		};
	};
};

_object_repair = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage"];
	_hitpoints = _object call vehicle_getHitpoints;
	_damage = damage _object;
	_array = [];
	{
		_hit = [_object,_x] call object_getHit;
		_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
		if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
		_object setHit ["_selection", _hit];
	} count _hitpoints;
	
	_key = format["CHILD:306:%1:%2:%3:",_objectID,_array,_damage];
	//diag_log ("HIVE: WRITE: "+ str(_key));
	_key call server_hiveWrite;
	_object setVariable ["needUpdate",false,true];
};

_object setVariable ["lastUpdate",time,true];
switch (_type) do {
	case "all": {
		call _object_position;
		call _object_inventory;
		call _object_damage;
		};
	case "position": {
		if (!(_object in needUpdate_objects)) then {
			//diag_log format["DEBUG Position: Added to NeedUpdate=%1",_object];
			needUpdate_objects set [count needUpdate_objects, _object];
		};
	};
	case "gear": {
		call _object_inventory;
			};
	case "damage": {
		if ( (time - _lastUpdate) > 5) then {
			call _object_damage;
		} else {
			if (!(_object in needUpdate_objects)) then {
				//diag_log format["DEBUG Damage: Added to NeedUpdate=%1",_object];
				needUpdate_objects set [count needUpdate_objects, _object];
			};
		};
	};
	case "killed": {
		call _object_killed;
	};
	case "repair": {
		call _object_damage;
	};
};
