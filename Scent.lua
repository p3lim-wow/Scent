
local FONT = [=[Interface\AddOns\Scent\semplice.ttf]=]
local BACKDROP = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

local function UpdateTime(self, elapsed)
	if(self.expiration) then
		self.expiration = math.max(self.expiration - elapsed, 0)

		if(self.expiration <= 0 or self.expiration > 90) then
			self.Duration:SetText('')
		else
			self.Duration:SetText(math.floor(self.expiration))
		end
	end
end

local function UpdateAuras(self, index)
	local name, _, texture, count, dtype, duration, expiration = UnitAura(self:GetParent():GetAttribute('unit'), index, self.filter)
	if(name) then
		self.Texture:SetTexture(texture)
		self.Count:SetText(count > 1 and count or '')
		self.expiration = expiration - GetTime()

		if(self.filter == 'HARMFUL') then
			local color = DebuffTypeColor[dtype or 'none']
			self:SetBackdropColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		end
	end
end

local function OnAttributeChanged(self, attribute, value)
	if(attribute == 'index') then
		return UpdateAura(self, value)
	end
end

local function InitiateAura(self)
	local Texture = self:CreateTexture(nil, 'BORDER')
	Texture:SetAllPoints()
	Texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Texture = Texture

	local Count = self:CreateFontString(nil, 'ARTWORK')
	Count:SetPoint('BOTTOMRIGHT', -1, 1)
	Count:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	self.Count = Count

	local Duration = self:CreateFontString(nil, 'ARTWORK')
	Duration:SetPoint('TOPLEFT', 1, -1)
	Duration:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	self.Duration = Duration

	self:SetScript('OnUpdate', UpdateTime)
	self:SetScript('OnAttributeChanged', OnAttributeChanged)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0)
end

local function CreateHeader(filter, ...)
	local header = CreateFrame('Frame', nil, UIParent, 'SecureAuraHeaderTemplate')
	header:SetAttribute('template', 'ScentAuraTemplate')
	header:SetAttribute('unit', 'player')
	header:SetAttribute('filter', filter)
	header:SetPoint(...)

	header:SetAttribute('sortMethod', 'TIME')
	header:SetAttribute('point', 'TOPLEFT')
	header:SetAttribute('minWidth', 330)
	header:SetAttribute('minHeight', 99)
	header:SetAttribute('xOffset', 33)
	header:SetAttribute('wrapYOffset', -33)
	header:SetAttribute('wrapAfter', 10)
	header:SetAttribute('maxWraps', 3)

	header:Show()

	for index = 1, 30 do
		local child = self:GetAttribute('child' .. index)
		if(child) then
			child.filter = filter
			InitiateAura(child)
		end
	end
end

CreateHeader('HELPFUL', 'TOPLEFT', 20, -20)
CreateHeader('HARMFUL', 'TOPLEFT', 20, -121)

BuffFrame:UnregisterAllEvents()
BuffFrame:Hide()
