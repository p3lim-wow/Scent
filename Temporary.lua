local function UpdateEnchant(self, event, unit)
	if(event == 'UNIT_INVENTORY_CHANGED' and unit ~= 'player') then return end

	local name = self:GetName()
	local main, _, _, off = GetWeaponEnchantInfo()
	if((name:find('Main') and main) or (name:find('Off') and off)) then
		AutoCastShine_AutoCastStart(self, 0.5, 0, 0.5)
	else
		AutoCastShine_AutoCastStop(self)
	end
end

do
	local orig = PaperDollItemSlotButton_OnModifiedClick
	function PaperDollItemSlotButton_OnModifiedClick(self, button)
		if(IsAltKeyDown() and button == 'RightButton') then
			CancelItemTempEnchantment(self:GetID() == 16 and 1 or self:GetID() == 17 and 2)
		else
			orig(self, button)
		end
	end
end

local mainhand = CreateFrame('Button', 'TempMainHandGlow', PaperDollFrame, 'AutoCastShineTemplate')
mainhand:SetAllPoints(CharacterMainHandSlot)
mainhand:SetScript('OnEvent', UpdateEnchant)
mainhand:RegisterEvent('UNIT_INVENTORY_CHANGED')
mainhand:RegisterEvent('PLAYER_LOGIN')
mainhand:EnableMouse(false)

mainhand.time = mainhand:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
mainhand.time:SetPoint('BOTTOMRIGHT')
CharacterMainHandSlot:RegisterForClicks('AnyUp')


local offhand = CreateFrame('Button', 'TempOffHandGlow', PaperDollFrame, 'AutoCastShineTemplate')
offhand:SetAllPoints(CharacterSecondaryHandSlot)
offhand:SetScript('OnEvent', UpdateEnchant)
offhand:RegisterEvent('UNIT_INVENTORY_CHANGED')
offhand:RegisterEvent('PLAYER_LOGIN')
offhand:EnableMouse(false)

offhand.time = offhand:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
offhand.time:SetPoint('BOTTOMRIGHT')
CharacterSecondaryHandSlot:RegisterForClicks('AnyUp')

TemporaryEnchantFrame:Hide()
TemporaryEnchantFrame:SetScript('OnUpdate', nil)