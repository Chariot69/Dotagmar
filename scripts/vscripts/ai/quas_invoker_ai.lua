--[[ Quas InvokerAI ]]
require( "ai/invoker_shared_ai" )

function Spawn( entityKeyValues )
	if IsServer() then
		thisEntity:SetContextThink( "QuasInvokerThink", QuasInvokerThink, 0.25 )
	
		s_Quas  = thisEntity:FindAbilityByName( "invoker_quas" )
		s_Wex = thisEntity:FindAbilityByName( "invoker_wex" )
		s_Exort  = thisEntity:FindAbilityByName( "invoker_exort" )
		s_Tornado = thisEntity:FindAbilityByName( "invoker_tornado" )
		s_IceWall = thisEntity:FindAbilityByName( "invoker_ice_wall" )
		s_ColdSnap = thisEntity:FindAbilityByName( "invoker_cold_snap" )
		s_GhostWalk = thisEntity:FindAbilityByName( "invoker_ghost_walk" )
		s_Invoke = thisEntity:FindAbilityByName( "invoker_invoke" )
		s_DeafeningBlast = thisEntity:FindAbilityByName( "invoker_deafening_blast" )

		s_Blink = nil
		s_Sheep = nil

		s_ActiveSpell1 = nil
		s_ActiveSpell2 = nil
		s_ChangeSpellQueue = {}

		s_vRetreatTarget = nil
	end
    
end

function FindItems()
	for i = 0, DOTA_ITEM_MAX - 1 do
		local item = thisEntity:GetItemInSlot( i )
		if item then
			if item:GetAbilityName() == "item_blink" then
				s_Blink = item
			end
			if item:GetAbilityName() == "item_sheepstick" then
				s_Sheep = item
			end
		end
	end
end

function QuasInvokerThink()
	if IsServer() then
		if GameRules:IsGamePaused() then
			return 0.1 
		end

		if thisEntity:IsAlive() == false then
			return 0.1
		end

		if s_Blink == nil or s_Sheep == nil then
			FindItems()
		end

		s_ActiveSpell1 = thisEntity:GetAbilityByIndex( 3 )
		s_ActiveSpell2 = thisEntity:GetAbilityByIndex( 4 )


		if CheckToCastBlink( thisEntity, s_Blink ) == true then
			CastBlink( thisEntity, s_Blink  )
			return 0.1
		end

		if CheckToCastSheep( thisEntity, s_Sheep ) == true then
			CastSheep( thisEntity, s_Sheep )
			return 01
		end

		if s_ActiveSpell2:IsFullyCastable() then
			if s_ActiveSpell2 == s_ColdSnap and CheckToCastColdSnap( thisEntity, s_ActiveSpell2 ) == true then
				CastColdSnap( thisEntity, s_ActiveSpell2 )
				return 0.1
			end

			if s_ActiveSpell2 == s_DeafeningBlast and CheckToCastDeafeningBlast( thisEntity, s_ActiveSpell2 ) == true then
			CastDeafeningBlast( thisEntity, s_ActiveSpell2 )
			return 0.1
		end

			if s_ActiveSpell2 == s_IceWall and CheckToCastIceWall( thisEntity, s_ActiveSpell2 ) == true then
				CastIceWall( thisEntity, s_ActiveSpell2 )
				return 0.1
			end

			if s_ActiveSpell2 == s_Tornado and CheckToCastTornado( thisEntity, s_ActiveSpell2) == true then
				CastTornado( thisEntity, s_ActiveSpell2 )
				return 0.1
			end

			if s_ActiveSpell2 == s_GhostWalk and CheckToCastGhostWalk( thisEntity, s_ActiveSpell2 ) == true  then
				CastGhostWalk( thisEntity, s_ActiveSpell2 )
				return 0.1
			end
		end

		if s_ActiveSpell1:IsFullyCastable() then
			if s_ActiveSpell1 == s_GhostWalk and CheckToCastGhostWalk( thisEntity, s_ActiveSpell1 ) == true  then
				CastGhostWalk( thisEntity, s_ActiveSpell1 )
				return 5.0
			end

			if s_ActiveSpell1 == s_DeafeningBlast and CheckToCastDeafeningBlast( thisEntity, s_ActiveSpell1 ) == true then
				CastDeafeningBlast( thisEntity, s_ActiveSpell1 )
				return 0.1
			end

			if s_ActiveSpell1 == s_IceWall and CheckToCastIceWall( thisEntity, s_ActiveSpell1 ) == true then
				CastIceWall( thisEntity, s_ActiveSpell1 )
				return 0.1
			end

			if s_ActiveSpell1 == s_ColdSnap and CheckToCastColdSnap( thisEntity, s_ActiveSpell1 ) == true then
				CastColdSnap( thisEntity, s_ActiveSpell1 )
				return 0.1
			end

			if s_ActiveSpell1 == s_Tornado and CheckToCastTornado( thisEntity, s_ActiveSpell1 ) == true then
				CastTornado( thisEntity, s_ActiveSpell1 )
				return 0.1
			end	
		end

		return InvokeThink()
	end

	return 0.1
end

function InvokeThink()
	if IsServer() then
		if #s_ChangeSpellQueue > 0 then
			local spell = s_ChangeSpellQueue[1]
			if spell == nil or spell:IsCooldownReady() == false then
				return 0.1
			end
			if s_ChangeSpellQueue ~= nil then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = spell:entindex()
				})
				table.remove( s_ChangeSpellQueue, 1 )
			end
			return 0.1
		else
			if s_ActiveSpell1:GetAbilityName() == "invoker_empty1" or CheckToInvoke( s_ColdSnap ) then
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Invoke )
				return 0.1
			end

			if s_ActiveSpell2:GetAbilityName() == "invoker_empty1" or CheckToInvoke( s_IceWall ) then
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Exort )
				table.insert( s_ChangeSpellQueue, s_Invoke )
				return 0.1
			end

			if CheckToInvoke( s_DeafeningBlast ) then
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Wex )
				table.insert( s_ChangeSpellQueue, s_Exort )
				table.insert( s_ChangeSpellQueue, s_Invoke )
				return 0.1
			end

			if CheckToInvoke( s_Tornado ) == true then
				table.insert( s_ChangeSpellQueue, s_Wex )
				table.insert( s_ChangeSpellQueue, s_Wex )
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Invoke )
				return 0.1
			end

			--[[
			if CheckToInvoke( s_GhostWalk )  then
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Quas )
				table.insert( s_ChangeSpellQueue, s_Wex )
				table.insert( s_ChangeSpellQueue, s_Invoke )
				return 0.1
			end		
			]]
		end 
	end
	
	return 0.1
end


function CheckToInvoke( spell )
	if spell == s_ActiveSpell1 or spell == s_ActiveSpell2 then
		return false
	end

	if spell:IsCooldownReady() == false then
		return false
	end

	if spell == s_ColdSnap then
		return CheckToCastColdSnap( thisEntity, spell )
	end

	if spell == s_DeafeningBlast then
		return CheckToCastDeafeningBlast( thisEntity, spell )
	end

	if spell == s_Tornado then
		return CheckToCastTornado( thisEntity, spell )
	end

	if spell == s_IceWall then
		return CheckToCastIceWall( thisEntity, spell )
	end

	if spell == s_GhostWalk then
		return CheckToCastGhostWalk( thisEntity, spell )
	end

	return false
end




