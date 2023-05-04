
  #
  <sub> <center> Discord https://discord.gg/Vk7eY8xYV2 </center></sub>
  
# <center>**SY_GARAGE**</center>
<center><img src="https://cdn.discordapp.com/attachments/1090270623059685428/1090270623235854336/image.png"></center>

#
#
# <center>**Features**</center>
* Work with radial menu from ox_lib or ox_target
* The vehicles persist when a player disconnects, when the vehicle reconnects it will continue in the same place.
* Share vehicles with colleagues, including a list to manage shared access to the vehicle.
* Garage for independent work.
* Generate a key when removing the vehicle from the garage and delete it when returning to the garage.
* 3 types of garages: "air", "car", and "boat".
* Vehicle impound system and recovery points.
* Vehicle mileage is stored in the database and can be viewed in the garage.
* Garage.RadialCopyCoords: Radial menu to copy coordinates and easily create garages. (Only use this on your development server!)
* Command to add a vehicle to the database as the owner. 
* Allows vehicles that are outside the garage and the entity is not present in the world to be sent directly to the impound.
* 

# <center> **Preview**</center>
# **Preview**

- https://streamable.com/22ksd7 -- Share vehicle
- https://streamable.com/f9ekle -- Command /impound
- https://streamable.com/o0hmej -- Command /givecar
- https://streamable.com/jnj6y6 -- Boat Type
- https://streamable.com/8xea51 -- Air Type 
- https://streamable.com/bc4wug -- Mix
- https://streamable.com/2v6bfl -- Persistent vehicles.
- https://streamable.com/4mjkzz -- Ox_target
#
#
#  <center>**Commands**</center>

* **/impound** - */impound - With this command, you can impound a vehicle. An NPC will appear and take the nearest vehicle to you. It only works for jobs, and you can add as many jobs as you want in Garage.NpcImpound.*
* 
 ----
* **/givecar** - *The vehicle you are in will be saved in the database and become your property. (ADMIN)*
* 
# 
#

# <center> **Examples Garages**</center>

You can add as many garages as you want in config_garage.lua > Garage.Garages.

* Example garage creation:
```LUA
['Garage Name'] = {                -- Garage name, blip, impound...
    impound = false,               -- impound = true or false
    impoundPrice = false,          -- if impound is false, this doesn't work
    type = 'car',                  -- Type 'car', 'air', 'boat'
    impoundIn = 'Impound name',    -- Name of the storage where the vehicle will be sent if it is not in the garage and is not on the street
    job = false,                   -- To assign a job, job = 'police', job = false for all
    pos = vec3(0, 0, 0),           -- Position of the garage zone
    size = vec3(0, 0, 0),          -- Size of the zone
    heading = 0,                   -- Direction of the zone
    spawnpos = {                   -- Spawn Pos, you can add more than one
        { x = 1, y = 1, z = 1, h = 1 },
        { x = 2, y = 2, z = 2, h = 2 },
        { x = 3, y = 3, z = 3, h = 3 },
    },
    debug = false,                 -- Zone debug
    blip = true,                   -- Show/Hide Blip
    sprite = 524,                  -- Blip Sprite
    scale = 0.6,                   -- Blip Size
    colorblip = 0,                 -- Blip Color 
    -- If Garage.Target is true you can edit this, if it is false, ignore it.
    NPCHash      = 'csb_trafficwarden',
    NPCPos       = vec4(0, 0, 0, 0),
}
```
* Example impound creation:
```LUA
['Impound name'] = {               -- Garage name, blip, impound...
    impound = true,                -- impound = true or false
    impoundPrice = 50,             -- if impound is false, this doesn't work
    type = 'car',                  -- Type 'car', 'air', 'boat'
    impoundIn = false,             -- Name of the storage where the vehicle will be sent if it is not in the garage and is not on the street
    job = false,                   -- To assign a job, job = 'police', job = false for all
    pos = vec3(0, 0, 0),           -- Position of the garage zone
    size = vec3(0, 0, 0),          -- Size of the zone
    heading = 0,                   -- Direction of the zone
    spawnpos = {                   -- Spawn Pos, you can add more than one
        { x = 1, y = 1, z = 1, h = 1 },
        { x = 2, y = 2, z = 2, h = 2 },
        { x = 3, y = 3, z = 3, h = 3 },
    },
    debug = false,                 -- Zone debug
    blip = true,                   -- Show/Hide Blip
    sprite = 524,                  -- Blip Sprite
    scale = 0.6,                   -- Blip Size
    colorblip = 0,                 -- Blip Color
    -- If Garage.Target is true you can edit this, if it is false, ignore it.
    NPCHash      = 'csb_trafficwarden',
    NPCPos       = vec4(0, 0, 0, 0),
}
```
* Example garage-job creation:
```LUA
['LSPD Garage'] = {                -- Garage name, blip, impound...
    impound = false,               -- impound = true or false
    impoundPrice = 50,             -- if impound is false, this doesn't work
    type = 'car',                  -- Type 'car', 'air', 'boat'
    impoundIn = false,             -- Name of the storage where the vehicle will be sent if it is not in the garage and is not on the street
    job = 'police',                -- To assign a job, job = 'police', job = false for all
    pos = vec3(0, 0, 0),           -- Position of the garage zone
    size = vec3(0, 0, 0),          -- Size of the zone
    heading = 0,                   -- Direction of the zone
    spawnpos = {                   -- Spawn Pos, you can add more than one
        { x = 1, y = 1, z = 1, h = 1 },
        { x = 2, y = 2, z = 2, h = 2 },
        { x = 3, y = 3, z = 3, h = 3 },
    },
    debug = false,                 -- Zone debug
    blip = true,                   -- Show/Hide Blip
    sprite = 524,                  -- Blip Sprite
    scale = 0.6,                   -- Blip Size
    colorblip = 0,                 -- Blip Color
    -- If Garage.Target is true you can edit this, if it is false, ignore it.
    NPCHash      = 'csb_trafficwarden',
    NPCPos       = vec4(0, 0, 0, 0),
}
```
#



#
# <center> **Events y exports**</center>

* Open the vehicle impound option.
```LUA
TriggerEvent('sy_garage:NPCImpound') 
```
# <center>**END SY_GARAGE**</center>
#


# <center>**SY_CARKEYS**</center>
<center><img src="https://i.imgur.com/45ygmFr.png"></center>

#
#
# <center>**Features**</center>
* Turn on and off the vehicle engine using the corresponding assigned key to the vehicle  (optional, Keys.Engine).
* You can hold down the F key when exiting the vehicle to keep the engine running, if you have the vehicle keys. (Optional, Keys.OnExitCar)
* Retrieve lost keys through an NPC that can be easily added in the Config.lua file.(In the config.lua file, you can edit the NPC to acquire the license plate. Keep in mind that if you set BuyNewPlate to true, the NPC will only sell license plates and not keys)
* Administrators can create keys for the vehicle they are in, as well as for other players using their ID.
* NPC-owned vehicles will be parked with their doors closed, and will be turned off if opened (This option is disabled by default since it is not 100% finished. It will block all kinds of vehicles, including those with NPCs inside. In the future, only vehicles without NPCs will be affected. Keys.CloseDoorsNPC).
* Lockpicking system with skill check, allowing players to force entry into vehicles (includes a function in the Config.lua file to optionally add a dispatch system).
* Includes a tool called "Wire Cutters" with skill check, allowing players to hotwire previously forced vehicles (optional).
* The license plate item allows the player to customize both the color and the license plate of their vehicle. (This will change the license plate in the database)
* Keybind to open/close the vehicle. (Default key is U, can be changed in the Config.lua file.)
* Keybind to turn on/off the engine. (Default key is M, can be changed in the Config.lua file. Optional) 
#
#
#  <center>**Commands Admins**</center>
* **/givekey [ID]** - *With this command, you can obtain a key for the vehicle you are currently in, or you can use the ID of a player who is in a vehicle to give them a key to that vehicle.*

* **/delkey [ID]** - *With this command, you can delete the key for the vehicle you are currently in.*

# 
#


# <center> **Events y exports**</center>

* To obtain a key for a nearby vehicle with a ProgressBar:
```LUA
exports['sy_garage']:CarKey(time) -- Waiting time of the ProgressBar
-- exports['sy_garage']:CarKey(1000)           1000 = 1s
```
* To generate a key with a wait time for the player to enter the vehicle and obtain its license plate:
```LUA
exports['sy_garage']:CarKeyBuy(time) --The time can be adjusted as needed and allows waiting for the player who is inside the vehicle.

-- exports['sy_garage']:CarKeyBuy(1000)           1000 = 1s
```
* Create Key event:
```LUA
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsUsing(ped)
local model = GetEntityModel(vehicle)
local name = GetDisplayNameFromVehicleModel(model)
local plate = GetVehicleNumberPlateText(vehicle)
TriggerServerEvent('sy_carkeys:CreateKey', plate, name)  
```
* To delete the key of a player in their current vehicle (useful for when a player returns a work vehicle):
```LUA
TriggerEvent('sy_carkeys:DeleteClientKey', count)
```
* To delete specific keys:
```LUA
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsUsing(ped)
local model = GetEntityModel(vehicle)
local name = GetDisplayNameFromVehicleModel(model)
local plate = GetVehicleNumberPlateText(vehicle)
TriggerServerEvent('sy_carkeys:DeleteKey', count, plate, name)  
```
* LockPick:
```LUA
exports['sy_garage']:LockPick()
```
* HotWire:
```LUA
exports['sy_garage']:HotWire()
```
* Change Plate:
```LUA
exports['sy_garage']:SetMatricula()
```
#
#
#  <center>**Ox inventory Item's**</center>
```LUA
['carkeys'] = {
	label = 'Car Key',
	weight = 5,
	stack = true
},

['ganzua'] = {
	label = 'Lockpick',
	weight = 25,
	stack = true,
	client = {
		export = 'sy_garage.LockPick'
	}
},

['alicates'] = {
	label = 'Wire Cutters',
	weight = 50,
	stack = true,
	client = {
		export = 'sy_garage.HotWire'
	}
},
['plate'] = {
	label = 'Plate',
	weight = 500,
	stack = true,
	client = {
		export = 'sy_garage.SetMatricula'
	}
},

 ```
# <center> **Dependencies**</center>
 - ox_lib  -  https://github.com/overextended/ox_lib/releases  
 - ox_inventory  -  https://github.com/overextended/ox_inventory/releases  
 - ox_target  -  https://github.com/overextended/ox_target/releases  



