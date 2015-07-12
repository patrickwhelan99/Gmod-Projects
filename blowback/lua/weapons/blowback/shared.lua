---- Sniper with increased damage but a chance to explode!



-- First some standard GMod stuff

if SERVER then

   AddCSLuaFile( "shared.lua" )

end



if CLIENT then

   SWEP.PrintName = "Blowback"

   SWEP.Slot      = 6 -- add 1 to get the slot number key



   SWEP.ViewModelFOV  = 40

   SWEP.ViewModelFlip = false

end



-- Always derive from weapon_tttbase.

SWEP.Base				= "weapon_tttbase"



--- Standard GMod values



SWEP.HoldType			= "ar2"



SWEP.Primary.Delay       = 0.2

SWEP.Primary.Recoil      = 4

SWEP.Primary.Automatic   = false

SWEP.Primary.Damage      = 80

SWEP.Primary.Cone        = 0.025

SWEP.Primary.Ammo        = "357"

SWEP.Primary.ClipSize    = 1

SWEP.Primary.ClipMax     = 10

SWEP.Primary.DefaultClip = 1

SWEP.Primary.Sound       = Sound( "weapon_AWP.Single" )



SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel          = Model("models/weapons/cstrike/c_snip_scout.mdl")
SWEP.WorldModel         = Model("models/weapons/w_snip_scout.mdl")

SWEP.Primary.Sound = Sound(")weapons/scout/scout_fire-1.wav")

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )


---------------------------------------------------------BEGINNING OF SCOPE SECTION-----------------------------------------------------------

function SWEP:SetZoom(state)
   if CLIENT then
      return
   elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
      if state then
         self.Owner:SetFOV(20, 0.3)
      else
         self.Owner:SetFOV(0, 0.2)
      end
   end
end

function SWEP:PrimaryAttack( worldsnd )
   self.BaseClass.PrimaryAttack( self.Weapon, worldsnd )
   self:SetNextSecondaryFire( CurTime() + 0.1 )
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   else
      self:EmitSound(self.Secondary.Sound)
   end

   self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:DefaultReload( ACT_VM_RELOAD )
   self:SetIronsights( false )
   self:SetZoom( false )
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)
         
         -- cover gaps on top and bottom of screen
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end
-----------------------------------------------------------------END OF SCOPE SECTION-----------------------------------------------------------



-- Left Click Hook

function SWEP:PrimaryAttack()

-- Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
	self:ShootBullet(1, 80, .075)
	self:TakePrimaryAmmo( 1 )
	self:EmitSound( "weapon_AWP.Single", 400, 400 )
	
if SERVER then
		local randint = math.random(1,3)
		if (randint == 1) then
		
		local explode = ents.Create( "env_explosion" ) -- creates the explosion
		explode:SetPos( self.Owner:GetPos() )
		-- this creates the explosion through your self.Owner:GetEyeTrace, which is why I put eyetrace in front
		explode:SetOwner( self.Owner ) -- this sets you as the person who made the explosion
		explode:Spawn() --this actually spawns the explosion
		explode:SetKeyValue( "iMagnitude", "220" ) -- the magnitude
		explode:Fire( "Explode", 0, 0 )
		explode:EmitSound( "weapon_AWP.Single", 400, 400 ) -- the sound for the explosion, and how far away it can be heard
        	self.Owner:Kill()

		end
	end
end



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

SWEP.AmmoEnt = "item_ammo_357_ttt"



-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If

-- a role is in this table, those players can buy this.

SWEP.CanBuy = { ROLE_TRAITOR }



-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should

-- receive this weapon as soon as the round starts. In this case, none.

SWEP.InLoadoutFor = nil



-- If LimitedStock is true, you can only buy one per round.

SWEP.LimitedStock = false



-- If AllowDrop is false, players can't manually drop the gun with Q

SWEP.AllowDrop = true



-- If IsSilent is true, victims will not scream upon death.

SWEP.IsSilent = false



-- If NoSights is true, the weapon won't have ironsights

SWEP.NoSights = false



-- Equipment menu information is only needed on the client

if CLIENT then

   -- Path to the icon material

   SWEP.Icon = "VGUI/ttt/icon_myserver_ak47"



   -- Text shown in the equip menu

   SWEP.EquipMenuData = {

      type = "Weapon",

      desc = "It's a musket!"

   };

end



-- Tell the server that it should download our icon to clients.

if SERVER then

   -- It's important to give your icon a unique name. GMod does NOT check for

   -- file differences, it only looks at the name. This means that if you have

   -- an icon_ak47, and another server also has one, then players might see the

   -- other server's dumb icon. Avoid this by using a unique name.

   resource.AddFile("materials/VGUI/ttt/icon_myserver_ak47.vmt")

end


