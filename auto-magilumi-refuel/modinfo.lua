name = "Auto Magiluminescence Re-fuel"
description = "Automatically re-fuels Magiluminescence using fuel from inventory"
author = "Pooffloof"
version = "1.0.0"

api_version = 10
dst_compatible = true
client_only_mod = true
all_clients_require_mod = false

configuration_options = {
    {
        name = "refuel_threshold",
        label = "Refuel Threshold",
        hover = "Re-fuel when fuel drops below this percentage",
        options = {
            {description = "30%", data = 0.30},
            {description = "40%", data = 0.40},
            {description = "50%", data = 0.50},
            {description = "60%", data = 0.60},
            {description = "99%", data = 0.99},
        },
        default = 0.40,
    },
    {
        name = "check_interval",
        label = "Check Interval",
        hover = "How often to check fuel level (seconds)",
        options = {
            {description = "5 seconds", data = 5},
            {description = "30 seconds", data = 30},
            {description = "60 seconds", data = 60},
            {description = "120 seconds", data = 120},
        },
        default = 120,
    },
    {
        name = "show_messages",
        label = "Show Messages",
        hover = "Player says message when re-fueling",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
    },
}