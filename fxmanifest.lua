-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'

author 'meth'
description 'QBCore Standalone Event Blocker Script'
version '1.0.0'

-- QBCore dependency
dependency 'qb-core'

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Ensure oxmysql is installed and included
    'event_blocker.lua'
}

-- Ensure qb-core and oxmysql resources are started before this resource
dependencies {
    'qb-core',
}
