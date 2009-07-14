--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local id2id = { [16] = 1, [17] = 2 }

do
	local orig = PaperDollItemSlotButton_OnModifiedClick
	function PaperDollItemSlotButton_OnModifiedClick(self, button, ...)
		if(IsShiftKeyDown() and button == 'LeftButton' and id2id[self:GetID()]) then
			CancelItemTempEnchantment(id2id[self:GetID()])
		else
			orig(self, button, ...)
		end
	end
end

CharacterMainHandSlot:RegisterForClicks('AnyUp')
local m = CreateFrame('Frame', 'ScentMainShine', CharacterMainHandSlot, 'AutoCastShineTemplate')
m:SetAllPoints(CharacterMainHandSlot)
m:RegisterEvent('UNIT_INVENTORY_CHANGED')
m:RegisterEvent('PLAYER_LOGIN')
m:SetScript('OnEvent', function(self, event, unit)
	if(unit and unit ~= 'player') then return end

	local active = GetWeaponEnchantInfo()
	if(active) then
		AutoCastShine_AutoCastStart(self, 0.5, 0, 0.5)
	else
		AutoCastShine_AutoCastStop(self)
	end
end)

CharacterSecondaryHandSlot:RegisterForClicks('AnyUp')
local o = CreateFrame('Frame', 'ScentOffShine', CharacterSecondaryHandSlot, 'AutoCastShineTemplate')
o:SetAllPoints(CharacterSecondaryHandSlot)
o:RegisterEvent('UNIT_INVENTORY_CHANGED')
o:RegisterEvent('PLAYER_LOGIN')
o:SetScript('OnEvent', function(self, event, unit)
	if(unit and unit ~= 'player') then return end

	local _, _, _, active = GetWeaponEnchantInfo()
	if(active) then
		AutoCastShine_AutoCastStart(self, 0.5, 0, 0.5)
	else
		AutoCastShine_AutoCastStop(self)
	end
end)

TemporaryEnchantFrame:Hide()
TemporaryEnchantFrame:SetScript('OnUpdate', nil)

for key, value in next, m.sparkles do
	value:SetWidth(value:GetWidth() * 3)
	value:SetHeight(value:GetHeight() * 3)
end

for key, value in next, o.sparkles do
	value:SetWidth(value:GetWidth() * 3)
	value:SetHeight(value:GetHeight() * 3)
end