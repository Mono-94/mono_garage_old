if Garage.Version then 
    local function CheckMenuVersion()
        PerformHttpRequest('https://raw.githubusercontent.com/Mono-94/sy_garage/main/fxmanifest.lua', function(error, result, headers)
            local actual = GetResourceMetadata(GetCurrentResourceName(), 'version')

          if not result then print("^6SY GARAGE^7 -  version couldn't be checked") end
    
          local version = string.sub(result, string.find(result, "%d.%d.%d"))

          if tonumber((version:gsub("%D+", ""))) > tonumber((actual:gsub("%D+", ""))) then
            print('^6SY GARAGE^7  - The version ^2'..version ..'^0 is available, you are still using version ^1'.. actual..'^0')
            print('^6SY GARAGE^7  - Download the new version at: https://github.com/Mono-94/sy_garage/releases.')
          else
            print('^6SY GARAGE^7 - You are using the latest version of the script.')
        end

        end)
      end
      CheckMenuVersion()
end

