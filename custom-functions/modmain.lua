-- Removes all items placed on the ground with the specified prefab from the world
clean = function(prefab)
    if not prefab then
        return
    end
    
    for k, v in pairs(Ents) do
        if v.prefab == prefab and 
           v.components and 
           v.components.inventoryitem and 
           v.components.inventoryitem.owner == nil then
            v:Remove()
        end
    end
end

GLOBAL.clean = clean