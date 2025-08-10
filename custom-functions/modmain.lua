-- Removes all items placed on the ground with the specified prefab from the world
clean = function(prefab)
    if not prefab then
        return
    end
    
    for k, v in pairs(GLOBAL.Ents) do
        if v.prefab == prefab and 
           v.components and 
           v.components.inventoryitem and 
           v.components.inventoryitem.owner == nil then
            v:Remove()
        end
    end
end

-- Removes all specified common excess items placed on the ground from the world
cleancom = function()
    local common_items = {
        stinger = true,
        spidergland = true,
        spiderhat = true,
        silk = true,
        mosquitosack = true,
        twigs = true
    }

    for k, v in pairs(GLOBAL.Ents) do
        if common_items[v.prefab] and 
           v.components and 
           v.components.inventoryitem and 
           v.components.inventoryitem.owner == nil then
            v:Remove()
        end
    end
end

GLOBAL.clean = clean
GLOBAL.cleancom = cleancom
GLOBAL.cc = cleancom -- shorter alias
