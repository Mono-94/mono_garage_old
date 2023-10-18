Garage.TestExport = {
    TestExports = false,  -- true test commands | false none
    CustomExport = false, -- true = Garage DB / false custom cars    | /openGarage = test export OpenGarage() | /saveGarage export SaveVehicle()
    jobcar = {           -- Custom Exports Cars
        { model = 'sultan',  plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'manchez', plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'dubsta3', plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'sanchez', plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'bmx',     plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'sultan3', plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'burrito', plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'ninef',   plate = 'MONOFIVE', text = 'M O N O !' },
        { model = 'blazer3', plate = 'MONOFIVE', text = 'M O N O !' },
    }
}


if Garage.TestExport.TestExports then
    RegisterCommand('openGarage', function(source)
        if not Garage.TestExport.CustomExport then
            -- This is DataBase Garage
            exports['mono_garage']:OpenGarage({
                garage = 'Mono Garage - DB Cars',
                type = 'all',
                spawnpos = {
                    GetEntityCoords(cache.ped)
                },
                impound = 'Auto Impound',
                SetInToVehicle = true,
            })
        else
            -- This is CustomCars
            exports['mono_garage']:OpenGarage({
                garage = 'Mono Garage - Custom Cars',
                type = 'all',
                spawnpos = {
                    GetEntityCoords(cache.ped)
                },
                impound = 'Auto Impound',
                SetInToVehicle = true,
                jobcar = Garage.TestExport.jobcar
            })
        end
    end)
    RegisterCommand('saveGarage', function()
        if not Garage.TestExport.CustomExport then
            -- This is DataBase Garage
            exports['mono_garage']:SaveVehicle({
                garage = 'Mono Garage - DB Cars',
                type = 'all',
                distance = 2.5,

            })
        else
            -- This is CustomCars
            exports['mono_garage']:SaveVehicle({
                garage = 'Mono Garage - Custom Cars',
                type = 'custom',
                distance = 2.5,
                jobcar = Garage.TestExport.jobcar
            })
        end
    end)
end
