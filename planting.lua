planting = {}

local common = require("GardeningMW.common")

local plantAdjust_table = {
	["Flora_BM_holly_01"] = 250,		

	["contain_trama_shrub_01"] = 150,
	["T_Hr_Flora_BjoulsRose02"] = 150,	
	
	["T_Ham_Flora_Silverplm04"] = 120,	
	["flora_muckspunge_01"] = 120,
		
	["flora_roobrush_02"] = 100,		
	["T_Cyr_Flora_Indureta01"] = 100,	
	["T_Mw_FloraAT_Lily_01"] = 100,		--thirrin lily water plant

	["flora_kreshweed_02"] = 80,
	["T_Ham_Flora_Persarine01"] = 80,	
	["flora_chokeweed_02"] = 80,	
	["T_Sky_Flora_Ironwood02"] = 80,	
	["flora_rm_scathecraw_01"] = 80,
	["T_Hr_Flora_WrothgGrap01"] = 80,	
	
	["T_Sky_Flora_ForsythTr01"] = 50,		
	["flora_fire_fern_01"] = 50,
	["flora_bc_fern_01"] = 50,	--sporepod
	["T_Hr_Flora_Dragynia01"] = 50,
	["T_Sky_Flora_Bearclaw02"] = 50,	
	["flora_marshmerrow_01"] = 50,
	
	["flora_saltrice_01"] = 30,
	["flora_black_anther_01"] = 30,		
	["T_Mw_Flora_Blackrose02"] = 30,	
	["T_Sky_Flora_BksporeCp03"] = 30,
	["T_Sky_Flora_WithWheat01"] = 30,	
	
	["flora_sedge_01"] = 10,		--goldensedge
	["flora_sedge_02"] = 10,		--noblesedge
	["flora_comberry_01"] = 10,
	["Flora_BC_Fern_04_Chuck"] = 10,	
	["T_Mw_FloraGM_VileMorc01"] = 10,
	["T_Mw_FloraGM_UmbMorch01"] = 10,
	["T_Mw_FloraAT_Uracia_02"] = 10,
	["Flora_plant_01"] = 10,			--horn lily
	["Flora_BM_belladonna_01"] = 10,			
	["Flora_BM_belladonna_02"] = 10,	
	["T_Glb_Flora_Potato01"] = 10,			
	["T_Mw_FloraTV_SpoLotus01"] = 10,
	
	["T_Sky_Flora_Trollroot01"] = -5,
	["T_Mw_FloraDP_SaltCroc01"] = -5,
	["T_Sky_Flora_Widowkiss01"] = -5,
	
	["T_Cyr_Flora_Monkshood01"] = -10,
	
	
	["T_Mw_FloraSH_Tanna01d"] = -50,
	
}

local function adjustingPlantPosition(adjAmount, plantpos)
	plantpos.z = plantpos.z + adjAmount
	return plantpos
end

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
	if plantAdjust_table[common.plantID] then
		plantPosition = adjustingPlantPosition(plantAdjust_table[common.plantID], plantPosition)
	end	
	local newplantRef = tes3.createReference({
		object = common.plantID, 
		position = plantPosition, 
		orientation = dugoutRef.orientation,	
		cell = tes3.player.mobile.cell
		})	
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