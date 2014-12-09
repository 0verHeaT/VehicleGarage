private ["_player","_vehicledata","_arrow","_key","_garage","_class","_cid","_colour1","_inventory","_fuel","_damage","_hitpoints","_location","_dir","_worldspace","_uid","_vehiclelist","_newlist"];
_player = _this select 0;
_vehicledata = _this select 1;
_arrow = _this select 2;
_garage = _this select 3;

_class = _vehicledata select 0;
_cid = str(_vehicledata select 1);
_colour1 = _vehicledata select 2;
_colour2 = _vehicledata select 3;
_inventory = _vehicledata select 4;
_fuel = _vehicledata select 5;
_damage = _vehicledata select 6;
_hitpoints = _vehicledata select 7;

_location = getPosATL _arrow;
_dir = getDir _garage;
_worldspace = [_dir,_location];

_uid = _worldspace call dayz_objectUID3;
_key = format["CHILD:308:%1:%2:%3:%4:%5:%6:%7:%8:%9:",dayZ_instance, _class, 0 , _cid, _worldspace, [], [], 1,_uid];
diag_log ("HIVE: WRITE: "+ str(_key)); 
_key call server_hiveWrite;

[_arrow,_uid,_cid,_class,_dir,_location,_player,_colour1,_colour2,_inventory,_fuel,_damage,_hitpoints] spawn {
	private ["_object","_uid","_characterID","_done","_retry","_key","_result","_outcome","_oid","_class","_location","_object_para","_activatingPlayer","_colour1","_colour2","_inventory","_fuel","_damage","_hitpoints","_clrinit","_clrinit2","_objWpnTypes","_objWpnQty","_countr"];
	_object = _this select 0;
	_uid = _this select 1;
	_characterID = _this select 2;
	_class = _this select 3;
	_dir = _this select 4;
	_location = _this select 5;
	_activatingPlayer = _this select 6;
	_colour1 = _this select 7;
	_colour2 = _this select 8;
	_inventory = _this select 9;
	_fuel = _this select 10;
	_damage = _this select 11;
	_hitpoints = _this select 12;

   _done = false;
	_retry = 0;
	while {_retry < 10} do {
		sleep 1;
		_key = format["CHILD:388:%1:",_uid];
		diag_log ("HIVE: WRITE: "+ str(_key));
		_result = _key call server_hiveReadWrite;
		_outcome = _result select 0;
		if (_outcome == "PASS") then {
			_oid = _result select 1;
			diag_log("CUSTOM: Selected " + str(_oid));
			_done = true;
			_retry = 100;
		} else {
			diag_log("CUSTOM: trying again to get id for: " + str(_uid));
			_done = false;
			_retry = _retry + 1;
		};
	};
	deleteVehicle _object;

	if(!_done) exitWith { diag_log("CUSTOM: failed to get id for : " + str(_uid)); };

	_object = createVehicle [_class, _location, [], 0, "CAN_COLLIDE"];
	_object setDir _dir;
	_object setvehiclelock "locked";

	clearWeaponCargoGlobal  _object;
	clearMagazineCargoGlobal  _object;

	_object setVariable ["ObjectID", _oid, true];
	_object setVariable ["lastUpdate",time];
	_object setVariable ["CharacterID",_characterID, true];
	
	if (_colour1 != "0") then {
		_object setVariable ["Colour",_colour1,true];
		_clrinit = format ["#(argb,8,8,3)color(%1)",_colour1];
		_object setVehicleInit "this setObjectTexture [0,"+str _clrinit+"];";
	};
	if (_colour2 != "0") then {			
		_object setVariable ["Colour2",_colour2,true];
		_clrinit2 = format ["#(argb,8,8,3)color(%1)",_colour2];
		_object setVehicleInit "this setObjectTexture [1,"+str _clrinit2+"];";
	};

	_objWpnTypes = (_inventory select 0) select 0;
	_objWpnQty = (_inventory select 0) select 1;
	_countr = 0;					
	{
		if(_x in (DZE_REPLACE_WEAPONS select 0)) then {
			_x = (DZE_REPLACE_WEAPONS select 1) select ((DZE_REPLACE_WEAPONS select 0) find _x);
		};
		_object addWeaponCargoGlobal [_x,(_objWpnQty select _countr)];
		_countr = _countr + 1;
	} count _objWpnTypes; 

	_objWpnTypes = (_inventory select 1) select 0;
	_objWpnQty = (_inventory select 1) select 1;
	_countr = 0;
	{
		if (_x == "BoltSteel") then { _x = "WoodenArrow" };
		if (_x == "ItemTent") then { _x = "ItemTentOld" };
		_object addMagazineCargoGlobal [_x,(_objWpnQty select _countr)];
		_countr = _countr + 1;
	} count _objWpnTypes;

	_objWpnTypes = (_inventory select 2) select 0;
	_objWpnQty = (_inventory select 2) select 1;
	_countr = 0;
	{
		_object addBackpackCargoGlobal [_x,(_objWpnQty select _countr)];
		_countr = _countr + 1;
	} count _objWpnTypes;

	_object setFuel _fuel;
	_object setDamage _damage;

	{
		private ["_selection","_dam"];
		_selection = _x select 0;
		_dam = _x select 1;
		if (_selection in dayZ_explosiveParts && _dam > 0.8) then {_dam = 0.8};
		[_object,_selection,_dam] call object_setFixServer;
	} forEach _hitpoints;

	PVDZE_serverObjectMonitor set [count PVDZE_serverObjectMonitor,_object];
	_object call fnc_veh_ResetEH;
	PVDZE_veh_Init = _object;
	publicVariable "PVDZE_veh_Init";
};

_vehiclelist = _garage getVariable ["StoredVehicles",[]];

_newlist = [];
{
	private ["_data","_toremove"];
	_toremove = false;
	if ((_x select 1) == _cid) then { _toremove = true; };
	if (!_toremove) then {
		_data = [(_x select 0),(_x select 1),(_x select 2),(_x select 3),(_x select 4),(_x select 5),(_x select 6),(_x select 7)];
		_newlist set [count _newlist,_data];
	};
} count _vehiclelist;

_garage setVariable ["StoredVehicles",_newlist,true];

diag_log format["VIRTUAL GARAGE: Player %1 (%2) has spawned a %3 | "+str _newlist+"",(name _player),(getPlayerUID _player),_class];

[_garage,"gear",_newlist] spawn server_updateObject;
