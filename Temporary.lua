--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local function onEvent(self, event, unit)
	if(unit and unit ~= 'player') then return end

	local main, _, _, off = GetWeaponEnchantInfo()
	if(self.index == 1 and main) then
		self.texture:Show()
	elseif(self.index == 2 and off) then
		self.texture:Show()
	else
		self.texture:Hide()
	end
end

local function createBorder(parent, index)
	local texture = parent:CreateTexture(nil, 'OVERLAY')
	texture:SetTexture([=[Interface\Buttons\UI-Button-Outline]=])
	texture:SetVertexColor(1/2, 0, 1/2)
	texture:SetBlendMode('ADD')
	texture:SetPoint('TOPRIGHT', parent, 15, 15)
	texture:SetPoint('BOTTOMLEFT', parent, -15, -15)

	local dummy = CreateFrame('Frame')
	dummy.index = index
	dummy.texture = texture
	dummy:RegisterEvent('UNIT_INVENTORY_CHANGED')
	dummy:RegisterEvent('PLAYER_LOGIN')
	dummy:SetScript('OnEvent', onEvent)
end

do
	local id = {[16] = 1, [17] = 2}
	local orig = PaperDollItemSlotButton_OnModifiedClick
	function PaperDollItemSlotButton_OnModifiedClick(self, button, ...)
		if(IsShiftKeyDown() and button == 'LeftButton' and id[self:GetID()]) then
			CancelItemTempEnchantment(id[self:GetID()])
		else
			orig(self, button, ...)
		end
	end
end

createBorder(CharacterMainHandSlot, 1)
createBorder(CharacterSecondaryHandSlot, 2)

TemporaryEnchantFrame:Hide()
TemporaryEnchantFrame:SetScript('OnUpdate', nil)