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
		local col, cols = 0, floor(400 / 34 + 0.5)
		local row, rows = 0, floor(110 / 34 + 0.5)

		for index = 1, maxIcons do
			local button = icons[index]
			if(button and button:IsShown()) then
				if(col >= cols) then
					col = 0
					row = row + 1
				end

				button:ClearAllPoints()
				button:SetPoint('TOPRIGHT', icons, 'TOPRIGHT', col * 34 * -1, row * 34 * -1)

				col = col + 1
			end
		end
	end
end

local function postCreate(self, button, icons)
	icons.showDebuffType = true
	icons.disableCooldown = true

	button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, bottom = -1, left = -1, right = -1}})
	button:SetBackdropColor(0, 0, 0)
	button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	button.icon:SetDrawLayer('ARTWORK')
	button.overlay:SetTexture()

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
	local _, _, _, _, dtype, duration, expiration = UnitAura(unit, index, icon.filter)

	if(duration and duration > 0 and expiration) then
		icon.timeLeft = expiration - GetTime()
		icon:SetScript('OnUpdate', updateTime)
	else
		icon.timeLeft = nil
		icon.time:SetText()
		icon:SetScript('OnUpdate', nil)
	end

	if(icon.debuff) then
		local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
		icon:SetBackdropColor(color.r * 0.3, color.g * 0.3, color.b * 0.3)
	else
		icon:SetBackdropColor(0, 0, 0)
	end
end

local function customFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, expiration, caster)
	if(not (buffFilter[name] and caster == 'player')) then
		return true
	end
end

local function style(self)
	self.Buffs = CreateFrame('Frame', nil, UIParent)
	self.Buffs:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -30, 0)
	self.Buffs:SetHeight(110)
	self.Buffs:SetWidth(400)
	self.Buffs.size = 26
	self.SetAuraPosition = setPosition
	self.PostCreateAuraIcon = postCreate
	self.PostUpdateAuraIcon = postUpdate
	self.CustomAuraFilter = customFilter

	self.Debuffs = CreateFrame('Frame', nil, UIParent)
	self.Debuffs:SetPoint('TOPRIGHT', self.Buffs, 'BOTTOMRIGHT', 0, -15)
	self.Debuffs:SetHeight(110)
	self.Debuffs:SetWidth(400)
	self.Debuffs.size = 26
	self.SetAuraPosition = setPosition
	self.PostCreateAuraIcon = postCreate
	self.PostUpdateAuraIcon = postUpdate

	BuffFrame:Hide()
	BuffFrame:UnregisterEvent('UNIT_AURA')

	TicketStatusFrame:EnableMouse(false)
	TicketStatusFrame:SetFrameStrata('BACKGROUND')
end

oUF:RegisterStyle('Scent', style)
oUF:SetActiveStyle('Scent')
oUF:Spawn('player') -- dummy
