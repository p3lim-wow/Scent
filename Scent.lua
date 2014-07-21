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
	local name, _, texture, count, _, duration, expiration = UnitAura(self:GetParent():GetAttribute('unit'), index, 'HELPFUL')
	if(name) then
		self.Texture:SetTexture(texture)
		self.Count:SetText(count > 1 and count or '')
		self.expiration = expiration - GetTime()
	end
end

local function OnAttributeChanged(self, attribute, value)
	if(attribute == 'index') then
		UpdateAura(self, value)
	end
end

local function InitiateAura(self, name, Button)
	if(not string.match(name, '^child')) then return end

	Button:SetScript('OnUpdate', UpdateTime)
	Button:SetScript('OnAttributeChanged', OnAttributeChanged)
	Button:SetBackdrop(BACKDROP)
	Button:SetBackdropColor(0, 0, 0)

	local Texture = Button:CreateTexture(nil, 'BORDER')
	Texture:SetAllPoints()
	Texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	Button.Texture = Texture

	local Count = Button:CreateFontString(nil, 'ARTWORK')
	Count:SetPoint('BOTTOMRIGHT', -1, 1)
	Count:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Button.Count = Count

	local Duration = Button:CreateFontString(nil, 'ARTWORK')
	Duration:SetPoint('TOPLEFT', 1, -1)
	Duration:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Button.Duration = Duration

	UpdateAura(Button, Button:GetID())
end

local header = CreateFrame('Frame', 'Scent', UIParent, 'SecureAuraHeaderTemplate')
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
