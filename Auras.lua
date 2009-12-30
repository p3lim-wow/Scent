--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local buffFilter = {
	[GetSpellInfo(52610)] = true, -- Druid: Savage Roar
	[GetSpellInfo(22812)] = true, -- Druid: Barkskin
	[GetSpellInfo(16870)] = true, -- Druid: Clearcast
	[GetSpellInfo(50334)] = true, -- Druid: Berserk
	[GetSpellInfo(50213)] = true, -- Druid: Tiger's Fury
	[GetSpellInfo(48517)] = true, -- Druid: Eclipse (Solar)
	[GetSpellInfo(48518)] = true, -- Druid: Eclipse (Lunar)
	[GetSpellInfo(57960)] = true, -- Shaman: Water Shield
	[GetSpellInfo(51566)] = true, -- Shaman: Tidal Waves (Talent)
	[GetSpellInfo(32182)] = true, -- Shaman: Heroism
	[GetSpellInfo(49016)] = true, -- Death Knight: Hysteria
}

local floor, max = math.floor, math.max
local match, format, gsub = string.match, string.format, string.gsub

local function hookTooltip(self)
	if(self.owner and UnitExists(self.owner)) then
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

local function updateTime(self, elapsed)
	self.timeLeft = max(self.timeLeft - elapsed, 0)

	if(self.timeLeft <= 0) then
		self.timeLeft = -1
		self.time:SetText()
		self:SetScript('OnUpdate', nil)
	else
		self.time:SetText(self.timeLeft < 90 and floor(self.timeLeft) or '')
	end
	
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetUnitAura(self.frame.unit, self:GetID(), self.filter)
		hookTooltip(self)
	end
end

local function updateAura(self, icons, unit, icon, index)
	local _, _, _, _, dtype = UnitAura(unit, index, icon.filter)

	if(icon.debuff) then
		local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
		icon:SetBackdropColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
	else
		icon:SetBackdropColor(0, 0, 0)
	end
end

local function createAura(self, button, icons)
	icons.showDebuffType = true
	icons.disableCooldown = true

	button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, bottom = -1, left = -1, right = -1}})
	button:SetBackdropColor(0, 0, 0)
	button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.icon:SetDrawLayer('ARTWORK')
	button.overlay:SetTexture()

	button.time = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	button.time:SetPoint('TOPLEFT', button)

	button:HookScript('OnEnter', hookTooltip)
end

local function filterAura(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, owner)
	if(not (buffFilter[name] and owner == 'player')) then
		icon.owner = owner

		if(timeLeft == 0) then
			icon.time:SetText()
			icon.timeLeft = math.huge
			icon:SetScript('OnUpdate', nil)
		else
			icon.timeLeft = timeLeft - GetTime()
			icon:SetScript('OnUpdate', updateTime)
		end

		return true
	else
		-- Auras that is filtered out will still count for the sorting function.
		icon.timeLeft = timeLeft
	end
end

local function sortAura(a, b)
	return a.timeLeft > b.timeLeft
end

local function positionAura(self, auras)
	table.sort(auras, sortAura)
end

local function style(self)
	self.Buffs = CreateFrame('Frame', nil, UIParent)
	self.Buffs:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -20, 0)
	self.Buffs:SetHeight(64)
	self.Buffs:SetWidth(384)
	self.Buffs.num = 24
	self.Buffs.size = 26
	self.Buffs.spacing = 6
	self.Buffs.initialAnchor = 'TOPRIGHT'
	self.Buffs['growth-x'] = 'LEFT'
	self.Buffs['growth-y'] = 'DOWN'

	self.Debuffs = CreateFrame('Frame', nil, UIParent)
	self.Debuffs:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -20, 0)
	self.Debuffs:SetHeight(64)
	self.Debuffs:SetWidth(384)
	self.Debuffs.num = 24
	self.Debuffs.size = 26
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = 'BOTTOMRIGHT'
	self.Debuffs['growth-x'] = 'LEFT'

	self.PreAuraSetPosition = positionAura
	self.PostCreateAuraIcon = createAura
	self.PostUpdateAuraIcon = updateAura
	self.CustomAuraFilter = filterAura

	BuffFrame:Hide()
	BuffFrame:UnregisterEvent('UNIT_AURA')

	TicketStatusFrame:EnableMouse(false)
	TicketStatusFrame:SetFrameStrata('BACKGROUND')
end

oUF:RegisterStyle('Scent', style)
oUF:SetActiveStyle('Scent')
oUF:Spawn('player') -- dummy
