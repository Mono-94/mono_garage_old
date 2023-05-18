
  #
  <sub> <center> Discord https://discord.gg/Vk7eY8xYV2 </center></sub>
  
# <center>**MONO_GARAGE**</center>
<center><img src="https://cdn.discordapp.com/attachments/1106742575081201764/1106742575337058384/lWcTATb.png"></center>


#
# <center>**Documents**</center>
# 
* Garage - https://mono-2.gitbook.io/docs/mono-scrips/mono_garage
* CarKeys - https://mono-2.gitbook.io/docs/mono-scrips/mono_carkeys


#
#
# <center>**Features**</center>
* Work with radial menu from ox_lib or ox_target
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
#  <center>**Commands**</center>

* **/impound** - */impound - With this command, you can impound a vehicle. An NPC will appear and take the nearest vehicle to you. It only works for jobs, and you can add as many jobs as you want in Garage.NpcImpound.*
* **/givecar** - *The vehicle you are in will be saved in the database and become your property. (ADMIN)*

# 
#


# <center> **Preview**</center>
# **Preview**

- https://streamable.com/22ksd7 -- Share vehicle
- https://streamable.com/f9ekle -- Command /impound
- https://streamable.com/o0hmej -- Command /givecar
- https://streamable.com/jnj6y6 -- Boat Type
- https://streamable.com/8xea51 -- Air Type 
- https://streamable.com/bc4wug -- Mix
- https://streamable.com/4mjkzz -- Ox_target
#
#





# <center> **Events y exports**</center>

* To obtain a key for a nearby vehicle with a ProgressBar:
```LUA
exports['mono_garage']:CarKey(time) -- Waiting time of the ProgressBar
-- exports['mono_garage']:CarKey(1000)           1000 = 1s
```
* To generate a key with a wait time for the player to enter the vehicle and obtain its license plate:
```LUA
exports['mono_garage']:CarKeyBuy(time) --The time can be adjusted as needed and allows waiting for the player who is inside the vehicle.

-- exports['mono_garage']:CarKeyBuy(1000)           1000 = 1s
```
* Create Key event:
```LUA
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsUsing(ped)
local model = GetEntityModel(vehicle)
local name = GetDisplayNameFromVehicleModel(model)
local plate = GetVehicleNumberPlateText(vehicle)
TriggerServerEvent('mono_carkeys:CreateKey', plate, name)  
```
* To delete the key of a player in their current vehicle (useful for when a player returns a work vehicle):
```LUA
TriggerEvent('mono_carkeys:DeleteClientKey', count)
```
* To delete specific keys:
```LUA
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsUsing(ped)
local model = GetEntityModel(vehicle)
local name = GetDisplayNameFromVehicleModel(model)
local plate = GetVehicleNumberPlateText(vehicle)
TriggerServerEvent('mono_carkeys:DeleteKey', count, plate, name)  
```
* LockPick:
```LUA
exports['mono_garage']:LockPick()
```
* HotWire:
```LUA
exports['mono_garage']:HotWire()
```
* Change Plate:
```LUA
exports['mono_garage']:SetMatricula()
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
		export = 'mono_garage:LockPick'
	}
},

['alicates'] = {
	label = 'Wire Cutters',
	weight = 50,
	stack = true,
	client = {
		export = 'mono_garage:HotWire'
	}
},
['plate'] = {
	label = 'Plate',
	weight = 500,
	stack = true,
	client = {
		export = 'mono_garage:SetMatricula'
	}
},

 ```
# <center> **Dependencies**</center>
 - ox_lib  -  https://github.com/overextended/ox_lib/releases  
 - ox_inventory  -  https://github.com/overextended/ox_inventory/releases  
 - ox_target  -  https://github.com/overextended/ox_target/releases  



