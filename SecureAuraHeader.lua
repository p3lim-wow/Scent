local sortingTable = {};
local groupingTable = {};

local function setAttributesWithoutResponse(self, ...)
	local oldIgnore = self:GetAttribute("_ignore");
	self:SetAttribute("_ignore", "attributeChanges");
	for i = 1, select('#', ...), 2 do
		self:SetAttribute(select(i, ...));
	end
	self:SetAttribute("_ignore", oldIgnore);
end

local function SetupAuraButtonConfiguration( header, newChild, defaultConfigFunction )
	local configCode = newChild:GetAttribute("initialConfigFunction") or header:GetAttribute("initialConfigFunction") or defaultConfigFunction;

	if ( type(configCode) == "string" ) then
		local selfHandle = GetFrameHandle(newChild);
		if ( selfHandle ) then
			CallRestrictedClosure("self", GetManagedEnvironment(header, true),
			                      selfHandle, configCode, selfHandle);
		end
	end
end

function SecureAuraHeader_OnLoad(self)
	self:RegisterEvent("UNIT_AURA");
end

function SecureAuraHeader_OnUpdate(self)
	local hasMainHandEnchant, hasOffHandEnchant, _;
	hasMainHandEnchant, _, _, hasOffHandEnchant, _, _ = GetWeaponEnchantInfo();
	if ( hasMainHandEnchant ~= self:GetAttribute("_mainEnchanted") ) then
		self:SetAttribute("_mainEnchanted", hasMainHandEnchant);
	end
	if ( hasOffHandEnchant ~= self:GetAttribute("_secondaryEnchanted") ) then
		self:SetAttribute("_secondaryEnchanted", hasOffHandEnchant);
	end
end

function SecureAuraHeader_OnEvent(self, event, ...)
	if ( self:IsVisible() ) then
		local unit = SecureButton_GetUnit(self);
		if ( event == "UNIT_AURA" and ... == unit ) then
			SecureAuraHeader_Update(self);
		end
	end
end

function SecureAuraHeader_OnAttributeChanged(self, name, value)
	if ( name == "_ignore" or self:GetAttribute("_ignore") ) then
		return;
	end
	if ( self:IsVisible() ) then
		SecureAuraHeader_Update(self);
	end
end

local buttons = {};

local function extractTemplateInfo(template, defaultWidget)
	local widgetType;

	if ( template ) then
		template, widgetType = strsplit(",", (tostring(template):trim():gsub("%s*,%s*", ",")) );
		if ( template ~= "" ) then
			if ( not widgetType or widgetType == "" ) then
				widgetType = defaultWidget;
			end
			return template, widgetType;
		end
	end
	return nil;
end

local function constructChild(kind, name, parent, template)
	local new = CreateFrame(kind, name, parent, template);
	SetupAuraButtonConfiguration(parent, new);
	return new;
end

local enchantableSlots = {
	[1] = "MainHandSlot", 
	[2] = "SecondaryHandSlot", 
	[3] = "RangedSlot",
}

local function configureAuras(self, auraTable, consolidateTable, weaponPosition)
	local point = self:GetAttribute("point") or "TOPRIGHT";
	local xOffset = tonumber(self:GetAttribute("xOffset")) or 0;
	local yOffset = tonumber(self:GetAttribute("yOffset")) or 0;
	local wrapXOffset = tonumber(self:GetAttribute("wrapXOffset")) or 0;
	local wrapYOffset = tonumber(self:GetAttribute("wrapYOffset")) or 0;
	local wrapAfter = tonumber(self:GetAttribute("wrapAfter"));
	if ( wrapAfter == 0 ) then wrapAfter = nil; end
	local maxWraps = self:GetAttribute("maxWraps");
	if ( maxWraps == 0 ) then maxWraps = nil; end
	local minWidth = tonumber(self:GetAttribute("minWidth")) or 0;
	local minHeight = tonumber(self:GetAttribute("minHeight")) or 0;

	if ( consolidateTable and #consolidateTable == 0 ) then
		consolidateTable = nil;
	end
	local name = self:GetName();

	wipe(buttons);
	local buffTemplate, buffWidget = extractTemplateInfo(self:GetAttribute("template"), "Button");
	if ( buffTemplate ) then
		for i=1, #auraTable do
			local childAttr = "child"..i;
			local button = self:GetAttribute("child"..i);
			if ( button ) then
				button:ClearAllPoints();
			else
				button = constructChild(buffWidget, name and name.."AuraButton"..i, self, buffTemplate);
				setAttributesWithoutResponse(self, childAttr, button, "frameref-"..childAttr, GetFrameHandle(button)); 
			end
			local buffInfo = auraTable[i];
			button:SetID(buffInfo.index);
			button:SetAttribute("index", buffInfo.index);
			button:SetAttribute("filter", buffInfo.filter);
			buttons[i] = button;
		end
	end

	local deadIndex = #buttons + 1;
	local button = self:GetAttribute("child"..deadIndex);
	while ( button ) do
		button:Hide();
		deadIndex = deadIndex + 1;
		button = self:GetAttribute("child"..deadIndex)
	end

	local consolidateProxy = self:GetAttribute("consolidateProxy");
	if ( consolidateTable ) then
		if ( type(consolidateProxy) == 'string' ) then
			local template, widgetType = extractTemplateInfo(consolidateProxy, "Button");
			if ( template ) then
				consolidateProxy = constructChild(widgetType, name and name.."ProxyButton", self, template);
				setAttributesWithoutResponse(self, "consolidateProxy", consolidateProxy, "frameref-proxy", GetFrameHandle(consolidateProxy));
			else
				consolidateProxy = nil;
			end
		end
		if ( consolidateProxy ) then
			if ( consolidateTable.position ) then
				tinsert(buttons, consolidateTable.position, consolidateProxy);
			else
				tinsert(buttons, consolidateProxy);
			end
			consolidateProxy:ClearAllPoints();
		end
	else
		if ( consolidateProxy and type(consolidateProxy.Hide) == 'function' ) then
			consolidateProxy:Hide();
		end
	end
	if ( weaponPosition ) then
		local hasMainHandEnchant, hasOffHandEnchant, hasRangedEnchant, _;
		hasMainHandEnchant, _, _, hasOffHandEnchant, _, _, hasRangedEnchant, _, _ = GetWeaponEnchantInfo();

		for weapon=3,1,-1 do
			local weaponAttr = "tempEnchant"..weapon
			local tempEnchant = self:GetAttribute(weaponAttr)
			if ( (select(weapon, hasMainHandEnchant, hasOffHandEnchant, hasRangedEnchant)) ) then
				if ( not tempEnchant ) then
					local template, widgetType = extractTemplateInfo(self:GetAttribute("weaponTemplate"), "Button");
					if ( template ) then
						tempEnchant = constructChild(widgetType, name and name.."TempEnchant"..weapon, self, template);
						setAttributesWithoutResponse(self, weaponAttr, tempEnchant);
					end
				end
				if ( tempEnchant ) then
					tempEnchant:ClearAllPoints();
					local slot = GetInventorySlotInfo(enchantableSlots[weapon]);
					tempEnchant:SetAttribute("target-slot", slot);
					tempEnchant:SetID(slot);
					if ( weaponPosition == 0 ) then
						tinsert(buttons, tempEnchant);
					else
						tinsert(buttons, weaponPosition, tempEnchant);
					end
				end
			else
				if ( tempEnchant and type(tempEnchant.Hide) == 'function' ) then
					tempEnchant:Hide();
				end
			end
		end
	end

	local display = #buttons
	if ( wrapAfter and maxWraps ) then
		display = min(display, wrapAfter * maxWraps);
	end

	local left, right, top, bottom = math.huge, -math.huge, -math.huge, math.huge;
	for index=1,display do
		local button = buttons[index];
		local wrapAfter = wrapAfter or index
		local tick, cycle = floor((index - 1) % wrapAfter), floor((index - 1) / wrapAfter);
		button:SetPoint(point, self, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset);
		button:Show();
		left = min(left, button:GetLeft() or math.huge);
		right = max(right, button:GetRight() or -math.huge);
		top = max(top, button:GetTop() or -math.huge);
		bottom = min(bottom, button:GetBottom() or math.huge);
	end
	
	if ( display >= 1 ) then
		self:SetWidth(max(right - left, minWidth));
		self:SetHeight(max(top - bottom, minHeight));
	else
		self:SetWidth(minWidth);
		self:SetHeight(minHeight);
	end
	if ( consolidateTable ) then
		local header = self:GetAttribute("consolidateHeader");
		if ( type(header) == 'string' ) then
			local template, widgetType = extractTemplateInfo(header, "Frame");
			if ( template ) then
				header = constructChild(widgetType, name and name.."ProxyHeader", consolidateProxy, template);
				setAttributesWithoutResponse(self, "consolidateHeader", header);
				consolidateProxy:SetAttribute("header", header);
				consolidateProxy:SetAttribute("frameref-header", GetFrameHandle(header))
			end
		end
		if ( header ) then
			configureAuras(header, consolidateTable);
		end
	end
end

local tremove = table.remove;

local function stripRAID(filter)
	return filter and tostring(filter):upper():gsub("RAID", ""):gsub("|+", "|"):match("^|?(.+[^|])|?$");
end

local freshTable;
local releaseTable;
do
	local tableReserve = {};
	freshTable = function ()
		local t = next(tableReserve) or {};
		tableReserve[t] = nil;
		return t;
	end
	releaseTable = function (t)
		tableReserve[t] = wipe(t);
	end
end

local sorters = {};

local function sortFactory(key, separateOwn, reverse)
	if ( separateOwn ~= 0 ) then
		if ( reverse ) then
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					if ( ownA ~= ownB ) then
						return ownA == (separateOwn > 0)
					end
					return a[key] > b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		else
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					if ( ownA ~= ownB ) then
						return ownA == (separateOwn > 0)
					end
					return a[key] < b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		end
	else
		if ( reverse ) then
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					return a[key] > b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		else
			return function (a, b)
				if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
					return a[key] < b[key];
				else
					return groupingTable[a.filter] < groupingTable[b.filter];
				end
			end;
		end
	end
end

for i, key in ipairs{"index", "name", "expires"} do
	local label = key:upper();
	sorters[label] = {};
	for bool in pairs{[true] = true, [false] = false} do
		sorters[label][bool] = {}
		for sep=-1,1 do
			sorters[label][bool][sep] = sortFactory(key, sep, bool);
		end
	end
end
sorters.TIME = sorters.EXPIRES;

function SecureAuraHeader_Update(self)
	local filter = self:GetAttribute("filter");
	local groupBy = self:GetAttribute("groupBy");
	local unit = SecureButton_GetUnit(self) or "player";
	local includeWeapons = tonumber(self:GetAttribute("includeWeapons"));
	if ( includeWeapons == 0 ) then
		includeWeapons = nil
	end
	local consolidateTo = tonumber(self:GetAttribute("consolidateTo"));
	local consolidateDuration, consolidateThreshold, consolidateFraction;
	if ( consolidateTo ) then
		consolidateDuration = tonumber(self:GetAttribute("consolidateDuration")) or 30;
		consolidateThreshold = tonumber(self:GetAttribute("consolidateThreshold")) or 10;
		consolidateFraction = tonumber(self:GetAttribute("consolidateFraction")) or 0.1;
	end
	local sortDirection = self:GetAttribute("sortDirection");
	local separateOwn = tonumber(self:GetAttribute("separateOwn")) or 0;
	if ( separateOwn > 0 ) then
		separateOwn = 1;
	elseif (separateOwn < 0 ) then
		separateOwn = -1;
	end
	local sortMethod = (sorters[tostring(self:GetAttribute("sortMethod")):upper()] or sorters["INDEX"])[sortDirection == "-"][separateOwn];

	local time = GetTime();

	local consolidateTable;
	if ( consolidateTo and consolidateTo ~= 0 ) then
		consolidateTable = wipe(tokenTable);
	end

	wipe(sortingTable);
	wipe(groupingTable);

	if ( groupBy ) then
		local i = 1;
		for subFilter in groupBy:gmatch("[^,]+") do
			if ( filter ) then
				subFilter = stripRAID(filter.."|"..subFilter);
			else
				subFilter = stripRAID(subFilter);
			end
			groupingTable[subFilter], groupingTable[i] = i, subFilter;
			i = i + 1;
		end
	else
		filter = stripRAID(filter);
		groupingTable[filter], groupingTable[1] = 1, filter;
	end
	if ( consolidateTable and consolidateTo < 0 ) then
		consolidateTo = #groupingTable + consolidateTo + 1;
	end
	if ( includeWeapons and includeWeapons < 0 ) then
		includeWeapons = #groupingTable + includeWeapons + 1;
	end
	local weaponPosition;
	for filterIndex, fullFilter in ipairs(groupingTable) do
		if ( consolidateTable and not consolidateTable.position and filterIndex >= consolidateTo ) then
			consolidateTable.position = #sortingTable + 1;
		end
		if ( includeWeapons and not weaponPosition and filterIndex >= includeWeapons ) then
			weaponPosition = #sortingTable + 1;
		end

		local i = 1;
		repeat
			local aura, _, duration = freshTable();
			aura.name, _, _, _, _, duration, aura.expires, aura.caster, _, aura.shouldConsolidate, _ = UnitAura(unit, i, fullFilter);
			if ( aura.name ) then
				aura.filter = fullFilter;
				aura.index = i;
				local targetList = sortingTable;
				if ( consolidateTable and aura.shouldConsolidate ) then
					if ( not aura.expires or duration > consolidateDuration or (aura.expires - time >= max(consolidateThreshold, duration * consolidateFraction)) ) then
						targetList = consolidateTable;
					end
				end
				tinsert(targetList, aura);
			else
				releaseTable(aura);
			end
			i = i + 1;
		until ( not aura.name );
	end
	if ( includeWeapons and not weaponPosition ) then
		weaponPosition = 0;
	end
	table.sort(sortingTable, sortMethod);
	if ( consolidateTable ) then
		table.sort(consolidateTable, sortMethod);
	end

	configureAuras(self, sortingTable, consolidateTable, weaponPosition);
	while ( sortingTable[1] ) do
		releaseTable(tremove(sortingTable));
	end
	while ( consolidateTable and consolidateTable[1] ) do
		releaseTable(tremove(consolidateTable));
	end
end