-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

_VERSION = '4.0.2'

-- Server
Users = {}
commands = {}
settings = {}
settings.defaultSettings = {
	['pvpEnabled'] = false,
	['permissionDenied'] = false,
	['debugInformation'] = false,
	['startingCash'] = 0,
	['enableRankDecorators'] = false,
	['moneyIcon'] = "$",
	['nativeMoneySystem'] = true,
	['commandDelimeter'] = '/'
}
settings.sessionSettings = {}

-- Version check
PerformHttpRequest("http://fivem.online/version.txt", function(err, rText, headers)
	print("\nCurrent version: " .. _VERSION)
	print("Updater version: " .. rText .. "\n")
	
	if rText ~= _VERSION then
		print("\nVersion mismatch, you are currently not using the newest stable version of essentialmode. Please update\n")
	else
		print("Everything is fine!\n")
	end
end, "GET", "", {what = 'this'})

AddEventHandler('playerDropped', function()
	if(Users[source])then
		TriggerEvent("es:playerDropped", Users[source])

		db.updateUser(Users[source].get('identifier'), {money = Users[source].getMoney(), Users[source].getBank()}, function()
			Users[source] = nil
		end)
	end
end)

local justJoined = {}

RegisterServerEvent('es:firstJoinProper')
AddEventHandler('es:firstJoinProper', function()
	registerUser(GetPlayerIdentifiers(source)[1], source)
	justJoined[source] = true

	if(settings.defaultSettings.pvpEnabled)then
		TriggerClientEvent("es:enablePvp", source)
	end
end)

AddEventHandler('es:setSessionSetting', function(k, v)
	settings.sessionSettings[k] = v
end)

AddEventHandler('es:getSessionSetting', function(k, cb)
	cb(settings.sessionSettings[k])
end)

RegisterServerEvent('playerSpawn')
AddEventHandler('playerSpawn', function()
	if(justJoined[source])then
		TriggerEvent("es:firstSpawn", source, Users[source])
		justJoined[source] = nil
	end
end)

AddEventHandler("es:setDefaultSettings", function(tbl)
	for k,v in pairs(tbl) do
		if(settings.defaultSettings[k] ~= nil)then
			settings.defaultSettings[k] = v
		end
	end

	debugMsg("Default settings edited.")
end)

AddEventHandler('chatMessage', function(source, n, message)
	if(startswith(message, settings.defaultSettings.commandDelimeter))then
		local command_args = stringsplit(message, " ")

		command_args[1] = string.gsub(command_args[1], settings.defaultSettings.commandDelimeter, "")

		local command = commands[command_args[1]]

		if(command)then
			CancelEvent()
			if(command.perm > 0)then
				if(Users[source].getPermissions() >= command.perm or groups[Users[source].getGroup()]:canTarget(command.group))then
					command.cmd(source, command_args, Users[source])
					TriggerEvent("es:adminCommandRan", source, command_args, Users[source])
				else
					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("es:adminCommandFailed", source, command_args, Users[source])

					if(type(settings.defaultSettings.permissionDenied) == "string" and not WasEventCanceled())then
						TriggerClientEvent('chatMessage', source, "", {0,0,0}, defaultSettings.permissionDenied)
					end

					debugMsg("Non admin (" .. GetPlayerName(source) .. ") attempted to run admin command: " .. command_args[1])
				end
			else
				command.cmd(source, command_args, Users[source])
				TriggerEvent("es:userCommandRan", source, command_args)
			end
			
			TriggerEvent("es:commandRan", source, command_args, Users[source])
		else
			TriggerEvent('es:invalidCommandHandler', source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent('es:chatMessage', source, message, Users[source])
	end
end)

function addCommand(command, callback)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback

	debugMsg("Command added: " .. command)
end

AddEventHandler('es:addCommand', function(command, callback)
	addCommand(command, callback)
end)

function addAdminCommand(command, perm, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end

AddEventHandler('es:addAdminCommand', function(command, perm, callback, callbackfailed)
	addAdminCommand(command, perm, callback, callbackfailed)
end)

function addGroupCommand(command, group, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end

AddEventHandler('es:addGroupCommand', function(command, group, callback, callbackfailed)
	addGroupCommand(command, group, callback, callbackfailed)
end)

RegisterServerEvent('es:updatePositions')
AddEventHandler('es:updatePositions', function(x, y, z)
	if(Users[source])then
		Users[source].setCoords(x, y, z)
	end
end)

-- Info command
commands['info'] = {}
commands['info'].perm = 0
commands['info'].cmd = function(source, args, user)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Version: ^2 " .. _VERSION)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Commands loaded: ^2 " .. (returnIndexesInTable(commands) - 1))
end
