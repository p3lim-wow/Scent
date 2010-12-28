
local function UpdateTime(self, elapsed)
	if(self.expiration) then
		self.expiration = math.max(self.expiration - elapsed, 0)
		self.time:SetText(self.expiration < 90 and math.floor(self.expiration) or '')
	end
end

local function UpdateAuras(header, button)
	if(not button.texture) then
		button.texture = button:CreateTexture(nil, 'BORDER')
		button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.texture:SetAllPoints()

		button.count = button:CreateFontString(nil, 'ARTWORK')
		button.count:SetPoint('BOTTOMRIGHT', -1, 1)
		button.count:SetFont([=[Interface\AddOns\Scent\semplice.ttf]=], 8, 'OUTLINEMONOCHROME')

		button.time = button:CreateFontString(nil, 'ARTWORK')
		button.time:SetPoint('TOPLEFT', 1, -1)
		button.time:SetFont([=[Interface\AddOns\Scent\semplice.ttf]=], 8, 'OUTLINEMONOCHROME')

		button:SetScript('OnUpdate', UpdateTime)
		button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, bottom = -1, left = -1, right = -1}})
		button:SetBackdropColor(0, 0, 0)
	end

	local name, _, texture, count, dtype, duration, expiration = UnitAura('player', button:GetID(), header:GetAttribute('filter'))
	if(name) then
		button.texture:SetTexture(texture)
		button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.count:SetText(count > 1 and count or '')
		button.expiration = expiration - GetTime()

		if(header:GetAttribute('filter') == 'HARMFUL') then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			button:SetBackdropColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		end
	end
end

local function ParseAuras(self, event, unit)
	if(not self:IsShown() or (unit and unit ~= SecureButton_GetUnit(self))) then return end

	for index = 1, 30 do
		local child = self:GetAttribute('child' .. index)
		if(child) then
			UpdateAuras(self, child)
		end
	end
end

local function CreateAuraHeader(filter, ...)
	local header = CreateFrame('Frame', nil, UIParent, 'SecureAuraHeaderTemplate')
	header:SetPoint(...)
	header:HookScript('OnEvent', ParseAuras)

	header:SetAttribute('unit', 'player')
	header:SetAttribute('sortMethod', 'TIME')
	header:SetAttribute('template', 'ScentAuraTemplate')
	header:SetAttribute('filter', filter)

	header:SetAttribute('point', 'TOPLEFT')
	header:SetAttribute('minWidth', 330)
	header:SetAttribute('minHeight', 99)
	header:SetAttribute('xOffset', 33)
	header:SetAttribute('wrapYOffset', -33)
	header:SetAttribute('wrapAfter', 10)
	header:SetAttribute('maxWraps', 3)

	header:Show()

	return header
end

ParseAuras(CreateAuraHeader('HELPFUL', 'TOPLEFT', 15, -15))
ParseAuras(CreateAuraHeader('HARMFUL', 'TOPLEFT', 15, -121))

BuffFrame:UnregisterAllEvents()
BuffFrame:Hide()
