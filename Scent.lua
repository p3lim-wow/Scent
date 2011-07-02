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

local function UpdateAura(self, index)
	local name, _, texture, count, dtype, duration, expiration = UnitAura(self:GetParent():GetAttribute('unit'), index, 'HELPFUL')
	if(name) then
		self.Texture:SetTexture(texture)
		self.Count:SetText(count > 1 and count or '')
		self.expiration = expiration - GetTime()
	end
end

local function OnAttributeChanged(self, attribute, value)
	if(attribute == 'index') then
		return UpdateAura(self, value)
	end
end

local function SkinAura(self)
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

	UpdateAura(self, self:GetID())
end

local function InitiateAura(self, name, value)
	if(string.match(name, '^child(%d)$')) then
		SkinAura(value)
	end
end

local header = CreateFrame('Frame', nil, UIParent, 'SecureAuraHeaderTemplate')
header:SetAttribute('template', 'ScentAuraTemplate')
header:SetAttribute('unit', 'player')
header:SetAttribute('filter', 'HELPFUL')
header:SetPoint('TOPLEFT', 20, -20)

header:SetAttribute('sortMethod', 'TIME')
header:SetAttribute('point', 'TOPLEFT')
header:SetAttribute('minWidth', 330)
header:SetAttribute('minHeight', 99)
header:SetAttribute('xOffset', 33)
header:SetAttribute('wrapYOffset', -33)
header:SetAttribute('wrapAfter', 10)
header:SetAttribute('maxWraps', 3)

RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')

header:HookScript('OnAttributeChanged', InitiateAura)
header:Show()

BuffFrame:UnregisterAllEvents()
BuffFrame:Hide()
