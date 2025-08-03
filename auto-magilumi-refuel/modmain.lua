print("=== Auto Magiluminescence Re-fuel mod starting to load ===")

local REFUEL_THRESHOLD = GetModConfigData("refuel_threshold") or 0.2
local CHECK_INTERVAL = GetModConfigData("check_interval") or 5
local SHOW_MESSAGES = GetModConfigData("show_messages") or true

print("Config loaded - Threshold:", REFUEL_THRESHOLD, "Interval:", CHECK_INTERVAL, "Messages:", SHOW_MESSAGES)

-- Import required constants - delay until player activated to ensure everything is loaded
local EQUIPSLOTS, ACTIONS, BufferedAction

local function AutoRefuelYellowAmulet(player)
    print("Checking yellow amulet fuel for player:", player)
    local amulet = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    
    if not amulet then
        print("No item equipped in body slot")
        return
    end
    
    print("Equipped item:", amulet.prefab)
    
    if amulet.prefab ~= "yellowamulet" then
        print("Equipped item is not a yellow amulet, it's:", amulet.prefab)
        return
    end
    
    -- Check for fueled component in different ways
    local fueled_component = nil
    local fuel_percent = nil
    
    if amulet.replica and amulet.replica.fueled then
        fueled_component = amulet.replica.fueled
        fuel_percent = fueled_component:GetPercent()
        print("Found replica fueled component, fuel percent:", fuel_percent)
    elseif amulet.components and amulet.components.fueled then
        fueled_component = amulet.components.fueled
        fuel_percent = fueled_component:GetPercent()
        print("Found direct fueled component, fuel percent:", fuel_percent)
    else
        print("No fueled component found on yellow amulet")
        -- Try alternative approach - check if it's a finiteuses item
        if amulet.replica and amulet.replica.finiteuses then
            local uses = amulet.replica.finiteuses:GetUses()
            local maxuses = amulet.replica.finiteuses:GetMaxUses()
            if uses and maxuses and maxuses > 0 then
                fuel_percent = uses / maxuses
                print("Using finiteuses instead - uses:", uses, "max:", maxuses, "percent:", fuel_percent)
            end
        end
    end
    
    if not fuel_percent then
        print("Could not determine fuel level for yellow amulet")
        return
    end
    
    print("Yellow amulet fuel percent:", fuel_percent, "Threshold:", REFUEL_THRESHOLD)
    
    if fuel_percent <= REFUEL_THRESHOLD then
        print("Yellow amulet fuel is low for player:", player, "Fuel percent:", fuel_percent)
        local nightmare_fuel = player.components.inventory:FindItem(function(item)
            return item.prefab == "nightmarefuel"
        end)
        
        if nightmare_fuel then
            print("Found nightmare fuel for player:", player)
                        
            -- Try different approaches to refueling
            local action = nil
            
            -- Method 1: Try ACTIONS.ADDFUEL (the correct client-side action)
            if ACTIONS.ADDFUEL then
                print("Using ACTIONS.ADDFUEL")
                action = BufferedAction(player, amulet, ACTIONS.ADDFUEL, nightmare_fuel)
            -- Method 2: Try ACTIONS.ADDWETFUEL as alternative
            elseif ACTIONS.ADDWETFUEL then
                print("Using ACTIONS.ADDWETFUEL as alternative")
                action = BufferedAction(player, amulet, ACTIONS.ADDWETFUEL, nightmare_fuel)
            -- Method 3: Fallback to ACTIONS.REPAIR (which worked)
            elseif ACTIONS.REPAIR then
                print("Using ACTIONS.REPAIR as fallback")
                action = BufferedAction(player, amulet, ACTIONS.REPAIR, nightmare_fuel)
            else
                print("No suitable action found for refueling")
                return
            end
            
            print("Creating action with:", player, amulet, action and "valid_action" or "nil", nightmare_fuel)
            print("Action created:", action)
            if action and action:IsValid() then
                print("Action is valid, performing refuel")
                action:Do()
                print("Refueled yellow amulet for player:", player)
                if SHOW_MESSAGES then
                    player.components.talker:Say("Auto-refueled my magilumi!")
                end
            else
                print("Refuel action is not valid or nil, action:", action)
                if action then
                    print("Action exists but not valid")
                else
                    print("Action is nil")
                end
            end
        else
            print("No nightmare fuel found in inventory")
            if SHOW_MESSAGES then
                player.components.talker:Say("Need nightmare fuel!")
            end
        end
    else
        print("Yellow amulet fuel is above threshold, no refuel needed")
    end
end

local function StartAutoRefuel(player)
    if not player then
        print("Player not available")
        return
    end
    
    print("Starting auto-refuel task for player:", player)
    player:DoPeriodicTask(CHECK_INTERVAL, AutoRefuelYellowAmulet)
end

-- This runs when the player entity is fully loaded and ready
local function OnPlayerActivated(player)
    print("OnPlayerActivated called for player:", player)
    print("Local player activated, starting auto-refuel")
    
    -- Import required constants here when everything is loaded
    EQUIPSLOTS = GLOBAL.EQUIPSLOTS
    ACTIONS = GLOBAL.ACTIONS
    BufferedAction = GLOBAL.BufferedAction
    
    print("EQUIPSLOTS:", EQUIPSLOTS and "loaded" or "nil")
    print("ACTIONS:", ACTIONS and "loaded" or "nil") 
    print("BufferedAction:", BufferedAction and "loaded" or "nil")
    
    if ACTIONS then
        print("Available fuel actions: ADDFUEL =", ACTIONS.ADDFUEL and "available" or "nil", 
              "ADDWETFUEL =", ACTIONS.ADDWETFUEL and "available" or "nil")
    end
    
    StartAutoRefuel(player)
end

AddPlayerPostInit(function(player)
    print("Auto Magiluminescence Re-fuel mod loaded for player:", player)
    print("ThePlayer is:", ThePlayer)
    
    -- Listen for when the player becomes active
    player:ListenForEvent("playeractivated", OnPlayerActivated)
end)