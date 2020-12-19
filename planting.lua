planting = {}

local common = require("GardeningMW.common")
function planting.startPlanting()
	if string.match(string.lower(common.plantID), "mushlog" ) then 	
		planting.shroomlog()	
	else
		planting.regularPlant()
	end
end	

function planting.regularPlant()
	local dugoutRef = tes3.getReference("_gard_dugout")
	common.ingRef.position = dugoutRef.position	
	dugoutRef.orientation.z = math.random(360)
	local plantPosition = dugoutRef.position
	local newplantRef = tes3.createReference({
		object = common.plantID, 
		position = plantPosition, 
		orientation = dugoutRef.orientation,	
		cell = tes3.player.mobile.cell
		})	
	local npBounds = newplantRef.object.boundingBox
	if npBounds.min.z > 0 then
		newplantRef.position.z = newplantRef.position.z - npBounds.min.z
	else
		newplantRef.position.z = newplantRef.position.z + math.abs(npBounds.min.z) - 10
	end	
	tes3.positionCell{
		cell = tes3.player.mobile.cell,
		position =newplantRef.position,
		reference = newplantRef,	
	}

	newplantRef:disable()	--hiding new plant, enabling it in plantAppears function		
	tes3.messageBox("You've planted %s. Now you need to cover it up.", common.ingRef.object.name )
	tes3.setGlobal("_gard_globalvar", 3 )
end		

function planting.shroomlog()
mwse.log("log start")
	local logCount = mwscript.getItemCount({ reference = tes3.player, item = "_gard_rottenwood"})
	if logCount == 0 then
		tes3.messageBox("You don't have a suitable material to inoculate with %s spore.", common.ingRef.object.name)
		tes3.addItem({ reference = tes3.player,
			item = common.ingRef.object.id,
			count = 1,
		})
	else
		tes3.removeItem({reference = tes3.player, item = "_gard_rottenwood", count = 1})		--remove misc log	
	end	
	local dugoutRef = tes3.getReference("_gard_dugout")
	local logOrientation = dugoutRef.orientation
	logOrientation.z = math.random(360)	
	local logPosition = dugoutRef.position
	logPosition.z = logPosition.z - 20		
	
	local emptyLog = tes3.createReference({
		object = "wl_MushLog_Empty", 
		position = logPosition, 
		orientation = logOrientation,
		scale = 0.5,  								
		})
		
	local InoculatedLog = tes3.createReference({
		object = common.plantID, 
		position = logPosition, 
		orientation = logOrientation,
		scale = 0.5,
		})	
	InoculatedLog:disable()		--enabled in plantappears
	tes3.messageBox("You have inoculated this old log with %s spore", common.ingRef.object.name)
	tes3.setGlobal("_gard_globalvar", 0 )
	safeDelete(dugoutRef)
	safeDelete(common.ingRef)
end

return planting