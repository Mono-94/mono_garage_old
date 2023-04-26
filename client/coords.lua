if Garage.RadialCopyCoords then
    lib.addRadialItem({
        {
            id = 'Cordenadas',
            label = 'Coords',
            icon = 'location-dot',
            menu = 'copy_coords'
        },

    })
    lib.registerRadial({
        id = 'copy_coords',
        items = {

            {
                label = '{x= 0,y= 0,z= 0,w= 0}',
                onSelect = function()
                    local ped = cache.ped
                    local coords = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)
                    lib.setClipboard('{ x = ' .. coords.x .. ', y = ' .. coords.y .. ', z = ' ..
                        coords.z .. ', h = ' .. heading .. '},')
                end
            },
            {
                label = 'vector3(0,0,0)',
                onSelect = function()
                    local ped = cache.ped
                    local coords = GetEntityCoords(ped)
                    lib.setClipboard('vec3(' .. coords.x .. ',' .. coords.y .. ',' .. coords.z .. ')')
                end
            },
            {
                label = 'vector4(0,0,0)',
                onSelect = function()
                    local ped = cache.ped
                    local coords = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)
                    lib.setClipboard('vector4(' .. coords.x .. ', ' .. coords.y .. ',' ..
                        coords.z .. ',' .. heading .. '),')
                end
            },
            {
                label = 'HEADING',
                onSelect = function()
                    local ped = cache.ped
                    lib.setClipboard(GetEntityHeading(ped))
                end
            },
        }
    })
end
