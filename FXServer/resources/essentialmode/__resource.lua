-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

-- Manifest
resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

description 'EssentialMode by Kanersps.'

ui_page 'ui.html'

-- Server
server_scripts { 
	'config.lua',
	'server/util.lua',
	'server/main.lua',
	'server/db.lua',
	'server/classes/player.lua',
	'server/classes/groups.lua',
	'server/player/login.lua'
}

-- Client
client_scripts {
	'client/main.lua'
}

-- NUI Files
files {
	'ui.html',
	'pdown.ttf'
}

server_exports {
	'getPlayerFromId',
	'addAdminCommand',
	'addCommand',
	'addGroupCommand'
}