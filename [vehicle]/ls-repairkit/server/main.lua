ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local vehicleList = {}
ESX.RegisterUsableItem('repairbodykit', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
  -- local itemQuantity = xPlayer.getInventoryItem('EngineParts').count
	TriggerClientEvent('esx_repairkit:RepairBody', _source)

end)

ESX.RegisterUsableItem('repairenginkit', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
  -- local itemQuantity = xPlayer.getInventoryItem('EngineParts').count
	TriggerClientEvent('esx_repairkit:RepairEngine', _source)

end)

ESX.RegisterUsableItem('repairtyre', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
  -- local itemQuantity = xPlayer.getInventoryItem('EngineParts').count
	TriggerClientEvent('esx_repairkit:RepairTire', _source)

end)

ESX.RegisterServerCallback('esx_repairkit:checkParts',function (source,cb,parts,num)
  -- num 1 - engine , num 2 - body 
  local xPlayer = ESX.GetPlayerFromId(source)
  local identifier = xPlayer.identifier
  local resultcb = 0
  local itemQuantity = 0
  if num == 1 then
    itemQuantity = xPlayer.getInventoryItem('BodyParts').count
    if itemQuantity >= parts then
      resultcb = 1
      cb(resultcb)
    else
      cb(resultcb)  
    end
  elseif num == 2 then
    itemQuantity = xPlayer.getInventoryItem('BodyParts').count
    if itemQuantity >= parts then
      resultcb = 1
      cb(resultcb)
    else
      cb(resultcb)  
    end
  end

end)

ESX.RegisterServerCallback('esx_repairkit:checkLevel',function (source,cb)
  local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
  local resultcb = 0
  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function (result)
        if result then
          resultcb = result.mechaniclevel
          if resultcb == nil then
          resultcb = 0
          end
          print(resultcb.."resultcb Lv")
          cb(resultcb)
        else 
          cb(resultcb) 
        end
      end)
end)

RegisterNetEvent('esx_repairkit:expup')
AddEventHandler('esx_repairkit:expup',function (soruce)
  local xPlayer = ESX.GetPlayerFromId(source)
  local identifier = xPlayer.identifier
  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function (result)
    --  locals user = result[1]
    local userexp = result.mechanicexp + 1
    local userlevel = result.mechaniclevel 

    for i,val in ipairs(Config.LevelUp) do
      if i == userlevel then
        if userexp >= val.exp then
 -- ?????????
          MySQL.Sync.execute("UPDATE `users` SET `mechaniclevel`=@mechaniclevel WHERE identifier = @identifier", { 
						['@mechaniclevel'] = userlevel + 1,
						['@identifier'] = identifier
						
					})
          MySQL.Sync.execute("UPDATE `users` SET `mechanicexp`=@mechanicexp WHERE identifier = @identifier", { 
						['@mechanicexp'] = 0,
						['@identifier'] = identifier
						
					})
        else
          MySQL.Sync.execute("UPDATE `users` SET `mechanicexp`=@mechanicexp WHERE identifier = @identifier", { 
						['@mechanicexp'] = userexp,
						['@identifier'] = identifier
						
					})
        end
      end
    end
  end)

end)
RegisterNetEvent('esx_repairkit:removeKit')
AddEventHandler('esx_repairkit:removeKit', function(parts,num)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('BodyParts', parts)

end)

RegisterNetEvent('esx_repairkit:removeTyreKit')
AddEventHandler('esx_repairkit:removeTyreKit', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('repairtyre', 1)
    		
end)

RegisterNetEvent('esx_repiarkit:savehicle')
AddEventHandler('esx_repiarkit:savehicle',function(vehplate,engineHealth,bodyHealth,fuel)
--   print(vehplate)
 -- print(engineHealth)
   local _isSerch = 0;
  -- ????????? ????????? ????????? ?????? ?????????????????? ?????? ?????????.
  for key, value in pairs(vehicleList) do
    --?????? ???????????? ?????? ??????????????? ????????? ????????????. ?????? ?????? isSerch??? 1??? ????????????. 
    --???????????? ???????????? 0?????? ????????? ?????????, ?????? ????????? ????????? ?????? ????????????.
    if value[1] == vehplate then
      _isSerch = 1;
      -- ????????? ?????? ???, ????????? ?????? ????????? ?????? ?????? ?????? ?????? ????????????. ????????? ????????? ????????????.
      if value[2] ~= engineHealth or value[3] ~= bodyHealth or value[4] ~= fuel then
        -- table??? ?????? ???????????? ?????? ??? ?????? ????????? ???????????? ????????? ???????????????.
        table.insert(vehicleList,key,{vehplate,engineHealth,bodyHealth,fuel})
        table.remove(vehicleList,key+1)
      end
    end
  end

  if _isSerch == 0 then
    table.insert(vehicleList,{vehplate,engineHealth,bodyHealth})
  end
end)

RegisterServerEvent("esx_repairkit:SetEngineHealthSync")
AddEventHandler("esx_repairkit:SetEngineHealthSync",function (veh)
  TriggerClientEvent("esx_repairkit:EngineSetSync",-1,veh)
end)

RegisterServerEvent("esx_repairkit:SetTyreSync")
AddEventHandler("esx_repairkit:SetTyreSync", function(veh, tyre)
	TriggerClientEvent("TyreSync", -1, veh, tyre)
end)

RegisterServerEvent("esx_repairkit:SetBodyHealthSync")
AddEventHandler("esx_repairkit:SetBodyHealthSync", function (veh)
  TriggerClientEvent("esx_repairkit:BodySetSync",-1,veh)
end)


Citizen.CreateThread(function()
    while true do 
        -- print("Vehicle DataBase SAVING !!")
        -- print("VehicleList : ".. #vehicleList)
        if #vehicleList > 0 then
          for key, value in pairs(vehicleList) do
            -- print(value[2])
            -- print(value[1])
            if value[2] > 0 then
              MySQL.Async.execute("UPDATE owned_vehicles SET enginehealth = @health,bodyhealth = @bodyhealth, fuel = @fuel WHERE plate = @plate ", {
                ['@health'] = value[2],
                ['@bodyhealth'] = value[3],
                ['@fuel'] = value[4],
                ['@plate'] = value[1]
                 },
                  function(result)
                    
                end)
            else
              MySQL.Async.execute("UPDATE owned_vehicles SET enginehealth = @health, state = @state WHERE plate = @plate and state = 1", {
                ['@health'] = value[2],
                ['@state'] = 0,
                ['@plate'] = value[1]
                 },
                  function(result)
                    
                end)
            end
              
          end
          local count = #vehicleList
          for i=0, count do 
            vehicleList[i]=nil 
          end
        end
        Citizen.Wait(5000)
    end

end)