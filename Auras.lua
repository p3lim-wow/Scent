--[[
 Copyright (c) 2006-2008 Trond A Ekseth
 Copyright (c) 2008-2009 Adrian L Lange

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
--]]

local math_floor = math.floor

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('TOPRIGHT', self, 'BOTTOMLEFT', -1, 0)
	GameTooltip:SetUnitAura('player', self:GetID(), self.filter)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(self, button)
	if(button == 'RightButton') then
		CancelUnitBuff('player', self:GetID(), self.filter)
	end
end

local function OnUpdate(self)
	if(self.expiration) then
		local timeleft = math_floor(self.expiration - GetTime() + 0.5)
		if(timeleft < 90) then
			self.time:SetText(timeleft > 0 and timeleft or '')
		else
			self.time:SetText()
		end
	else
		self:SetScript('OnUpdate', nil)
	end
end

local function CreateAura(self, index, filter)
	local button = CreateFrame('Frame', nil, self)
	button:EnableMouse(true)
	button:SetWidth(28)
	button:SetHeight(28)
	button.filter = filter

	button:SetScript('OnEnter', OnEnter)
	button:SetScript('OnLeave', OnLeave)
	button:SetScript('OnMouseUp', OnMouseUp)

	button.icon = button:CreateTexture(nil, 'BACKGROUND')
	button.icon:SetAllPoints(button)

	button.time = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	button.time:SetPoint('TOPLEFT', button)

	button.count = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	button.count:SetPoint('BOTTOMRIGHT',  button)

	local border = button:CreateTexture(nil, 'BORDER')
	border:SetTexture([=[Interface\AddOns\Scent\media\CaithNormal]=])
	border:SetPoint('TOPLEFT', button, -2, 2)
	border:SetPoint('BOTTOMRIGHT', button, 2, -2)
	border:SetVertexColor(0.25, 0.25, 0.25)

	button.overlay = button:CreateTexture(nil, 'ARTWORK')
	button.overlay:SetTexture([=[Interface\AddOns\Scent\media\CaithBorder]=])
	button.overlay:SetAllPoints(border)

	table.insert(self, button)

	return button
end

local function UpdateAura(self, index, filter)
	local name, rank, icon, count, dtype, _, expiration, owned = UnitAura('player', index, filter)
	local button = self[index]

	if(name) then
		if(not button) then button = CreateAura(self, index, filter) end

		button:Show()
		button:SetID(index)
		button.icon:SetTexture(icon)
		button.count:SetText(count > 1 and count)

		if(expiration and expiration > 0) then
			button.time:Show()
			button.expiration = expiration
			button:SetScript('OnUpdate', OnUpdate)
		else
			button.time:Hide()
		end

		if(filter == 'HARMFUL') then
			local color = DebuffTypeColor[dtype or 'none']
			button.overlay:SetVertexColor(color.r, color.g, color.b)
		else
			if(owned) then
				button.overlay:SetVertexColor(0, 0.75, 1)
			else
				button.overlay:SetVertexColor(0.25, 0.25, 0.25)
			end
		end

		return true
	elseif(button) then
		button:Hide()
	end
end

local function PositionAura(self, max)
	if(self and max > 0) then
		local num, col, row = 11, 0, 0

		for index = 1, max do
			local button = self[index]
			if(button and button:IsShown()) then
				if(col >= num) then
					col = 0
					row = row + 1
				end

				button:ClearAllPoints()
				button:SetPoint('TOPRIGHT', self, (col * 36 * -1), (row * 36 * -1))

				col = col + 1
			end
		end
	end
end

local function InitAura(self, filter)
	local max = (filter == 'HELPFUL') and 32 or 40
	local visible = 0
	for index = 1, max do
		if(not UpdateAura(self, index, filter)) then
			max = index - 1

			while(self[index]) do
				self[index]:Hide()
				index = index + 1
			end
			break
		end

		visible = visible + 1
	end

	PositionAura(self, max)
end

local function check(event, unit)
	if(event == 'UNIT_AURA' and unit ~= 'player') then return false end
	return true
end

local buff = CreateFrame('Frame', nil, UIParent)
buff:SetPoint('TOPRIGHT', UIParent, -185, -18)
buff:SetHeight(110)
buff:SetWidth(400)
buff:SetScript('OnEvent', function(self, ...) if(check(...)) then InitAura(self, 'HELPFUL') end end)
buff:RegisterEvent('UNIT_AURA')
buff:RegisterEvent('PLAYER_LOGIN')

local debuff = CreateFrame('Frame', nil, UIParent)
debuff:SetPoint('TOPRIGHT', buff, 'BOTTOMRIGHT', 0, -15)
debuff:SetHeight(150)
debuff:SetWidth(400)
debuff:SetScript('OnEvent', function(self, ...) if(check(...)) then InitAura(self, 'HARMFUL') end end)
debuff:RegisterEvent('UNIT_AURA')
debuff:RegisterEvent('PLAYER_LOGIN')

BuffFrame:Hide()
BuffFrame:UnregisterEvent("UNIT_AURA")
TicketStatusFrame:EnableMouse(false)