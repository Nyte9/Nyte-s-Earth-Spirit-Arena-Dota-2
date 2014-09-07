

if ESwars == nil then
	ESwars = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end


-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = ESwars()
	GameRules.AddonTemplate:InitGameMode()
end

function ESwars:OnNPCSpawned( keys )
	
	local spawnedUnit = EntIndexToHScript( keys.entindex )
	if not spawnedUnit:IsIllusion() and spawnedUnit:IsHero() then
		local level = spawnedUnit:GetLevel()
		while level < 25 do
			print("level is less than minimum")
			spawnedUnit:AddExperience (2000,false)
			level = spawnedUnit:GetLevel()
		end
	end
end

function ESwars:InitGameMode()
	

	--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:SetHeroRespawnEnabled( true )
	GameRules:SetSameHeroSelectionEnabled( true )
	self.scoreDire = 0
	self.scoreRadiant = 0
	self.kills_to_win = 30

	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( ESwars, 'OnNPCSpawned' ), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(ESwars, 'OnEntityKilled'), self )
end


function ESwars:OnEntityKilled( keys )
	local killedUnit = EntIndexToHScript(keys.entindex_killed)
	local killerEntity = nil
	killerEntity = EntIndexToHScript( keys.entindex_attacker )
	local killedTeam = killedUnit:GetTeam()
	local killerTeam = killerEntity:GetTeam()

	if killedTeam == DOTA_TEAM_BADGUYS then
		if killerTeam == 2 then
			self.scoreRadiant = self.scoreRadiant + 1
		end
		elseif killedTeam == DOTA_TEAM_GOODGUYS then
			if killerTeam == 3 then
				self.scoreDire = self.scoreDire + 1
			end
	end



	if keys.entindex_attacker == nil then
		return
	end

	if killedUnit:IsRealHero() == true then
		print("respawning")
	end


	if self.scoreRadiant == self.kills_to_win-5 then
		Say(nil,"5 kills remaining", false)
	end
	if self.scoreDire == self.kills_to_win-5 then
		Say(nil,"5 kills remaining", false)
	end
	

	-- Add on the kill
	if killedTeam == DOTA_TEAM_BADGUYS then
		if killerTeam == 2 then
			self.scoreRadiant = self.scoreRadiant + 1
		end
		elseif killedTeam == DOTA_TEAM_GOODGUYS then
			if killerTeam == 3 then
				self.scoreDire = self.scoreDire + 1
			end
	end



	-- Victory checking
	if self.scoreDire >= self.kills_to_win then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
		Say(nil,"Dire Wins!", false)
		GameRules:Defeated()
	end
	if self.scoreRadiant >= self.kills_to_win  then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
		Say(nil,"Radiant Wins!", false)
		GameRules:Defeated()
	end

end


-- Evaluate the state of the game
function ESwars:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end


