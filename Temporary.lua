do
	local frame = CreateFrame('Button', nil, Minimap)
	frame:SetPoint('BOTTOMLEFT')
	frame:SetSize(10, 30)
	frame:Hide()

	local text = frame:CreateFontString(nil, 'ARTWORK')
	text:SetAllPoints()
	text:SetFont([=[Interface\AddOns\oUF_P3lim\media\semplice.ttf]=], 9, 'OUTLINE')
	text:SetJustifyH('LEFT')

	frame:SetScript('OnUpdate', function(self, elapsed)
		if(self.elapsed and self.elapsed > 1) then
			local enchant, time = GetWeaponEnchantInfo()
			if(enchant) then
				local str, val = SecondsToTimeAbbrev(time / 1000)
				text:SetFormattedText(str:gsub(' ', ''), val)
			end

			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end)

	frame:SetScript('OnClick', function(self, button)
		CancelItemTempEnchantment(1)
	end)

	frame:RegisterEvent('PLAYER_LOGIN')
	frame:RegisterEvent('UNIT_INVENTORY_CHANGED')
	frame:SetScript('OnEvent', function(self, event, unit)
		if(unit and unit ~= 'player') then return end

		if(GetWeaponEnchantInfo()) then
			self:Show()
		else
			self:Hide()
		end
	end)

	TemporaryEnchantFrame:Hide()
end
