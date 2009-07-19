--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local function hookTooltip(self)
	GameTooltip:AddLine(format('Casted by %s', self.owner and UnitName(self.owner) or UNKNOWN))
	GameTooltip:Show()
end

local function postCreate(self, button, icons)
	icons.showDebuffType = true
	icons.disableCooldown = true

	local border = button:CreateTexture(nil, 'BORDER')
	border:SetTexture([=[Interface\AddOns\Scent\media\CaithNormal]=])
	border:SetPoint('TOPLEFT', button, -2, 2)
	border:SetPoint('BOTTOMRIGHT', button, 2, -2)
	border:SetVertexColor(0.25, 0.25, 0.25)

	button.overlay:SetDrawLayer('ARTWORK')
	button.overlay:SetTexture([=[Interface\AddOns\Scent\media\CaithBorder]=])
	button.overlay:SetAllPoints(border)
	button.overlay:SetTexCoord(0, 1, 0, 1)

	button.time = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	button.time:SetPoint('TOPLEFT', button)

	button:HookScript('OnEnter', hookTooltip)
end

local function updateTime(self, elapsed)
	self.timeLeft = max(self.timeLeft - elapsed, 0)
	self.time:SetText(self.timeLeft < 90 and floor(self.timeLeft) or '')
	
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetUnitAura(self.frame.unit, self:GetID(), self.filter)
		hookTooltip(self)
	end
end

local function postUpdate(self, icons, unit, icon, index)
	local _, _, _, _, _, duration, expiration = UnitAura(unit, index, icon.filter)

	if(duration > 0 and expiration) then
		icon.timeLeft = expiration - GetTime()
		icon:SetScript('OnUpdate', updateTime)
	else
		icon.timeLeft = nil
		icon.time:SetText()
		icon:SetScript('OnUpdate', nil)
	end
end

local function style(self, unit)
	self.Buffs = CreateFrame('Frame', nil, self)
	self.Buffs:SetPoint('TOPRIGHT', UIParent, -185, -18)
	self.Buffs:SetHeight(110)
	self.Buffs:SetWidth(400)
	self.Buffs.size = 28
	self.Buffs.spacing = 8
	self.Buffs.initialAnchor = 'TOPRIGHT'
	self.Buffs['growth-y'] = 'DOWN'
	self.Buffs['growth-x'] = 'LEFT'
	self.PostCreateAuraIcon = postCreate
	self.PostUpdateAuraIcon = postUpdate
	self.CustomAuraFilter = customFilter

	self.Debuffs = CreateFrame('Frame', nil, self)
	self.Debuffs:SetPoint('TOPRIGHT', self.Buffs, 'BOTTOMRIGHT', 0, -15)
	self.Debuffs:SetHeight(150)
	self.Debuffs:SetWidth(400)
	self.Debuffs.size = 28
	self.Debuffs.spacing = 8
	self.Debuffs.initialAnchor = 'TOPRIGHT'
	self.Debuffs['growth-y'] = 'DOWN'
	self.Debuffs['growth-x'] = 'LEFT'
	self.PostCreateAuraIcon = postCreate
	self.PostUpdateAuraIcon = postUpdate

	BuffFrame:Hide()
	BuffFrame:UnregisterEvent("UNIT_AURA")

	TicketStatusFrame:EnableMouse(false)
	TicketStatusFrame:SetFrameStrata('BACKGROUND')
end

oUF:RegisterStyle('P3limAuras', style)
oUF:SetActiveStyle('P3limAuras')
oUF:Spawn('player') -- dummy