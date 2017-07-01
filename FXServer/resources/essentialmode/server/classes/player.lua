-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

-- restart essentialmode

function CreatePlayer(source, permission_level, money, bank, identifier, group)
	local self = {}

	self.source = source
	self.permission_level = permission_level
	self.money = money
	self.bank = bank
	self.identifier = identifier
	self.group = group
	self.coords = {x = 0.0, y = 0.0, z = 0.0}
	self.session = {}

	local rTable = {}

	rTable.setMoney = function(m)
		local prevMoney = self.money
		local newMoney = m

		self.money = m

		if((prevMoney - newMoney) < 0)then
			TriggerClientEvent("es:addedMoney", self.source, math.abs(prevMoney - newMoney), settings.defaultSettings.nativeMoneySystem)
		else
			TriggerClientEvent("es:removedMoney", self.source, math.abs(prevMoney - newMoney), settings.defaultSettings.nativeMoneySystem)
		end

		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.getMoney = function()
		return self.money
	end

	rTable.setBankBalance = function(m)
		TriggerEvent("es:setPlayerData", self.source, "bank", m, function(response, success)
			self.bank = m
		end)
	end

	rTable.getBank = function()
		return self.bank
	end

	rTable.getCoords = function()
		return self.coords
	end

	rTable.setCoords = function(x, y, z)
		self.coords = {x = x, y = y, z = z}
	end

	rTable.kick = function(r)
		DropPlayer(self.source, r)
	end

	rTable.addMoney = function(m)
		local newMoney = self.money + m

		self.money = newMoney

		TriggerClientEvent("es:addedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.removeMoney = function(m)
		local newMoney = self.money - m

		self.money = newMoney

		TriggerClientEvent("es:removedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.addBank = function(m)
		local newBank = self.bank + m
		self.bank = newBank

		TriggerClientEvent("es:addedBank", self.source, m)
	end

	rTable.removeBank = function(m)
		local newBank = self.bank - m
		self.bank = newBank

		TriggerClientEvent("es:removedBank", self.source, m)
	end

	rTable.displayMoney = function(m)
		TriggerClientEvent("es:addedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
	end

	rTable.displayBank = function(m)
		TriggerClientEvent("es:addedBank", self.source, m)
	end

	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	rTable.getPermissions = function()
		return self.permission_level
	end

	rTable.setPermissions = function(p)
		self.permission_level = p
	end

	rTable.getIdentifier = function(i)
		return self.identifier
	end

	rTable.getGroup = function()
		return self.group
	end

	rTable.set = function(k, v)
		self[k] = v
	end

	rTable.get = function(k)
		return self[k]
	end

	return rTable
end