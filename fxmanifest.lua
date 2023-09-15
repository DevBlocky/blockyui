--[[
    SCRIPT INFORMATION BELOW
    PLEASE REFER TO LICENSE BEFORE MODIFICATION
]]
version '0.1.0a'
author 'DevBlocky'
description 'TODO'
repository 'https://github.com/DevBlocky/neo-ui'

-- required fxmanifest stuff
fx_version 'cerulean'
game 'common'

-- setup for nui
file 'dist/**/*'
ui_page 'dist/ui.html'

-- build webpack page automatically when resource is started for the first time
dependencies { 'yarn', 'webpack' }
webpack_config 'webpack.config.js'

server_script 'core/sv.lua'
client_script 'core/main.lua'

-- development shit
-- blockyui_resource 'mui'
-- client_script 'ext/lib*.lua'
-- client_script 'test.lua'
