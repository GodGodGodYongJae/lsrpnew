ESX          = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Citizen.CreateThread(function()
-- 	while true do
--         Wait(0)
--         SetParkedVehicleDensityMultiplierThisFrame(0.1)
--         SetVehicleDensityMultiplierThisFrame(0.3)
--         SetRandomVehicleDensityMultiplierThisFrame(0.3)
--         SetPedDensityMultiplierThisFrame(0.5)
--         SetScenarioPedDensityMultiplierThisFrame(0.1, 0.1)
--         SetVehicleModelIsSuppressed(GetHashKey("rubble"), true)
--         SetVehicleModelIsSuppressed(GetHashKey("taco"), true)
--         SetVehicleModelIsSuppressed(GetHashKey("biff"), true)
--     end
-- end)

RegisterNetEvent('ls_gunevent:removeGun')
AddEventHandler('ls_gunevent:removeGun',function (hash)
  local weapon =  ''
  local check,weapons = GetCurrentPedWeapon(PlayerPedId(), 1)
  -- RemoveWeaponFromPed(PlayerPedId(),weapons)

  -- print(weapons)
  -- print(GetHashKey("weapon_pistol"))
  local weapon = Config.WeaponModel[weapons]["model"]
  -- print("removeGun"..weapon)
  TriggerServerEvent('ls_gunevent:addPackage',weapon)
end)

RegisterCommand('총패키지',function (soruce,args,command)
  local check, hash = GetCurrentPedWeapon(PlayerPedId(), 1)
  local ammoInWeapon = GetAmmoInPedWeapon(PlayerPedId(), hash)

  local typeammo = Config.Weapons[hash]["ammotype"]
  
  TriggerServerEvent('ls_gunevent:packageGun',hash,ammoInWeapon,typeammo)
end)

RegisterNetEvent('ls_gunevent:PistolAmmoadd')
AddEventHandler('ls_gunevent:PistolAmmoadd', function(val)
    local ped = GetPlayerPed(-1)
    local weapons = GetSelectedPedWeapon(ped);
    if weapons == GetHashKey("WEAPON_GLOCK19") then
	TriggerServerEvent('ls_gunevent:ammoadd', 'WEAPON_GLOCK19',val,true);
    elseif weapons == GetHashKey("WEAPON_PISTOL") then
        TriggerServerEvent('ls_gunevent:ammoadd', 'WEAPON_PISTOL',val,true);   
    else
        TriggerServerEvent('ls_gunevent:ammoadd', 'WEAPON_PISTOL',val,false);        
end

end)