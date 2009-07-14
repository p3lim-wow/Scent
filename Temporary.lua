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
m.t = m:CreateTexture(nil, 'OVERLAY')
m.t:SetTexture([=[Interface\Buttons\UI-Button-Outline]=])
m.t:SetVertexColor(1/2, 0, 1/2)
m.t:SetBlendMode('ADD')
m.t:SetPoint('TOPRIGHT', m, 15, 15)
m.t:SetPoint('BOTTOMLEFT', m, -15, -15)
m:SetAllPoints(CharacterMainHandSlot)
m:RegisterEvent('UNIT_INVENTORY_CHANGED')
m:RegisterEvent('PLAYER_LOGIN')
m:SetScript('OnEvent', function(self, event, unit)
	if(unit and unit ~= 'player') then return end

	local active = GetWeaponEnchantInfo()
	if(active) then
		self.t:Show()
	else
		self.t:Hide()
	end
end)

CharacterSecondaryHandSlot:RegisterForClicks('AnyUp')
local o = CreateFrame('Frame', 'ScentOffShine', CharacterSecondaryHandSlot, 'AutoCastShineTemplate')
o.t = o:CreateTexture(nil, 'OVERLAY')
o.t:SetTexture([=[Interface\Buttons\UI-Button-Outline]=])
o.t:SetVertexColor(1/2, 0, 1/2)
o.t:SetBlendMode('ADD')
o.t:SetPoint('TOPRIGHT', o, 15, 15)
o.t:SetPoint('BOTTOMLEFT', o, -15, -15)
o:SetAllPoints(CharacterSecondaryHandSlot)
o:RegisterEvent('UNIT_INVENTORY_CHANGED')
o:RegisterEvent('PLAYER_LOGIN')
o:SetScript('OnEvent', function(self, event, unit)
	if(unit and unit ~= 'player') then return end

	local _, _, _, active = GetWeaponEnchantInfo()
	if(active) then
		self.t:Show()
	else
		self.t:Hide()
	end
end)

TemporaryEnchantFrame:Hide()
TemporaryEnchantFrame:SetScript('OnUpdate', nil)
