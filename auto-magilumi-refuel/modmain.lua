local DEBUG_MODE = false
local function DebugLog(...)
    if DEBUG_MODE then
        print(...)
    end
end

DebugLog("=== Auto Magiluminescence Re-fuel mod starting to load ===")

local REFUEL_THRESHOLD = GetModConfigData("refuel_threshold") or 0.2
local CHECK_INTERVAL = GetModConfigData("check_interval") or 5
local SHOW_MESSAGES = GetModConfigData("show_messages") or true

DebugLog("Config loaded - Threshold:", REFUEL_THRESHOLD, "Interval:", CHECK_INTERVAL, "Messages:", SHOW_MESSAGES)

-- Import required constants - delay until player activated to ensure everything is loaded
local EQUIPSLOTS, ACTIONS, BufferedAction

local function AutoRefuelYellowAmulet(player)
    -- Check if EQUIPSLOTS.BODY exists (might be modified by other mods)
    if not EQUIPSLOTS or not EQUIPSLOTS.BODY then
        DebugLog("EQUIPSLOTS.BODY not available")
        return
    end
    
    local amulet = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    
    -- Check if there's actually an item equipped in the body slot
    if not amulet then
        DebugLog("No item equipped in body slot")
        return
    end
    
    -- Check if the equipped item is actually a magiluminescence
    if amulet.prefab ~= "yellowamulet" then
        DebugLog("Equipped item is not a magiluminescence:", amulet.prefab)
        return
    end
    
    DebugLog("Equipped item:", amulet.prefab)

    -- Check for fueled component in different ways
    local fueled_component = nil
    local fuel_percent = nil
    
    if amulet.replica and amulet.replica.fueled then
        fueled_component = amulet.replica.fueled
        fuel_percent = fueled_component:GetPercent()
        DebugLog("Found replica fueled component, fuel percent:", fuel_percent)
    elseif amulet.components and amulet.components.fueled then
        fueled_component = amulet.components.fueled
        fuel_percent = fueled_component:GetPercent()
        DebugLog("Found direct fueled component, fuel percent:", fuel_percent)
    else
        DebugLog("No fueled component found on yellow amulet")
        -- Try alternative approach - check if it's a finiteuses item
        if amulet.replica and amulet.replica.finiteuses then
            local uses = amulet.replica.finiteuses:GetUses()
            local maxuses = amulet.replica.finiteuses:GetMaxUses()
            if uses and maxuses and maxuses > 0 then
                fuel_percent = uses / maxuses
                DebugLog("Using finiteuses instead - uses:", uses, "max:", maxuses, "percent:", fuel_percent)
            end
        end
    end
    
    if not fuel_percent then
        DebugLog("Could not determine fuel level for yellow amulet")
        return
    end
    
    if fuel_percent <= REFUEL_THRESHOLD then
        DebugLog("Yellow amulet fuel is low for player:", player, "Fuel percent:", fuel_percent)
        local nightmare_fuel = player.components.inventory:FindItem(function(item)
            return item.prefab == "nightmarefuel"
        end)
        
        if nightmare_fuel then
            DebugLog("Found nightmare fuel for player:", player)
                        
            action = BufferedAction(player, amulet, ACTIONS.ADDFUEL, nightmare_fuel)
            DebugLog("Action created:", action)
            if action and action:IsValid() then
                action:Do()
                DebugLog("Refueled yellow amulet for player:", player)
                if SHOW_MESSAGES then
                    player.components.talker:Say("Auto-refueled my magilumi!")
                end
            else
                DebugLog("Refuel action is not valid or nil, action:", action)
                if action then
                    DebugLog("Action exists but not valid")
                else
                    DebugLog("Action is nil")
                end
            end
        else
            DebugLog("No nightmare fuel found in inventory")
            if SHOW_MESSAGES then
                player.components.talker:Say("Need nightmare fuel!")
            end
        end
    else
        DebugLog("Yellow amulet fuel is above threshold, no refuel needed")
    end
end

local function StartAutoRefuel(player)
    if not player then
        DebugLog("Player not available")
        return
    end
    
    DebugLog("Starting auto-refuel task for player:", player)
    player:DoPeriodicTask(CHECK_INTERVAL, AutoRefuelYellowAmulet)
end

-- This runs when the player entity is fully loaded and ready
local function OnPlayerActivated(player)
    DebugLog("OnPlayerActivated called for player:", player)
    DebugLog("Local player activated, starting auto-refuel")
    
    EQUIPSLOTS = GLOBAL.EQUIPSLOTS
    ACTIONS = GLOBAL.ACTIONS
    BufferedAction = GLOBAL.BufferedAction
    
    DebugLog("EQUIPSLOTS:", EQUIPSLOTS and "loaded" or "nil")
    DebugLog("ACTIONS:", ACTIONS and "loaded" or "nil") 
    DebugLog("BufferedAction:", BufferedAction and "loaded" or "nil")
    
    StartAutoRefuel(player)
end

AddPlayerPostInit(function(player)
    DebugLog("Auto Magiluminescence Re-fuel mod loaded for player:", player)
    DebugLog("ThePlayer is:", ThePlayer)
    
    -- Listen for when the player becomes active
    player:ListenForEvent("playeractivated", OnPlayerActivated)
end)