name = "Auto Magiluminescence Re-fuel"
description = "Automatically re-fuels Magiluminescence when it reaches 50% durability using Nightmare Fuel from inventory"
author = "Pooffloof"
version = "1.0.0"

api_version = 10
dst_compatible = true
client_only_mod = true  -- This is the key setting!
all_clients_require_mod = false

configuration_options = {
    {
        name = "refuel_threshold",
        label = "Refuel Threshold",
        hover = "Refuel when fuel drops below this percentage",
        options = {
            {description = "20%", data = 0.20},
            {description = "50%", data = 0.50},
            {description = "99%", data = 0.99},
        },
        default = 0.99,
    },
    {
        name = "check_interval",
        label = "Check Interval",
        hover = "How often to check fuel level (seconds)",
        options = {
            {description = "1 second", data = 1},
            {description = "3 seconds", data = 3},
            {description = "5 seconds", data = 5},
            {description = "10 seconds", data = 10},
        },
        default = 5,
    },
    {
        name = "show_messages",
        label = "Show Messages",
        hover = "Display chat messages when refueling",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
    },
}