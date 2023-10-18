fx_version 'cerulean'

game 'gta5'

name 'M O N O   G A R A G E    V 2'

lua54 'yes'

version '1.9.1'

author '- M O N O, Symbiote_'


shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
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
    'ui/*.html',
    'ui/css/*.css',
    'ui/lang.json',
    'ui/js/*.js',
    'locales/*.json',
}

ui_page {
    'ui/index.html',
}
