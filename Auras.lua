local function OnUpdate(self, elapsed)
	self.timeLeft = math.max(self.timeLeft - elapsed, 0)
	self.time:SetText(self.timeLeft < 90 and math.floor(self.timeLeft) or '')
	
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetUnitAura(self.parent:GetParent().unit, self:GetID(), self.filter)
	end
end

local function PostUpdate(element, unit, button, index)
	local _, _, _, _, type = UnitAura(unit, index, button.filter)

	local color = DebuffTypeColor[type] or DebuffTypeColor.none
	button:SetBackdropColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
end

local function PostCreate(element, button)
	element.disableCooldown = true

	button:SetScript('OnUpdate', OnUpdate)
	button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, bottom = -1, left = -1, right = -1}})
	button:SetBackdropColor(0, 0, 0)
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer('ARTWORK')

	button.time = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	button.time:SetPoint('TOPLEFT', button)
end

local function CustomFilter(element, unit, button, ...)
	local _, _, _, _, _, _, timeLeft = ...
	button.timeLeft = (timeLeft == 0) and math.huge or (timeLeft - GetTime())

	return true
end

local PrePosition
do
	local function sort(a, b)
		return a.timeLeft > b.timeLeft
	end

	function PrePosition(element)
		table.sort(element, sort)
	end
end

local function style(self)
	self.Buffs = CreateFrame('Frame', nil, self)
	self.Buffs:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -20, 0)
	self.Buffs:SetHeight(64)
	self.Buffs:SetWidth(384)
	self.Buffs.num = 36
	self.Buffs.size = 26
	self.Buffs.spacing = 6
	self.Buffs.initialAnchor = 'TOPRIGHT'
	self.Buffs['growth-x'] = 'LEFT'
	self.Buffs['growth-y'] = 'DOWN'
	self.Buffs.PreSetPosition = PrePosition
	self.Buffs.PostCreateIcon = PostCreate
	self.Buffs.CustomFilter = CustomFilter

	self.Debuffs = CreateFrame('Frame', nil, self)
	self.Debuffs:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -20, 0)
	self.Debuffs:SetHeight(64)
	self.Debuffs:SetWidth(384)
	self.Debuffs.num = 24
	self.Debuffs.size = 26
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = 'BOTTOMRIGHT'
	self.Debuffs['growth-x'] = 'LEFT'
	self.Debuffs.PreSetPosition = PrePosition
	self.Debuffs.PostCreateIcon = PostCreate
	self.Debuffs.PostUpdateIcon = PostUpdate
	self.Debuffs.CustomFilter = CustomFilter

	BuffFrame:Hide()
	BuffFrame:UnregisterEvent('UNIT_AURA')

	TicketStatusFrame:EnableMouse(false)
	TicketStatusFrame:SetFrameStrata('BACKGROUND')
end

oUF:RegisterStyle('Scent', style)
oUF:SetActiveStyle('Scent')
oUF:Spawn('player') -- dummy
