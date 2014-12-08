VehicleGarage
=============

Virtual Vehicle Storage for Arma 2 Epoch 

Created by 0verHeaT

Installation
=============
##### 0. Basic
Paste the garage folder in your mission file.
Dont forget to add this to your custom compiles.sqf
  
	garage_getnearVeh = compile preprocessFileLineNumbers "Garage\garage_nearvehicles.sqf";
	garage_getstoredVeh = compile preprocessFileLineNumbers "Garage\garage_storedvehicles.sqf";
	garage_manage = compile preprocessFileLineNumbers "Garage\garage_manage.sqf";
	garage_fillplayers = compile preprocessFileLineNumbers "Garage\garage_fillplayers.sqf";
	garage_addfriend = compile preprocessFileLineNumbers "Garage\garage_addfriend.sqf";
	garage_removefriend = compile preprocessFileLineNumbers "Garage\garage_removefriend.sqf";
	garage_spawnVehicle = compile preprocessFileLineNumbers "Garage\garage_spawnvehicle.sqf";
	garage_storeVehicle = compile preprocessFileLineNumbers "Garage\garage_storeVehicle.sqf";
	
I your description.ext
	
	#include "Garage\garage_defines.hpp"
	#inlcude "Garage\garage_dialog.hpp"
	

##### 1. Server Files
Copy and paste the files from the serverfolder to '\z\addons\dayz_server\compile\'
  
server_function.sqf
Add these lines to the compile lines at the top

	server_storevehicle = compile preprocessFileLineNumbers "\z\addons\dayz_server\compile\server_storevehicle.sqf";
	server_spawnvehicle = compile preprocessFileLineNumbers "\z\addons\dayz_server\compile\server_spawnvehicle.sqf";

below add

	"PVDZE_veh_store" addPublicVariableEventHandler {(_this select 1) spawn server_storevehicle};
	"PVDZE_veh_spawn" addPublicVariableEventHandler {(_this select 1) spawn server_spawnvehicle};

  	
server_monitor.sqf
Below

  	_object = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
    	_object setVariable ["lastUpdate",time];
    	_object setVariable ["ObjectID", _idKey, true];
    	
 Add this
 
   	if ((typeOf _object) in DZE_Garage) then {
		_object setVariable ["StoredVehicles",_intentory,true];
		_object setVariable ["GarageFriends",_hitPoints,true];
	};

Now look for 

	  if (count _intentory > 0) then {
	  
replace it with 

    if ((count _intentory > 0) && !((typeOf _object) in DZE_Garage)) then {


##### 2. Mission files
  ***Variables.sqf
  Paste this line at the top
  
   DZE_Garage = ["Land_MBG_Garage_Single_A","Land_MBG_Garage_Single_B","Land_MBG_Garage_Single_C","Land_MBG_Garage_Single_D"];
  
  ***fn_selfActions.sqf
  Add this anywhere below line 225
  
  	private ["_garageowner","_garagefriends","_garageallowed","_friend"];
  	_garageowner = _cursorTarget getVariable ["ownerPUID","0"];
  	_friend = _cursorTarget getVariable ["GarageFriends",[]];
  	_garagefriends = [];
  	{
  		_garagefriends set [count _garagefriends,(_x select 0)];
  	} count _friend;
  	_garageallowed = [_owner] + _garagefriends;
  	if ((_typeOfCursorTarget in DZE_Garage) && (speed player <= 1) && _canDo) then {
  		if (s_player_garage < 0) then {
	  		if ((getPlayerUID player) in _garageallowed) then {
	  			s_player_garage =  player addAction ["<t color='#FFAA00'>Garage Menu</t>", "OcgMods\actions\player_virtualgarage.sqf", _cursorTarget, 2, false];
  			} else {
	  			s_player_garage = player addAction ["<t color='#FF0000'>Garage Locked</t>", "",_cursorTarget, 2, true, true, "", ""];	
	  		};
  		};
  	} else {
	  	player removeAction s_player_garage;
	  	s_player_garage = -1;		
  	};
  
  This has to put to the buttom

  	player removeAction s_player_garage;
  	s_player_garage = -1;
  	
Done.
