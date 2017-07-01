local garages = {
    { ['x'] = 255.97665405273, ['y'] = -776.36376953125, ['z'] = 30.635633468628 },
    { ['x'] = 1840.4936523438, ['y'] = 2496.2255859375, ['z'] = 45.772537231445 },
    { ['x'] = 147.20378112793, ['y'] = 6626.8291015625, ['z'] = 31.716638565063 },
}


local inGarage = false
local currentMenu = "menu"
local selected = 0
local owned = {}

function DisplayHelpText(str)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentScaleform(str)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function drawText(top, left, size, str, color, font, center)
	SetTextFont(font or 0)
	SetTextScale(1, size)
	SetTextColour(color[1], color[2], color[3], color[4])
	if center then SetTextCentre(true) end
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(tostring(str))
	EndTextCommandDisplayText(left, top)
end

RegisterNetEvent('es_garages:notify')
AddEventHandler('es_garages:notify', function(str)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(str)
	DrawNotification(false, false)
end)

RegisterNetEvent('es_garages:owned')
AddEventHandler('es_garages:owned', function(tab)
	SendNUIMessage({
        type = 'owned',
        vehicles = json.encode(tab)
    })
end)

RegisterNetEvent('es_garages:spawnVehicle')
AddEventHandler('es_garages:spawnVehicle', function(carid)
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		FreezeEntityPosition(GetPlayerPed(-1), false)

		Citizen.Trace(carid .. " <- Spawn\n")
		RequestModel(GetHashKey(carid))
		while not HasModelLoaded(GetHashKey(carid)) do
			Citizen.Wait(0)
		end
		local playerCoords = GetEntityCoords(playerPed, false)

        SetNuiFocus(false)

        SendNUIMessage({
            type = 'garageSwitch',
            enable = false
        })

        inGarage = false

		local veh = CreateVehicle(GetHashKey(carid), playerCoords.x, playerCoords.y, playerCoords.z - 1.0, 0.0, true, false)
		TaskWarpPedIntoVehicle(playerPed, veh, -1)
		SetVehicleDirtLevel(veh, 0)
		SetVehicleEngineOn(veh, true, true)

		return
	end)
end)

RegisterNetEvent('es_garages:newOwned')
AddEventHandler('es_garages:newOwned', function(veh)
	owned[veh] = true

    SendNUIMessage({
        type = 'own',
        vehicle = veh
    })
end)

Citizen.CreateThread(function()
	for k,v in ipairs(garages)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, 357)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName("Garage")
		EndTextCommandSetBlipName(blip)
	end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false)

    SendNUIMessage({
        type = 'garageSwitch',
        enable = false
    })

    inGarage = false
end)

local canSelect = true

RegisterNUICallback('select', function(data, cb)
    if canSelect then
        if(data.owned)then
            canSelect = false
            Citizen.CreateThread(function()
                Wait(300000)
                canSelect = true
            end)
        end
        TriggerServerEvent('es_garages:selectVehicle', data.vehicle)
    else
        if data.owned then
            TriggerEvent('es_rp:notify', "You can retrieve a vehicle every 5 minutes", "CHAR_CARSITE", "Legendary Motorsports", "Unable to retrieve")
        else
            TriggerServerEvent('es_garages:selectVehicle', data.vehicle)
        end
    end
end)

RegisterNetEvent('es_garages:fixCurrentVehicle')
AddEventHandler('es_garages:fixCurrentVehicle', function()
    SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end)

Citizen.CreateThread(function()
	while true do
		local p = GetEntityCoords(GetPlayerPed(-1), true)
		for i in ipairs(garages) do
			local garage = garages[i]
			DrawMarker(1, garage.x, garage.y, garage.z - 1, 0, 0, 0, 0, 0, 0, 3.4001, 3.4001, 0.8001, 0, 75, 255, 165, 0,0, 0,0)
		
			if (Vdist(garage.x, garage.y, garage.z, p.x, p.y, p.z) < 2.4) then

				if not inGarage then
					if(IsPedInAnyVehicle(GetPlayerPed(-1), false))then
                        if IsVehicleDamaged(GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                            DisplayHelpText("Press ~INPUT_CONTEXT~ to fix your vehicle for ~g~$50")
                            if IsControlJustPressed(1, 51) then
                                TriggerServerEvent('es_garages:deductVehicleFix')
                            end
                        else
    						DisplayHelpText("Please leave your vehicle first.")
                        end
					else
						DisplayHelpText("Press ~INPUT_CONTEXT~ to access the garage")

						if IsControlJustPressed(1, 51) then
							SendNUIMessage({
                                type = 'garageSwitch',
                                enable = true
                            })
                            SetNuiFocus(true, true)

                            inGarage = true
						end
					end
                else
                    DisableAllControlActions(1)

                    if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                        SendNUIMessage({
                            type = "click"
                        })
                    end
				end
			end
		end

		Citizen.Wait(0)
	end
end)