local common = {}

common.digcount = 0
common.ingRef = true
common.plantID = true
common.logCountGlobal = true
common.toolReadied = true
common.dummyPlanterRef = true


function safeDelete(reference)
	reference:disable()
	timer.delayOneFrame(function() mwscript.setDelete{reference = reference} end)
end	

function getOrCreateGardenToolsBox()
    local ref = tes3.getReference(tes3.player.data.containerID)
    if ref then return ref end
    local ref = tes3.createReference{
        object="_g_toolbox",
        position=tes3.player.position,
        cell=tes3.player.cell,   }
    ref:clone()
    ref:disable()
    tes3.positionCell{reference=ref, position={0, 0, 0}}
    tes3.player.data.containerID = ref.id
    return ref
end

function calledFrom_plantAppears(cellRef)
	tes3.setGlobal("_gard_plantCounter", 0)		--allow more planting 		
	for ref in cellRef:iterateReferences(tes3.objectType.container) do
		if ref.object.organic and ref.disabled then	
			ref:enable()
		end	
	end	
	for ref in cellRef:iterateReferences(tes3.objectType.static) do	
		if ref.id == "_g_filledhole" then safeDelete(ref) end
		if ref.id == "wl_MushLog_Empty" then safeDelete(ref) end	
	end			
	tes3.setGlobal("_gard_globalvar", 0 )
end

function calledFrom_droppedIngredient()
	common.ingRef.scale = 0.5
	local howmanyingreds = common.ingRef.stackSize	
	common.ingRef.stackSize = 1
	if howmanyingreds > 1 then	--replacing excess ingredients in player inventory
		tes3.addItem({ reference = tes3.player,
			item = common.ingRef.object.id,
			count = howmanyingreds - 1,
			})
	end	
	common.digcount = 0	
	planting.startPlanting()

end

return common




