fx_version 'cerulean'
game 'gta5'

author 'SicilianoPazzo'
description 'Equipaggiamento Polizia'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'es_extended',
    'ox_target'
}
