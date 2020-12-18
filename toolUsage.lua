toolUsage = {}

local common = require("GardeningMW.common")

function toolUsage.start()
	local gvar = tes3.getGlobal("_gard_globalvar")
	local dig = tes3.player.mobile.actionData.attackSwing
	if (dig) then
		common.digcount = common.digcount + 1
		tes3.playSound{ soundPath = "Fx\\digging.wav" }
	end
	if common.digcount == 2 then
		if (common.toolReadied == "_gard_hoe") then	
			toolUsage.plantremover()
		elseif (common.toolReadied == "_gard_shovel") then
			if (gvar == 0) then	
				toolUsage.digginghole()				
			elseif (gvar == 1) then	
				toolUsage.removehole()	
			elseif (gvar == 3) then
				toolUsage.fillingIn()
			end	
		elseif (common.toolReadied == "_gard_trowel") then		
			if (gvar == 0) then
				toolUsage.diggingInPlanter()
			elseif (gvar == 1) then	
				toolUsage.removehole()	
			elseif (gvar == 3) then
				toolUsage.fillingIn()
			end				
		end
		common.digcount = 0				
	end
end

function toolUsage.fillingIn()
	local dugoutRef = tes3.getReference("_gard_dugout")
	local filledhole = tes3.createReference{object = "_g_filledhole", position = dugoutRef.position, cell = tes3.player.mobile.cell}				
	safeDelete(dugoutRef)	
	safeDelete(common.ingRef)
	tes3.setGlobal("_gard_globalvar", 0 )		

end

function toolUsage.diggingInPlanter()
	local hitResult = tes3.rayTest{
		position = tes3.getPlayerEyePosition(), 
		direction = tes3.getPlayerEyeVector(),
		maxDistance = 256,
		}
	local hitReference = hitResult and hitResult.reference
		
	if string.match(string.lower(hitReference.object.id), "planter")  then 
		local dugInPlanter = tes3.createReference{
			position = hitResult.intersection,
			object = "_gard_dugout",
			scale = 0.8,
			cell = tes3.player.mobile.cell,
			}
		tes3.setGlobal("_gard_globalvar", 1 )	
	end	
end

function toolUsage.digginghole()
	local result = tes3.rayTest{
		position = tes3.getPlayerEyePosition(), 
		direction = tes3.getPlayerEyeVector(),
		root = tes3.game.worldLandscapeRoot, 
		maxDistance = 256
		}
	if result then 
		local playerRef = tes3.getPlayerRef()
		local distanceToTarget = playerRef.position:distance(result.intersection)		
		if distanceToTarget <= 128 then  				
		local newDugoutRef = tes3.createReference{
			position = result.intersection, 
			object = "_gard_dugout"
			}
		end
		tes3.setGlobal("_gard_globalvar", 1 )	
	end	
end

function toolUsage.removehole()		
	local ref = tes3.getReference("_gard_dugout")
	if ref then	safeDelete(ref)	end
	tes3.mobilePlayer.weaponReady = false
	tes3.messageBox("You've filled in the hole without planting anything.")	
	tes3.setGlobal("_gard_globalvar", 0 )		
end

function toolUsage.plantremover()	
-- using _gard_hoe to remove organic containers (most plants) and some static plants
	local result = tes3.rayTest{
		position = tes3.getPlayerEyePosition(), 
		direction = tes3.getPlayerEyeVector(), 
		maxDistance = 256
		}
	local plantToRemove = result.reference
	if (plantToRemove.object.objectType == tes3.objectType.container) then
		if (plantToRemove.object.organic) then
			safeDelete(plantToRemove)
		end	
	elseif 	(plantToRemove.object.objectType == tes3.objectType.static) then
		if string.match(string.lower(plantToRemove.object.id), "flora") then
			if string.match(string.lower(plantToRemove.object.id), "grass") then safeDelete(plantToRemove) end
			if string.match(string.lower(plantToRemove.object.id), "fern") then	safeDelete(plantToRemove) end
			if string.match(string.lower(plantToRemove.object.id), "shrub") then safeDelete(plantToRemove)	end	
		end	
	end	
end

local planterList = {
	["_g_dummyPlanter1"] = "Furn_Com_Planter",		
	["_g_dummyPlanter2"] = "furn_planter_01",		
	["_g_dummyPlanter3"] = "furn_planter_02",		
	["_g_dummyPlanter4"] = "furn_planter_03",		
	["_g_dummyPlanter5"] = "furn_planter_04",		
	["_g_dummyPlanter6"] = "Furn_Planter_MH_01",	
	["_g_dummyPlanter7"] = "Furn_Planter_MH_02",	
	["_g_dummyPlanter8"] = "Furn_Planter_MH_03",	
	["_g_dummyPlanter9"] = "Furn_Planter_MH_04",	
	["_g_dummyPlanter10"] = "Furn_Planter_MH_05",	
	["_g_dummyPlanter11"] = "Ex_MH_bazaar_planter_02",	
	["_g_dummyPlanter12"] = "Ex_MH_bazaar_planter_01",	
	
}

function toolUsage.planterSetup()
	local result = tes3.rayTest{
		position = tes3.getPlayerEyePosition(), 
		direction = tes3.getPlayerEyeVector(), 
		maxDistance = 256
		}
	local miscPlanter = result.reference

	if  string.match(miscPlanter.object.id, "_g_dummyPlanter") then 
		tes3.messageBox{
			message = "Set this planter here and fill it with soil?",
			buttons = {"Yes", "No"},
			callback = function(e)
				if e.button == 0 then	--yes
					local setPlanter = tes3.createReference({
						object = planterList[miscPlanter.object.id],	
						cell = tes3.player.mobile.cell,
						position = miscPlanter.position,
						orientation = miscPlanter.orientation
						})
					safeDelete(miscPlanter)	
					tes3.messageBox("planter is ready")
				elseif e.button == 1 then	--no				
				end
			end,
		}
	end	
	
end
return toolUsage