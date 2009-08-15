--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local buffFilter = {
	[GetSpellInfo(61336)] = true,
	[GetSpellInfo(22842)] = true,
	[GetSpellInfo(52610)] = true,
	[GetSpellInfo(22812)] = true,
	[GetSpellInfo(16870)] = true,
	[GetSpellInfo(62600)] = true,
}

local floor, max = math.floor, math.max
local match, format, gsub = string.match, string.format, string.gsub

local function hookTooltip(self)
	if(self.owner) then
		if(self.owner == 'vehicle' or self.owner == 'pet') then
			GameTooltip:AddLine(format('Cast by %s <%s>', UnitName(self.owner), UnitName('player')))
		elseif(self.owner:match('^partypet[1-4]$')) then
			GameTooltip:AddLine(format('Cast by %s <%s>', UnitName(self.owner), UnitName(format('party%d', self.owner:gsub('^partypet(%d)$', '%1')))))
		elseif(self.owner:match('^raidpet[1-40]$')) then
			GameTooltip:AddLine(format('Cast by %s <%s>', UnitName(self.owner), UnitName(format('raid%d', self.owner:gsub('^raidpet(%d)$', '%1')))))
		else
			GameTooltip:AddLine(format('Cast by %s', UnitName(self.owner)))
		end
	else
		GameTooltip:AddLine(format('Cast by %s', UNKNOWN))
	end

	GameTooltip:Show()
end

local function setPosition(self, icons, maxIcons)
	if(icons and maxIcons > 0) then
		local col, cols = 0, floor(400 / 36 + 0.5)
		local row, rows = 0, floor(110 / 36 + 0.5)

		for index = 1, maxIcons do
			local button = icons[index]
			if(button and button:IsShown()) then
				if(col >= cols) then
					col = 0
					row = row + 1
				end

				button:ClearAllPoints('TOPRIGHT', icons, 'TOPRIGHT', col * 36 * -1, row * 36 * -1)

				col = col + 1
			end
		end
	end
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

local function customFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, expiration, caster)
	if(not (buffFilter[name] and caster == 'player')) then
		return true
	end
end

local function style(self, unit)
	self.Buffs = CreateFrame('Frame', nil, self)
	self.Buffs:SetPoint('TOPRIGHT', UIParent, -185, -18)
	self.Buffs:SetHeight(110)
	self.Buffs:SetWidth(400)
	self.SetAuraPosition = setPosition
	self.PostCreateAuraIcon = postCreate
	self.PostUpdateAuraIcon = postUpdate
	self.CustomAuraFilter = customFilter

	self.Debuffs = CreateFrame('Frame', nil, self)
	self.Debuffs:SetPoint('TOPRIGHT', self.Buffs, 'BOTTOMRIGHT', 0, -15)
	self.Debuffs:SetHeight(110)
	self.Debuffs:SetWidth(400)
	self.SetAuraPosition = setPosition
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