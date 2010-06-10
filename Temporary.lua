local function GetEnchantInfo(id)
	local _, mainhand, _, _, offhand = GetWeaponEnchantInfo()
	if(id == 1) then
		return mainhand
	elseif(id == 2) then
		return offhand
	end
end

local function CreateTemp(id, point)
	local frame = CreateFrame('Button', nil, Minimap)
	frame:SetPoint('BOTTOM'..point)
	frame:SetSize(10, 30)
	frame:Hide()

	local text = frame:CreateFontString(nil, 'ARTWORK')
	text:SetAllPoints()
	text:SetFont([=[Interface\AddOns\Scent\semplice.ttf]=], 9, 'OUTLINE')
	text:SetJustifyH(point)

	frame:SetScript('OnClick', function() CancelItemTempEnchantment(id) end)
	frame:SetScript('OnUpdate', function(self, elapsed)
		if((self.elapsed or 6) > 5) then
			local str, val = SecondsToTimeAbbrev(GetEnchantInfo(id) / 1e3)
			text:SetFormattedText(str:gsub(' ', ''), val)

			self.elapsed = 0
		else
			self.elapsed = self.elapsed + elapsed
		end
	end)

	frame:RegisterEvent('PLAYER_LOGIN')
	frame:RegisterEvent('UNIT_INVENTORY_CHANGED')
	frame:SetScript('OnEvent', function(self, event, unit)
		if(unit and unit ~= 'player') then return end

		if(GetEnchantInfo(id)) then
			self:Show()
		else
			self:Hide()
		end
	end)
end

do
	CreateTemp(1, 'LEFT')
	CreateTemp(2, 'RIGHT')

	TemporaryEnchantFrame:Hide()
end
