--[[
	© 2014 TeslaCloud Studios.
	
	Feel free to use, edit and share this code, but do not
	re-distribute or sell without the permission of it's author.
	
	Feel free to contact us at support@teslacloud.net
--]]

local ROLE = TTT.Role:New("joker");
	ROLE.roleID = "joker";
	ROLE.icon = "ttt/icons/roles/joker.png";
	ROLE.color = "0 0 0 0";
	ROLE.prefix = "FELLOW JOKER";
	ROLE.group = RG_FFA;
	ROLE.shop = false;
	ROLE.hasCredits = false;
	ROLE.startCredits = 0;
	ROLE.maxPly = 10;
	ROLE.minPly = 3;
	ROLE.ratio = 3;
	ROLE.chance = 50;
	ROLE.realTime = true;
	ROLE.shouldWearDetectiveHat = false;

function ROLE.Callback(player)
		print("Picked Joker - "..player:Name());

end;



function playerDies( victim, inflictor, attacker )

	print "Function called!"
		if (TTT.Role:GetRole(victim) == "joker" && TTT.Role:GetRole(attacker) == "innocent" || TTT.Role:GetRole(victim) == "joker" && TTT.Role:GetRole(attacker) == "detective") then
			print "Code Called!"
			attacker:Kill()
			timer.Simple(1, function()
			victim:SetTeam( TEAM_TERROR )
			victim:SetRole(detective)
			victim:Spawn()
			end)

		elseif (TTT.Role:GetRole(victim) == "joker" && TTT.Role:GetRole(attacker) == "traitor") then
			attacker:Kill()
			timer.Simple(1, function()
			victim:SetTeam( TEAM_TERROR )
			victim:SetRole(traitor)
			victim:Spawn()
			end)		
		end	
end

hook.Add( "PlayerDeath", "playerDeathTest", playerDies )


ROLE:Register();

