
  #
  <sub> <center> Discord https://discord.gg/Vk7eY8xYV2 </center></sub>
  
# <center>**MONO_GARAGE**</center>
<center><img src="https://i.imgur.com/vE7000q.png"></center>



# <center>**Features**</center>
* Work with radial menu from ox_lib or ox_target 
* Share vehicles with colleagues, including a list to manage shared access to the vehicle.
* Garage for independent work.
* Generate a key when removing the vehicle from the garage and delete it when returning to the garage.
* 4 types of garages: "all","air","car", and "boat".
* Vehicle impound system and recovery points.
* Vehicle mileage is stored in the database and can be viewed in the garage.
* Garage.RadialCopyCoords: Radial menu to copy coordinates and easily create garages. (Only use this on your development server!)
* Command to add a vehicle to the database as the owner. 
* Allows vehicles that are outside the garage and the entity is not present in the world to be sent directly to the impound.
*  **(New)** Compatible with the Quasar inventory...
*  **(New)** Garages for jobs with configurable vehicles by ranks.
*  **(New)** Now you can use PolyZone only for garages, not impounds. 
*  **(New)** One name for the blips. Config/config_garage.lua - Garage.BlipsName
*  **(New)** TextUI added, you can customize it in client/functions.lua. (default ox_textui)
*  **(New)** 2 Commands to test the EXPORTS and see how it works in client/Default.lua (Default disabled)
*  **(New)** Command /spawncar [ID] [MODEL] [TIME (1 = 1 min)] generates a vehicle with a time of use. ( /spawncar 1 sultan 10  )
*  **(New)**  Sell or Transfer the ownership of a vehicle to another player  + WebHook to record transfers in server/functions_s.lua .
*  **(New)** Compatible with ox_fuel  / LegacyFuel / esx-sna-fuel  
*  **(New)** ProgressBar when closing/opening vehicles  Config/config_carkeys.lua - Keys.Progress 
*  **(New)** Delay between closing/opening vehicles to avoid massive spawns of notifications or progress bar.
*  **(New)** Now you can add a price for transferring vehicles between garages, each garage has its price, if no price is assigned in the configuration of a garage, the transfer between garages will be free. (All current garages of type = 'car' have a price of $20).
*  **(New)** EXTRAS Menu with custom job vehicles, (Target)

#  <center>**Commands**</center>

* **/impound** For Jobs.

* **/givecar** [ID] [MODEL] [GARAGE (Optional)] now spawns the vehicle and adds it to the player's database.

* **/spawncar** [ID] [MODEL] [TIME (1 = 1 min)] generates a vehicle with a time of use. ( /spawncar 1 sultan 10  )

#


# <center> **Dependencies**</center>
 - ox_lib  -  https://github.com/overextended/ox_lib/releases  
 - ox_inventory  -  https://github.com/overextended/ox_inventory/releases  
 - ox_target  -  https://github.com/overextended/ox_target/releases  

#
# <center>**Documents**</center>
# 
* Garage - https://mono-2.gitbook.io/docs/mono-scrips/mono_garage


