fx_version 'cerulean'

game 'gta5'

name 'mono_garage'

lua54 'yes'

repository 'https://github.com/Mono-94/mono_garage'

version '1.2.2'

author 'Discord ID & Link & tebex : symbiote_  ,  https://discord.gg/Vk7eY8xYV2 , https://mono-scripts.tebex.io/'


shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
  --  '@mono_lib/extras.lua',  
    'Config/*.lua',
}


client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'locales/*.json',
--    'AllVehicleEntitys.json'
}
