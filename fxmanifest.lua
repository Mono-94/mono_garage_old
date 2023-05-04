fx_version 'cerulean'

game 'gta5' 

name 'Sy_Garage'

repository 	'https://github.com/Mono-94/sy_garage '

version 		'1.0.3'

author 'Symbiote#3027 - Discord https://discord.gg/Vk7eY8xYV2'


shared_scripts{
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config_garage.lua',
    'config_keys.lua',
    'functions.lua'
    
} 


client_scripts{
    'client/*.lua',
   
} 

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
} 


files {
    'locales/*.json'
}

lua54 'yes'
