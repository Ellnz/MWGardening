local config = require("GardeningMW.config")

local function createGeneralCategory(page)
    local category = page:createCategory{
        label = "Settings"
    }
    category:createOnOffButton{
        label = "Digging is illegal in towns and cities.",
        description = "If it's illegal to sleep in an area, it's illegal to go digging around. There's a bounty of 5 gold for trying to do so. However, there's no restrictions on using pots and planters.",
        variable = mwse.mcm.createTableVariable{
            id = "IllegalToggle",
            table = config
        }
    }
--[[	
    category:createDropdown{
        label = "Growing time of plants.",
		description = "The number of days it takes for plants to appear.",
		options = {
			{label = "Instantly"},
			{label = "After one day"},
			{label = "After 3 days"},
			{label = "After 1 week"},
			{label = "After 1 month"},
			},			
        variable = mwse.mcm.createTableVariable{
            id = "GrowthTime",
            table = config
        }
    }
--]]	
	
	
	local Instructions = page:createCategory{
		label = "\nHow to's:"
	}	
   Instructions:createCategory{
        label = "Use of the spade:",
		description = "You use the spade to dig holes into the ground to plant ingredients. To dig, look at the spot that you wish to plant into, and strike twice with the spade. Then drop an ingredient into the resulting hole and cover it up with two more strikes. A new plant cooresponding to the ingredient you dropped will appear in that spot at a later time.",
	}
    Instructions:createCategory{
        label = "Use of the hoe:",
		description = "The hoe can be used to remove organic plants, and some small static plants as well. It doesn't affect grasses added by groundcover mods, nor does it remove large plants like trees. Look at the plant you want to remove and strike twice with the hoe.",
	}
    Instructions:createCategory{
        label = "Use of planters and potting soil:",
		description = "Planters are containers that you can plant into. They range in size from large pots to wide garden beds. Drop and set the planter into position, then drop a potting soil package while looking at the planter. This will fill it with soil, and then you can use the trowel to plant into it.",
	}
	
    return Settings
end

-- Handle mod config menu.
local template = mwse.mcm.createTemplate("GardeningMW")
template:saveOnClose("GardeningMW", config)

local page = template:createSideBarPage{
    label = "Settings Sidebar",
    description = "Hover over a setting to learn more about it."
}

createGeneralCategory(page)

mwse.mcm.register(template)