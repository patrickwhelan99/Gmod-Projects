---- Example TTT custom weapon

-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile( "shared.lua" )
   
   -- Defines the messages for client to listen for
   util.AddNetworkString( "danceClient" )
   util.AddNetworkString( "song" )
   
   
   -- Gets a random song from folder
   function songSelector()
		local files, directories = file.Find("sound/weapons/dance_gun/*", "GAME", "nameasc")
		local tablefiles = table.ToString( files, "files", true ) 
		local tabledirs = table.ToString( directories, "dirs", true ) 
		easy, peasy = table.Random(files) -- easy is values, peasy is keys
		lemon = "weapons/dance_gun/".. easy
			
			-- Sends the message to clients to make them dance
			net.Start( "danceClient" )
			net.Broadcast()
			
			-- Sends the message to clients telling them what song to play
			net.Start( "song" )
			net.WriteString( lemon )
			net.Broadcast()

	end


end
   

if CLIENT then
   SWEP.PrintName = "Dance Gun"
   SWEP.Slot      = 6 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 60
   SWEP.ViewModelFlip = false
   
   
   
   -- Networking Shizzle
    net.Receive( "danceClient", function( length, client )
		timer.Simple(1, function() LocalPlayer():ConCommand("act dance") end)
	 end )
	 
	 
	 net.Receive( "song", function( length, client )
		song = net.ReadString()
	 end )
	 
end




-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_tttbase"

--- Standard GMod values
SWEP.HoldType			= "pistol"
SWEP.Primary.Delay       = 10
SWEP.Primary.Recoil      = 1
SWEP.Primary.Automatic   = false
SWEP.Primary.Damage      = 0
SWEP.Primary.Cone        = 0.025
SWEP.Primary.Ammo        = "" -- Leave this as is
SWEP.Primary.ClipSize    = 1
SWEP.Primary.ClipMax     = 1
SWEP.Primary.DefaultClip = 1


SWEP.ViewModel  = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_Pistol.mdl"

	

function SWEP:PrimaryAttack()

	-- Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
	self:TakePrimaryAmmo( 1 )
	
	if SERVER then
		songSelector()
	end
	
	canTaunt = true -- Allows taunting or the 'act commands'
	timer.Simple(3, function() canTaunt = false end)
	
	if CLIENT then
		timer.Simple(1, function() surface.PlaySound( song )  end) -- Timer is needed to give var time to set 
	end
end
	

	
	
	-- Freezes players and unfreezes them after timer
		for k, v in pairs( player.GetAll() ) do
			 if not v:HasWeapon("dance_gun") then
					v:Freeze(true)
					if SERVER then			
					timer.Simple(5, function() v:Freeze(false) end)
					end
		end
end


	-- MAKE PEOPLE DANCE AT END OF ROUND
function danceGood()

	canTaunt = true
	for k, v in pairs( player.GetAll() ) do
		if CLIENT then
			v:ConCommand("act dance")
		end
	end
end

	hook.Add("TTTEndRound", "whatacoolname", danceGood)
	
	-- This code sets the dance condition to false on round start
function dontDance()
	canTaunt = false
end
	
	hook.Add("TTTPrepareRound", "whatanawesomename", dontDance)



--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

-- Equipment menu information is only needed on the client
if CLIENT then
   -- Path to the icon material
   SWEP.Icon = "vgui/ttt/dance_gun"

   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "Dance your foes to Death! ... Well almost"
   };
end

-- Tell the server that it should download our icon to clients.
if SERVER then
   -- It's important to give your icon a unique name. GMod does NOT check for
   -- file differences, it only looks at the name. This means that if you have
   -- an icon_ak47, and another server also has one, then players might see the
   -- other server's dumb icon. Avoid this by using a unique name.
   resource.AddFile("materials/vgui/ttt/dance_gun.vmt")
end



