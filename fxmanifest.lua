fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.2'
author 'Coach=D#1337'
description 'coachHalloween'

shared_scripts {
    'config/config.lua'
}

client_scripts {
    'extra/notify.lua',
    'client.lua'
}

server_scripts {
    'config/webhook.lua',
    'config/coords.lua',
    'server.lua'
}

ui_pages {
    'ui/index.html'
}

files {
    'ui/index.html',
    'ui/sound/*.ogg'
}

data_file "DLC_ITYP_REQUEST" "jackolantern_ytyp.ytyp"

escrow_ignore {
    "config/**/*",
    "extra/**/*",
    "**/*",
}
