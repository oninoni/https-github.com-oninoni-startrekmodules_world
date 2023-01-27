---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--            World Entity           --
--           Base | Client           --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:Init(clientData)
	self:SetData(clientData)
	self:SetDynData(clientData)

	local modelScale = self.Scale or 1
	local skyboxEntity = ClientsideModel(self.Model, RENDERGROUP_BOTH)
	skyboxEntity:SetNoDraw(true)
	skyboxEntity:SetModelScale(modelScale)
	self.SkyboxEntity = skyboxEntity

	local nearbyEntity = ClientsideModel(self.Model, RENDERGROUP_BOTH)
	nearbyEntity:SetNoDraw(true)
	nearbyEntity:SetModelScale(modelScale * 1024)
	self.NearbyEntity = nearbyEntity
end

function SELF:Terminate()
	SafeRemoveEntity(self.SkyboxEntity)
end

function SELF:SetData(clientData)
	self.Pos = WorldVectorFromTable(clientData.Pos)
	self.Ang = clientData.Ang

	self.Model = clientData.Model
	self.Diameter = clientData.Diameter
	self.Scale = clientData.Scale
end

function SELF:SetDynData(clientData)
end

local NEARBY_MAX = 12
local VECTOR_MAX = Star_Trek.World.Vector_Max or 131071
function SELF:RenderThink(shipPos, shipAng)
	local pos, ang = WorldToLocalBig(self.Pos, self.Ang, shipPos, shipAng)
	local distance = pos:Length()
	self.Distance = distance

	local nearbyEntity = self.NearbyEntity
	if distance < NEARBY_MAX then
		self.RenderNearby = true

		nearbyEntity:SetPos(pos * 1024)
		nearbyEntity:SetAngles(ang)
	else
		self.RenderNearby = false
	end
	if distance + self.Diameter < NEARBY_MAX then
		self.RenderSkybox = false
	else
		self.RenderSkybox = true
	end

	local skyboxEntity = self.SkyboxEntity

	-- Apply scaling
	local modelScale = self.Scale or 1
	if distance > VECTOR_MAX then
		pos = Vector(pos)
		pos:Normalize()
		pos = pos * VECTOR_MAX

		skyboxEntity:SetModelScale(modelScale * (VECTOR_MAX / distance))
	else
		skyboxEntity:SetModelScale(modelScale)
	end

	skyboxEntity:SetPos(pos)
	skyboxEntity:SetAngles(ang)
end

function SELF:DrawSkybox()
	if not self.RenderSkybox then return end
	self.SkyboxEntity:DrawModel()
end

function SELF:DrawNearby()
	if not self.RenderNearby then return end
	self.NearbyEntity:DrawModel()
end