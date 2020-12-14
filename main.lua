local ID_Table
local toolUsage
local common 
local planting
local gotToolBox = "gotGardenToolBox"

event.register("modConfigReady", function()
    require("GardeningMW.mcm")
end)

local config = require("GardeningMW.config")

local function droppedPlanter(e)
	if e.reference.object.objectType ~= tes3.objectType.miscItem then return end	
	if string.match(e.reference.object.id, "_g_dummyPlanter") then	
		common.dummyPlanterRef = e.reference
		mwse.log("dummy ref is %s", common.dummyPlanterRef)
	end	
end

local function plantAppears(e) -- enables new plants to simulate growth while player was away
	if (e.cell.isInterior == true and e.cell.behavesAsExterior == false) then return end		
	local currentCell = e.cell	
	calledFrom_plantAppears(currentCell)	
end

local function droppedIngredient(e)	--itemDropped event, e is dropped item
	if not (tes3.getGlobal("_gard_globalvar") == 1 ) then return end
	if e.reference.object.objectType ~= tes3.objectType.ingredient then return end	
	common.ingRef = e.reference	
	common.plantID = ID_Table[common.ingRef.object.id]		
	if common.plantID == nil then		--non-plant ingredient dropped
		tes3.messageBox("Nothing will grow from this.")
		return
	end	
	calledFrom_droppedIngredient()
end	

local function toolReadied(e)
	if (e.reference ~= tes3.player) then return end
	if not (e.weaponStack or e.weaponStack.object.spearTwoWide) then return end
	if not string.match(e.weaponStack.object.id, "_gard_") then return end
	common.toolReadied = e.weaponStack.object.id
	
	if common.toolReadied ~= "_gard_trowel" then
		if e.reference.mobile.cell.isInterior == true then
			tes3.messageBox("You can't plant anything in here.")
			return	
		end	
		if (config.IllegalToggle == true) then	
			if (e.reference.mobile.cell.restingIsIllegal == true) then
				tes3.messageBox("Digging is illegal here.")
			end	
		end
	end	
end

local function usingTools(e)
	if (e.reference ~= tes3.player) then return end
	if (e.reference.mobile.readiedWeapon.object.id ~= common.toolReadied) then return end
	if common.toolReadied ~= "_gard_trowel" then	
		if (config.IllegalToggle == true) then	
			tes3.triggerCrime({
				type = tes3.crimeType.trespass,
				value = 5,
			})	
		end
	end	
	toolUsage.start()	
end

local function onMerchantTalk(e)    
	if (e.activator ~= tes3.player or e.target.object.objectType ~= tes3.objectType.npc) then return end
	if e.target.object.class.id ~= "Smith" then return end
    local container = getOrCreateGardenToolsBox()
    if e.target.data[gotToolBox] ~= true then
		e.target.data[gotToolBox] = true
		tes3.positionCell{reference=container, cell=e.target.cell, position={0,0,0}}
		tes3.setOwner{reference=container, owner=e.target.baseObject}
	end	
end

local function noPickyUppy(e)
	if e.target == common.ingRef then
		return false
	end		
end

local function initialized()
	common = require("GardeningMW.common")
	toolUsage = require("GardeningMW.toolUsage")
--	planterUsage = require("GardeningMW.planterUsage")
	
	ID_Table = require("GardeningMW.ID_Table")
	planting = require("GardeningMW.planting")
	event.register("itemDropped",droppedPlanter)
	event.register("cellChanged", plantAppears)
	event.register("itemDropped", droppedIngredient)
	event.register("weaponReadied", toolReadied)
	event.register("attack", usingTools)
	event.register("activate", onMerchantTalk)
	event.register("activate", noPickyUppy)
	
	print("[Gardening in Morrowind] Initialized")	
end

event.register("initialized", initialized )


