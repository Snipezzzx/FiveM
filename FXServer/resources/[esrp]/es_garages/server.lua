local vehicles = {
    blista = 4200,
    brioso = 15500,
    dilettante = 2500,
	issi2 = 2500,
	panto = 8500,
	prairie = 3000,
	rhapsody = 14000,
	cogcabrio = 18500,
	exemplar = 20500,
	f620 = 8000,
	felon = 9000,
	felon2 = 9500,
	jackal = 6000,
	oracle = 8000,
	oracle2 = 8200,
	sentinel = 9500,
	sentinel2 = 10000,
	windsor = 84500,
	windsor2 = 88000,
	zion = 6000,
	zion2 = 6500,
	ninef = 12000,
	ninef2 = 13000,
	alpha = 15000,
	banshee = 12600,
	bestiagts = 61000,
	blista = 4200,
	buffalo = 3500,
	buffalo2 = 9600,
	carbonizzare = 19500,
	comet2 = 10000,
	conquette = 13800,
	tampa2 = 90000,
	feltzer2 = 13000,
	furoregt = 44800,
	fusilade = 3600,
	jester = 24000,
	jester2 = 35000,
	kuruma = 12600,
	lynx = 173500,
	massascro = 27500,
	massacro2 = 38500,
	omnis = 70100,
	penumbra = 2400,
	rapidgt = 14000,
	rapidgt2 = 15000,
	schafter3 = 14000,
	sultan = 1200,
	surano = 11000,
	tropos = 81600,
	verlierer2 = 69500,
	casco = 68000,
	coquette2 = 66500,
	jb700 = 35000,
	pigalle = 40000,
	stinger = 85000,
	stingergt = 87500,
	feltzer3 = 97500,
	ztype = 95000,
	adder = 100000,
	banshee2 = 56500,
	bullet = 15500,
	cheetah = 65000,
	entityxf = 79500,
	sheava = 19950,
	fmj = 175000,
	infernus = 44000,
	osiris = 195000,
	le7b = 247500,
	reaper = 159500,
	sultanrs = 79500,
	t20 = 220000,
	turismor = 50000,
	tyrus = 255000,
	vacca = 24000,
	voltic = 15000,
	prototipo = 270000,
	zentorno = 72500,
	blade = 16000,
	buccaneer = 2900,
	chino = 22500,
	coquette3 = 69500,
	dominator = 3500,
	dukes = 6200,
	guantlet = 3200,
	hotknife = 9000,
	faction = 3600,
	nightshade = 58500,
	picador = 900,
	sabregt = 1500,
	tampa = 37500,
	virgo = 19500,
	vigero = 2100,
	bifta = 7500,
	blazer = 800,
	brawler = 71500,
	dubsta3 = 24900,
	dune = 2000,
	rebel2 = 2200,
	sandking = 3800,
	monster = 55000,
	trophytruck = 55000,
	baller = 9000,
	cavalcade = 6000,
	granger = 3500,
	huntley = 19500,
	landstalker = 5800,
	radi = 3200,
	rocoto = 8500,
	seminole = 3000,
	xls = 25300,
	bison = 3000,
	bobcatxl = 2300,
	gburrito = 6500,
	journey = 1500,
	minivan = 3000,
	paradise = 2500,
	rumpo = 1300,
	surfer = 1100,
	youga = 1600,
	asea = 1200,
	fugitive = 2400,
	gledale = 2000,
	ingot = 900,
	intruder = 1600,
	premier = 2000,
	primo = 900,
	primo2 = 950,
	regine = 800,
	schafter2 = 6500,
	stanier = 1000,
	stratum = 1000,
	stretch = 3000,
	superd = 25000,
	surge = 3800,
	tailgater = 5500,
	warrener = 12000,
	washington = 1500,
	scorcher = 10,
	tribike = 10,
	tribike2 = 10,
	tribike3 = 10,
	fixter = 10,
	cruiser = 10,
	bmx = 10,
}

local owned = {}

RegisterNetEvent('es_garages:deductVehicleFix')
AddEventHandler('es_garages:deductVehicleFix', function()
	TriggerEvent('es:getPlayerFromId', source, function(user)
		if user.getMoney() >= 50 then
			user.removeMoney(50)
			TriggerClientEvent('es_garages:fixCurrentVehicle', source)
			TriggerClientEvent('es_rp:notify', source, "We have fixed your vehicle", "CHAR_CARSITE", "Legendary Motorsports", "Repair Complete")
		else
			TriggerClientEvent('es_rp:notify', source, "You do not seem to have enough cash on hand to fix your vehicle", "CHAR_CARSITE", "Legendary Motorsports", "Insufficient Cash")
		end
	end)
end)

AddEventHandler('onResourceStart', function(res)
	if(res == "es_garages")then
		SetTimeout(2000, function()
			TriggerEvent('es:exposeDBFunctions', function(db)
				TriggerEvent('es:getPlayers', function(players)
					for i in pairs(players)do
						local user = players[i]
						db.getDocumentByRow('es_garages', 'identifier', user.get('identifier'), function(dbuser)
							owned[i] = dbuser.vehicles
							TriggerClientEvent('es_garages:owned', i, owned[i])
						end)
					end
				end)
			end)
		end)
	end
end)

AddEventHandler('es:playerLoaded', function(source, user)
	TriggerEvent('es:exposeDBFunctions', function(db)
		db.getDocumentByRow('es_garages', 'identifier', user.get('identifier'), function(dbuser)
			if(dbuser)then
				owned[source] = dbuser.vehicles
			else
				owned[source] = {}
			end

			TriggerClientEvent('es_garages:owned', source, owned[source])
		end)
	end)
end)

RegisterServerEvent('es_garages:selectVehicle')
AddEventHandler('es_garages:selectVehicle', function(veh)
	if(vehicles[veh])then
		TriggerEvent('es:getPlayerFromId', source, function(user)
			local ownedV = false

			for e,v in ipairs(owned[source])do
				if(v == veh)then
					ownedV = true
				end
			end

			if not ownedV then
				if(user.getBank() >= vehicles[veh])then
					TriggerClientEvent('es_garages:newOwned', source, veh)
					owned[source][#owned[source] + 1] = veh
					TriggerClientEvent('es_rp:notify', source, "You have transferred funds to ~g~Legendary Motorsports\n\n~w~Amount: ~g~$" .. vehicles[veh], "CHAR_BANK_FLEECA", "Fleeca Bank", "Transaction log")
					TriggerClientEvent('es_rp:notify', source, "Vehicle bought, press again to spawn", "CHAR_CARSITE", "Legendary Motorsports", "Thank you for your purschase")
					user.removeBank(vehicles[veh])

					TriggerEvent('es:exposeDBFunctions', function(db)
						db.getDocumentByRow('es_garages', 'identifier', user.get('identifier'), function(dbuser)
							dbuser.vehicles[#dbuser.vehicles + 1] = veh
							db.updateDocument('es_garages', dbuser._id, {vehicles = dbuser.vehicles}, function()
							end)
						end)
					end)
				else
					TriggerClientEvent('es_rp:notify', source, "You do not seem to have enough funds in your account", "CHAR_CARSITE", "Legendary Motorsports", "Insufficient Funds")
				end
			else
				TriggerClientEvent('es_garages:spawnVehicle', source, veh)
				TriggerClientEvent('es_rp:notify', source, "We've delivered your vehicle", "CHAR_CARSITE", "Legendary Motorsports", "Delivered")
			
				print(source .. " | " .. GetPlayerName(source) .. ": Has spawned a vehicle")
			end
		end)
	end
end)

TriggerEvent('es:exposeDBFunctions', function(db)
	db.createDatabase('es_garages', function()end)
end)

AddEventHandler('es:newPlayerLoaded', function(source, user)
	TriggerEvent('es:exposeDBFunctions', function(db)
		db.createDocument('es_garages', {identifier = user.get('identifier'), vehicles = {}}, function()
			owned[source] = {}
		end)
	end)	
end)