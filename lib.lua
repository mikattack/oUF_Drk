------------------------------------------------------------------------------
--| oUF_Drk
--| Drakull 2010
--| Updated by myno, Kellen
------------------------------------------------------------------------------

-----------------------
-- Initialize
-----------------------

local addon, ns = ...
local cfg = ns.cfg
local cast = ns.cast
local lib = CreateFrame("Frame")  
local _, playerClass = UnitClass("player")
oUF.colors.runes = {
  {0.87, 0.12, 0.23};
  {0.40, 0.95, 0.20};
  {0.14, 0.50, 1};
  {.70, .21, 0.94};
}

-----------------------
-- Functions
-----------------------

-- Returns val1, val2 or val3 depending on frame
-- 
--   1: Player, Target
--   2: Everything Else
--   3: Raid
local retVal = function(f, val1, val2, val3)
	if f.mystyle == "player" or f.mystyle == "target" then
		return val1
	elseif f.mystyle == "raid" then
		return val3
	else
		return val2
	end
end


-- Add background and border to a frame
lib.addBackground = function(f)
  local bg = CreateFrame("Frame", nil, f)
  bg:SetPoint("TOPLEFT", f, "TOPLEFT", -4, 4)
  bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -4)

	bg:SetBackdrop({
		bgFile = cfg.backdrop_texture, 
		edgeFile = cfg.frame_edge_texture,
		tile = false,
		tileSize = 0, 
		edgeSize = 10, 
		insets = { 
			left   = 3,
			right  = 3,
			top    = 3,
      bottom = 3,
		}
	});
	bg:SetBackdropColor(0,0,0,1)
	bg:SetBackdropBorderColor(0,0,0,0.4)
  f.bg = bg
end


-- Right Click Menu
lib.spawnMenu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("^%l", string.upper)

	if(cunit == 'Vehicle') then
		cunit = 'Pet'
	end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end


-- Create Font Function
lib.genFontstring = function(f, name, size, outline)
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(name, size, outline)
	fs:SetShadowColor(0,0,0,0.8)
	fs:SetShadowOffset(1,-1)
	return fs
end


-- Create Health Bar Function
lib.addHealthBar = function(f)
	-- Statusbar
	local s = CreateFrame("StatusBar", nil, f)
	--s:SetFrameLevel(1)
	if f.mystyle=="boss" then
		s:SetHeight(30)
		s:SetWidth(f:GetWidth())
		s:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
		s:SetStatusBarTexture(cfg.statusbar_texture)
	else
		--s:SetHeight(retVal(f, f:GetHeight() - 5, f:GetHeight() - 5, 29))
    s:SetHeight(f:GetHeight() - 5)
		s:SetWidth(f:GetWidth())
		s:SetPoint("TOP",0,0)
		if f.mystyle=="raid" then
			s:SetStatusBarColor(.12,.12,.12,1)
			s:SetStatusBarTexture(cfg.raid_texture)
		else
			s:SetStatusBarTexture(cfg.statusbar_texture)
		end
	end
	s:GetStatusBarTexture():SetHorizTile(true)

	-- Helper
	local h = CreateFrame("Frame", nil, s)
	--h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle == "boss" then
		h:SetPoint("BOTTOMRIGHT",4,-4)
	elseif f.mystyle == "raid" then
		h:SetPoint("TOPLEFT",f,"TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT", 3.8, -4)
	else
		h:SetPoint("BOTTOMRIGHT", 4, -10*cfg.unitframeScale)
	end
	--lib.createBackdrop(h,0)

	-- Background
	local b = s:CreateTexture(nil, "BACKGROUND")
	b:SetTexture(cfg.statusbar_texture)
	b:SetAllPoints(s)
	f.Health = s
	f.Health.bg = b
end


-- Adds Health, Power, Name, and other strings to a bar
lib.addStrings = function(f)
	local name, hpval, powerval, altppval
	if f.mystyle == "boss" then
    -- Bosses
		name = lib.genFontstring(f.Health, cfg.font, 14, "NONE")
		name:SetPoint("LEFT", f.Health, "LEFT", 3, 0)
		name:SetJustifyH("LEFT")
		hpval = lib.genFontstring(f.Health, cfg.font, 14, "NONE")
		hpval:SetPoint("RIGHT", f.Health, "RIGHT", -3, 0)
		altppval = lib.genFontstring(f.Health, cfg.font, 12, "THINOUTLINE")
		altppval:SetPoint("RIGHT", f.Health, "BOTTOMRIGHT", -3, -22)

		f:Tag(name,"[name]")
		f:Tag(hpval,"[drk:hp]")
  elseif f.mystyle == "pet" then
    -- Pets have no strings in this layout.  If you're savvy enough for an
    -- oUF layout, we trust you know who your pet is.
    return;
	else
    -- Name Text
		name = lib.genFontstring(f.Health, retVal(f,cfg.font,cfg.font,cfg.raidfont), retVal(f,16,16,12), retVal(f,"OUTLINE","OUTLINE","NONE"))
		name:SetPoint(retVal(f,"LEFT","LEFT","TOPLEFT"), f.Health, retVal(f,"LEFT","LEFT","TOPLEFT"), retVal(f,3,3,1), retVal(f,0,0,-1))
		name:SetJustifyH("LEFT")
		name.frequentUpdates = true

    -- Health Text
    if f.mystyle == "player" then
      hpval = lib.genFontstring(f.Health, cfg.font, retVal(f,28), "OUTLINE")
      hpval:SetPoint("LEFT", f.Health, "LEFT", 3, 3)
      hpval.frequentUpdates = true
      rawval = lib.genFontstring(f.Health, cfg.font, 16, "OUTLINE")
      rawval:SetPoint("BOTTOMLEFT", hpval, "BOTTOMRIGHT", 0, 3)
      rawval.frequentUpdates = true
    else
      hpval = lib.genFontstring(f.Health, cfg.font, retVal(f,16,16,14), "OUTLINE")
      hpval:SetPoint(retVal(f,"RIGHT","RIGHT","BOTTOMLEFT"), f.Health, retVal(f,"RIGHT","RIGHT","BOTTOMLEFT"), retVal(f,-1,-1,1), retVal(f,0,0,1))
      hpval.frequentUpdates = true
    end

    -- Set Name and Power Tags
		if f.mystyle == "raid" then
			name:SetPoint("RIGHT", f, "RIGHT", -1, 0)
			f:Tag(name, "[drk:color][name][drk:raidafkdnd]")
		else
			name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
			if f.mystyle == "player" then
        powerval = lib.genFontstring(f.Health, cfg.font, 14, "OUTLINE")
        powerval:SetPoint("RIGHT", f.Health, "RIGHT", -2, 1)
        f:Tag(powerval, "[drk:power]")
			elseif f.mystyle == "target" then
				f:Tag(name, "[drk:level] [drk:color][name][drk:afkdnd]")
			else
				f:Tag(name, "[drk:color][name]")
			end
		end

    -- Set Health Tags
    if f.mystyle == "player" then
      f:Tag(hpval, "[drk:perhp]")
      f:Tag(rawval, "[drk:rhp]")
    elseif f.mystyle == "tot" then
      f:Tag(hpval, "[drk:perhp]")
    else
      f:Tag(hpval, retVal(f,"[drk:hp]","[drk:hp]","[drk:raidhp]"))
    end
	end
end


-- Add Power bar
lib.addPowerBar = function(f)
	-- Statusbar
	local s = CreateFrame("StatusBar", nil, f)
  s:SetStatusBarTexture(cfg.powerbar_texture)
	s:GetStatusBarTexture():SetHorizTile(true)
	--s:SetFrameLevel(1)
	if f.mystyle=="boss" then		
		s:SetHeight(4)
    s:SetWidth(250)
		s:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
		s:SetStatusBarColor(165/255, 73/255, 23/255, 1)
	else
		s:SetHeight(4)
		s:SetWidth(f:GetWidth())
    s:SetPoint("BOTTOM",f,"BOTTOM",0,0)
	end
	s.frequentUpdates = true
  
  -- Helper
  --[[
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle=="boss" then
		local h = CreateFrame("Frame", nil, s)
		--h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		--lib.createBackdrop(h,0)
	end
  --]]

  -- Background
  local b = s:CreateTexture(nil, "BACKGROUND")
  b:SetTexture(cfg.powerbar_texture)
  b:SetAllPoints(s)
  f.Power = s
  f.Power.bg = b
end


-- Create Icons (Combat, PvP, Resting, LFDRole, Leader, Assist, Master Looter, Phase, Quest, Raid Mark, Ressurect)
lib.addInfoIcons = function(f)
  local h = CreateFrame("Frame",nil,f)
  h:SetAllPoints(f)
  --h:SetFrameLevel(10)

  --Combat Icon
	if f.mystyle=="player" then
		f.Combat = h:CreateTexture(nil, 'OVERLAY')
		f.Combat:SetSize(15,15)
		f.Combat:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		f.Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)
		f.Combat:SetPoint('BOTTOMRIGHT', 7, -7)
	elseif f.mystyle == "target" then
    local combat = CreateFrame("Frame", nil, h)
    combat:SetSize(15, 15)
    combat:SetPoint("BOTTOMRIGHT", 7, -7)
    f.CombatIcon = combat

    local combaticon = combat:CreateTexture(nil, "ARTWORK")
    combaticon:SetAllPoints(true)
    combaticon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    combaticon:SetTexCoord(0.58, 0.9, 0.08, 0.41)
    combat.icon = combaticon

    combat.__owner = f
    combat:SetScript("OnUpdate", function(self)
        local unit = self.__owner.unit
        if unit and UnitAffectingCombat(unit) then
            self.icon:Show()
        else
            self.icon:Hide()
        end
    end)
    end

	-- PvP Icon
	f.PvP = h:CreateTexture(nil, "OVERLAY")
	local faction = PvPCheck
	if faction == "Horde" then
		f.PvP:SetTexCoord(0.08, 0.58, 0.045, 0.545)
	elseif faction == "Alliance" then
		f.PvP:SetTexCoord(0.07, 0.58, 0.06, 0.57)
	else
		f.PvP:SetTexCoord(0.05, 0.605, 0.015, 0.57)
	end
	if f.mystyle == 'player' then
		f.PvP:SetHeight(14)
		f.PvP:SetWidth(14)
		f.PvP:SetPoint("TOPRIGHT", 7, 7)
	elseif f.mystyle == 'target' then
		f.PvP:SetHeight(14)
		f.PvP:SetWidth(14)
		f.PvP:SetPoint("TOPRIGHT", 7, 7)
	end

	-- Rest Icon
    if f.mystyle == 'player' then
		f.Resting = h:CreateTexture(nil, 'OVERLAY')
		f.Resting:SetSize(15,15)
		f.Resting:SetPoint('BOTTOMRIGHT', -12, -8)
		f.Resting:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		f.Resting:SetTexCoord(0.09, 0.43, 0.08, 0.42)
	end

    --LFDRole icon
	if f.mystyle == 'player' or f.mystyle == 'target' then
		f.LFDRole = h:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(15,15)
		f.LFDRole:SetAlpha(0.9)
		f.LFDRole:SetPoint('BOTTOMLEFT', -6, -8)
  elseif cfg.showRoleIcons and f.mystyle == 'raid' then 
		f.LFDRole = h:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(12,12)
		f.LFDRole:SetPoint('CENTER', f, 'RIGHT', 1, 0)
		f.LFDRole:SetAlpha(0)
  end

	-- Leader, Assist, Master Looter Icon
	if f.mystyle ~= 'raid' then
		li = h:CreateTexture(nil, "OVERLAY")
		li:SetPoint("TOPLEFT", f, 0, 8)
		li:SetSize(12,12)
		f.Leader = li
		ai = h:CreateTexture(nil, "OVERLAY")
		ai:SetPoint("TOPLEFT", f, 0, 8)
		ai:SetSize(12,12)
		f.Assistant = ai
		local ml = h:CreateTexture(nil, 'OVERLAY')
		ml:SetSize(10,10)
		ml:SetPoint('LEFT', f.Leader, 'RIGHT')
		f.MasterLooter = ml
	end

	-- Phase Icon
	if f.mystyle == 'target' then
		picon = h:CreateTexture(nil, 'OVERLAY')
		picon:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 8, 8)
		picon:SetSize(16, 16)
		f.PhaseIcon = picon
	end

	-- Quest Icon
	--[[
	if f.mystyle == 'target' then
		qicon = self.Health:CreateTexture(nil, 'OVERLAY')
		qicon:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 8)
		qicon:SetSize(16, 16)
		f.QuestIcon = qicon
	end
	]]

	-- Raid Marks
	ri = h:CreateTexture(nil,'OVERLAY')
	if f.mystyle == 'player' or f.mystyle == 'target' or f.mystyle == 'focus' then
		ri:SetPoint("RIGHT", f, "LEFT", 5, 0)
	elseif f.mystyle == 'raid' then	
		ri:SetPoint("CENTER", f, "TOP",0,0)
	else
		ri:SetPoint("LEFT", f, "LEFT", 5, 0)
	end
	local size = retVal(f, 20, 18, 12)
	ri:SetSize(size, size)
	f.RaidIcon = ri

	-- Ressurect Icon
	if f.mystyle == 'raid' then
		rezicon = h:CreateTexture(nil,'OVERLAY')
		rezicon:SetPoint('CENTER',f,'CENTER',0,-3)
		rezicon:SetSize(16,16)
		f.ResurrectIcon = rezicon
	end

	-- Ready Check Icon
	if f.mystyle == 'raid' then
		rc = f.Health:CreateTexture(nil, "OVERLAY")
		rc:SetSize(14, 14)
		rc:SetPoint("BOTTOMLEFT", f.Health, "TOPRIGHT", -13, -12)
		f.ReadyCheck = rc
	end
end


-- Create Target Border
function lib.CreateTargetBorder(self)
	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	self.TargetBorder = CreateFrame("Frame", nil, self)
	self.TargetBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -2.5)
	self.TargetBorder:SetBackdrop(glowBorder)
	--self.TargetBorder:SetFrameLevel(5)
	self.TargetBorder:SetBackdropBorderColor(.7,.7,.7,.8)
	self.TargetBorder:Hide()
end

-- Raid Frames Target Highlight Border
function lib.ChangedTarget(self, event, unit)
	if UnitIsUnit('target', self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end


-- Create Raid Threat Status Border
--function lib.CreateThreatBorder(self)
--	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 2}
--	self.Thtborder = CreateFrame("Frame", nil, self)
--	self.Thtborder:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 2)
--	self.Thtborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
--	self.Thtborder:SetBackdrop(glowBorder)
--	self.Thtborder:SetFrameLevel(4)
--	self.Thtborder:Hide()	
--end
 
-- Raid Frames Threat Highlight
--function lib.UpdateThreat(self, event, unit)
--	if (self.unit ~= unit) then return end
--	
--	local status = UnitThreatSituation(unit)
--	unit = unit or self.unit
--	if status and status > 1 then
--		local r, g, b = GetThreatStatusColor(status)
--		self.Thtborder:Show()
--		self.Thtborder:SetBackdropBorderColor(r, g, b, 1)
--	else
--		self.Thtborder:SetBackdropBorderColor(r, g, b, 0)
--		self.Thtborder:Hide()
--	end
--end
	
  
-- Add Castbar
lib.addCastBar = function(f)
	if not cfg.Castbars then return end

  local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..f.mystyle, f)
  s:SetHeight(cfg.castBarHeight)
  s:SetWidth(cfg.castBarWidth)  

	if f.mystyle == "player" then
		s:SetPoint("BOTTOM",UIParent,"BOTTOM", cfg.playerCastBarX, cfg.playerCastBarY)
  elseif f.mystyle == "target" then
		s:SetPoint("BOTTOM",UIParent,"BOTTOM", cfg.targetCastBarX, cfg.targetCastBarY)
  end

  s:SetStatusBarTexture(cfg.statusbar_texture)
  s:SetStatusBarColor(.5, .5, 1,1)
  --s:SetFrameLevel(9)
  
  -- Color
  s.CastingColor = {.5, .5, 1}
  s.CompleteColor = {0.5, 1, 0}
  s.FailColor = {1.0, 0.05, 0}
  s.ChannelingColor = {.5, .5, 1}
  
  -- Helper
  --[[
  local h = CreateFrame("Frame", nil, s)
 -- h:SetFrameLevel(0)
  h:SetPoint("TOPLEFT",-4,4)
  h:SetPoint("BOTTOMRIGHT",4,-4)
  --lib.createBackdrop(h,0)
  --]]

  -- Backdrop
  if f.mystyle~="player" or f.mystyle~="target" then
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
    b:SetVertexColor(.5*0.2,.5*0.2,1*0.2,0.7)
	end

  --spark
  sp = s:CreateTexture(nil, "OVERLAY")
  sp:SetBlendMode("ADD")
  sp:SetAlpha(0.5)
  sp:SetHeight(s:GetHeight()*2.5)
  
  --spell text
  local txt = lib.genFontstring(s, cfg.font, 12, "NONE")
  txt:SetPoint("LEFT", 4, 0)
  txt:SetJustifyH("LEFT")
  
  --time
  local t = lib.genFontstring(s, cfg.font, 12, "NONE")
  t:SetPoint("RIGHT", -2, 0)
  txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
  
  --icon
  local i = s:CreateTexture(nil, "ARTWORK")

	if (f.mystyle=='player' or f.mystyle=='target') then
		i:SetPoint("RIGHT",s,"LEFT",-5,0)
		i:SetSize(s:GetHeight()-1,s:GetHeight()-1)
	else
		i:SetPoint("RIGHT",s,"LEFT",-4,0)
		i:SetSize(s:GetHeight(),s:GetHeight())
	end
  i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    
  --[[
  --helper2 for icon
  local h2 = CreateFrame("Frame", nil, s)
  --h2:SetFrameLevel(0)
  h2:SetPoint("TOPLEFT",i,"TOPLEFT",-4,4)
  h2:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",4,-4)
  --lib.createBackdrop(h2,0)
  --]]

  if f.mystyle == "player" then
		--latency only for player unit
		local z = s:CreateTexture(nil,"OVERLAY")
		z:SetTexture(cfg.statusbar_texture)
		z:SetVertexColor(1,0,0,.6)
		z:SetPoint("TOPRIGHT")
		z:SetPoint("BOTTOMRIGHT")
		--s:SetFrameLevel(10)
		s.SafeZone = z

		--custom latency display
		local l = lib.genFontstring(s, cfg.font, 10, "THINOUTLINE")
		l:SetPoint("CENTER", -2, 17)
		l:SetJustifyH("RIGHT")
		l:Hide()
		s.Lag = l
		f:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)
  end

  s.OnUpdate = cast.OnCastbarUpdate
  s.PostCastStart = cast.PostCastStart
  s.PostChannelStart = cast.PostCastStart
  s.PostCastStop = cast.PostCastStop
  s.PostChannelStop = cast.PostChannelStop
  s.PostCastFailed = cast.PostCastFailed
  s.PostCastInterrupted = cast.PostCastFailed

  --lib.addBackground(s)

  f.Castbar = s
  f.Castbar.Text = txt
  f.Castbar.Time = t
  f.Castbar.Icon = i
  f.Castbar.Spark = sp
end


-- Mirror Bar
-- NOTE:  The bars are just styled, not repositioned
lib.addMirrorCastBar = function(f)
	for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do   
		--for i, region in pairs({_G[bar]:GetRegions()}) do
		--	if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
		--	  region:Hide()
		--	end
		--end
		_G[bar..'Border']:Hide()
		_G[bar]:SetParent(UIParent)
		_G[bar]:SetScale(1)
		_G[bar]:SetHeight(16)
		_G[bar]:SetWidth(280)
		_G[bar]:SetBackdropColor(.1,.1,.1)
		_G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
		_G[bar..'Background']:SetTexture(cfg.statusbar_texture)
		_G[bar..'Background']:SetAllPoints(bar)
		_G[bar..'Background']:SetVertexColor(.15,.15,.15,.75)
		_G[bar..'Text']:SetFont(cfg.font, 14)
		_G[bar..'Text']:ClearAllPoints()
		_G[bar..'Text']:SetPoint('CENTER', MirrorTimer1StatusBar, 0, 1)
		_G[bar..'StatusBar']:SetAllPoints(_G[bar])
		
		-- Borders
		local h = CreateFrame("Frame", nil, _G[bar])
		--h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-5,5)
		h:SetPoint("BOTTOMRIGHT",5,-5)
		--lib.createBackdrop(h,0)
	end
end
  
  
-- Post Create Icon
local myPostCreateIcon = function(self, button)
	self.showDebuffType = true
	self.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.icon:SetTexCoord(.04, .96, .04, .96)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0,1,0,1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
	
	
	button.time = lib.genFontstring(button, cfg.smallfont, 8, "OUTLINE")
	button.time:SetPoint("BOTTOMLEFT", button, -2, -2)
	button.time:SetJustifyH('CENTER')
	button.time:SetVertexColor(1,1,1)
	
	button.count = lib.genFontstring(button, cfg.smallfont, 8, "OUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button, 2, 2)
	button.count:SetVertexColor(1,1,1)	
		
	-- Helper
	local h = CreateFrame("Frame", nil, button)
	--h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	--lib.createBackdrop(h,0)
end


-- Post Update Icon
local myPostUpdateIcon = function(self, unit, icon, index, offset, filter, isDebuff)
	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
	
	if duration and duration > 0 then
		icon.time:Show()
		icon.timeLeft = expirationTime	
		icon:SetScript("OnUpdate", CreateBuffTimer)			
	else
		icon.time:Hide()
		icon.timeLeft = math.huge
		icon:SetScript("OnUpdate", nil)
	end
		
	-- Desaturate non-Player Debuffs
	if unit == "target" and icon.filter == "HARMFUL" then
		if (unitCaster == 'player' or unitCaster == 'vehicle') then
			icon.icon:SetDesaturated(nil)
		elseif not UnitPlayerControlled(unit) then -- If Unit is Player Controlled don't desaturate debuffs
			icon:SetBackdropColor(0, 0, 0)
			icon.overlay:SetVertexColor(0.3, 0.3, 0.3)
			icon.icon:SetDesaturated(1)
		end
	end
	
	-- Right Click Cancel Buff/Debuff
	icon:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
		end
	end)
	
	icon.first = true
end


local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end


-- Create Buff/Debuff Timer Function 
function CreateBuffTimer(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0.5, 0.5)
				else
					self.time:SetTextColor(.7, .7, .7)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end


lib.addBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
    b.num = 20
    b.spacing = 5
    b.onlyShowPlayer = false
    b:SetHeight(b.size*2)
    b:SetWidth(f:GetWidth())
	if f.mystyle == "player" then
		b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", -5, -1)
		b.initialAnchor = "TOPRIGHT"
		b["growth-x"] = "LEFT"
		b["growth-y"] = "DOWN"
	else
		b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 5)
		b.initialAnchor = "BOTTOMLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "UP"
	end
	b.PostCreateIcon = myPostCreateIcon
  b.PostUpdateIcon = myPostUpdateIcon

  f.Buffs = b
end


lib.addDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 10
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	
	b:SetPoint("BOTTOMLEFT", f.Power, "TOpLEFT", 0, 5)
    b.initialAnchor = "TOPLEFT"
    b["growth-x"] = "RIGHT"
    b["growth-y"] = "UP"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
	--b:SetFrameLevel(1)
	
    f.Debuffs = b
end


lib.addFocusAuras = function(f)
  b = CreateFrame("Frame", nil, f)
  b.size = 20
	b.num = 5
	b.onlyShowPlayer = false
  b.spacing = 5
  b:SetHeight(b.size)
  b:SetWidth(f:GetWidth())
	b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 3)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "UP"
  b.PostCreateIcon = myPostCreateIcon
  b.PostUpdateIcon = myPostUpdateIcon
	if (cfg.focusBuffs) then f.Buffs = b end
	if (cfg.focusDebuffs and not cfg.focusBuffs) then f.Debuffs = b end
end


lib.addBossBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 4
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Buffs = b
end


lib.addBossDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 4
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("BOTTOMLEFT", f, "BOTTOMRIGHT", 5, 1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Debuffs = b
end


--[[lib.addRaidDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 12
	b.num = 3
	b.onlyShowPlayer = false
    b.spacing = 3
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 3, 3)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Debuffs = b
end
]]


-- Raid PostUpdate
lib.PostUpdateRaidFrame = function(Health, unit, min, max)
	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local inrange = UnitInRange(unit)
	
	Health:SetStatusBarColor(.12,.12,.12,1)
	Health:SetAlpha(1)
	Health:SetValue(min)
	
	if dc or dead or ghost then
		if dc then
			Health:SetAlpha(.225)
		elseif ghost then
			--Health:SetStatusBarColor(.03,.03,.03,1)
			Health:SetValue(0)
		elseif dead then
			--Health:SetStatusBarColor(.03,.03,.03,1)
			Health:SetValue(0)
		end
	else
		Health:SetValue(min)
		if(unit == 'vehicle') then
			Health:SetStatusBarColor(.12,.12,.12,1)
		end
	end
end


lib.PostUpdateRaidFramePower = function(Power, unit, min, max)
	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	
	Power:SetAlpha(1)
	
	if dc or dead or ghost then
		if(dc) then
			Power:SetAlpha(.3)
		elseif(ghost) then
			Power:SetAlpha(.3)
		elseif(dead) then
			Power:SetAlpha(.3)
		end
	end
end


------------------------------------------------------------------------------
-- 
-- Class-specific Bars
-- 
------------------------------------------------------------------------------


-- Laser Chicken
lib.addEclipseBar = function(self)
	if playerClass ~= "DRUID" then return end

  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'

	local eclipseBar = CreateFrame('Frame', nil, self)
	eclipseBar:SetPoint('CENTER', point, anchor, 0, 0)
	eclipseBar:SetFrameLevel(4)
	eclipseBar:SetHeight(6)
	eclipseBar:SetWidth(self:GetWidth()+.5)
	local h = CreateFrame("Frame", nil, eclipseBar)
	h:SetPoint("TOPLEFT",-3,3)
	h:SetPoint("BOTTOMRIGHT",3,-3)
	eclipseBar.eBarBG = h
  lib.addBackground(h)

	local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
	lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
	lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
	lunarBar:SetStatusBarTexture(cfg.statusbar_texture)
	lunarBar:SetStatusBarColor(.1, .3, .7)
	lunarBar:SetFrameLevel(5)

	local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
	solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
	solarBar:SetStatusBarTexture(cfg.statusbar_texture)
	solarBar:SetStatusBarColor(1,.85,.13)
	solarBar:SetFrameLevel(5)
	
	
	eclipseBar.SolarBar = solarBar
	eclipseBar.LunarBar = lunarBar
	self.EclipseBar = eclipseBar
	self.EclipseBar.PostUnitAura = eclipseBarBuff
    
	local EBText = lib.genFontstring(solarBar, cfg.font, 14, "OUTLINE")
	EBText:SetPoint('CENTER', eclipseBar, 'CENTER', 0,0)
	local EBText2 = lib.genFontstring(solarBar, cfg.font, 16, "THINOUTLINE")
	EBText2:SetPoint('LEFT', EBText, 'RIGHT', 1,-1)
	--EBText2:SetShadowColor(0,0,0,1)
	--EBText2:SetShadowOffset(1,1)

	self.EclipseBar.PostDirectionChange = function(element, unit)
		EBText:SetText("")
		EBText2:SetText("")
	end
		
	--self:Tag(EBText, '[pereclipse]')
	self.EclipseBar.PostUpdatePower = function(unit)

		local eclipsePowerMax = UnitPowerMax('player', SPELL_POWER_ECLIPSE)
		local eclipsePower = math.abs(UnitPower('player', SPELL_POWER_ECLIPSE)/eclipsePowerMax*100)

		if ( GetEclipseDirection() == "sun" ) then
			EBText:SetText(eclipsePower .. "  >>")
			EBText2:SetText("|cff006accSTARFIRE|r")
			EBText2:ClearAllPoints()
			EBText2:SetPoint('RIGHT', EBText, 'LEFT', 1,-1)
		elseif ( GetEclipseDirection() == "moon" ) then
			EBText:SetText("<<  " .. eclipsePower)
			EBText2:SetText("|cffeac500WRATH|r")
			EBText2:ClearAllPoints()
			EBText2:SetPoint('LEFT', EBText, 'RIGHT', 1,-1)
		else
			EBText:SetText(eclipsePower)
			EBText2:SetText("")
		end
	end
	
	self.EclipseBar.PostUpdateVisibility = function(unit)
		local eclipsePowerMax = UnitPowerMax('player', SPELL_POWER_ECLIPSE)
		local eclipsePower = math.abs(UnitPower('player', SPELL_POWER_ECLIPSE)/eclipsePowerMax*100)

		if ( GetEclipseDirection() == "sun" ) then
			EBText:SetText(eclipsePower .. "  >>")
			EBText2:SetText("|cff006accSTARFIRE|r ")
			EBText2:ClearAllPoints()
			EBText2:SetPoint('RIGHT', EBText, 'LEFT', 1,-1)
		elseif ( GetEclipseDirection() == "moon" ) then
			EBText:SetText("<<  " .. eclipsePower)
			EBText2:SetText("|cffeac500WRATH|r")
			EBText2:ClearAllPoints()
			EBText2:SetPoint('LEFT', EBText, 'RIGHT', 1,-1)
		else
			EBText:SetText(eclipsePower)
			EBText2:SetText("")
		end
	end
end


-- Monk
lib.addHarmony = function(self)
	if playerClass ~= "MONK" then return end

  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'
	
	local mhb = CreateFrame("Frame", "MonkHarmonyBar", self)
	mhb:SetPoint("CENTER", point, anchor, cfg.resourcebarX, cfg.resourcebarY)
	mhb:SetWidth(self.Health:GetWidth() * .75)
	mhb:SetHeight(11)
  lib.addBackground(mhb)

  -- Placeholder slots for the "orbs"
  local maxPower = UnitPowerMax("player", SPELL_POWER_CHI)
  mhb.slots = CreateFrame("Frame", nil, self)
  mhb.slots:SetAllPoints(mhb)
  mhb.slots:SetFrameLevel(mhb:GetFrameLevel() + 1)
  local r,g,b = unpack(oUF.colors.class.MONK);
  for i = 1, maxPower do
    mhb.slots[i] = mhb.slots:CreateTexture(nil,"BORDER")
    mhb.slots[i]:SetTexture(r * 0.1, g * 0.1, b * 0.1, 1)
    mhb.slots[i]:SetHeight(9)
    mhb.slots[i]:SetWidth(mhb:GetWidth() / maxPower - 2)
    if i == 1 then
      mhb.slots[i]:SetPoint("LEFT", mhb.slots, "LEFT", 0, 0)
    else
      mhb.slots[i]:SetPoint("LEFT", mhb.slots[i - 1], "RIGHT", 2, 0)
    end
  end
	
  -- The actual "orbs"
	for i = 1, 5 do
		mhb[i] = CreateFrame("StatusBar", "MonkHarmonyBar"..i, mhb)
		mhb[i]:SetHeight(9)
		mhb[i]:SetStatusBarTexture(cfg.statusbar_texture)
		mhb[i]:SetStatusBarColor(.9,.9,.9)

		mhb[i].bg = mhb[i]:CreateTexture(nil,"BORDER")
		mhb[i].bg:SetTexture(0,1,0, 1)
		mhb[i].bg:SetPoint("TOPLEFT",mhb[i],"TOPLEFT",0,0)
		mhb[i].bg:SetPoint("BOTTOMRIGHT",mhb[i],"BOTTOMRIGHT",0,0)
		mhb[i].bg.multiplier = .3
		
		if i == 1 then
			mhb[i]:SetPoint("LEFT", mhb, "LEFT", 0, 0)
		else
			mhb[i]:SetPoint("LEFT", mhb[i-1], "RIGHT", 2, 0)
		end
	end
	
	self.MonkHarmonyBar = mhb
end


--Shadow Orbs bar
lib.addShadoworbs = function(self)
	if playerClass ~= "PRIEST" then return end

  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'
	
	local pso = CreateFrame("Frame", nil, self)
	pso:SetPoint('CENTER', point, anchor, 0, 0)
	pso:SetHeight(5)
	pso:SetWidth(self.Health:GetWidth()/2+50)
	
	local maxShadowOrbs = UnitPowerMax('player', SPELL_POWER_SHADOW_ORBS)
	
	for i = 1,maxShadowOrbs do
		pso[i] = CreateFrame("StatusBar", self:GetName().."_PriestShadowOrbs"..i, self)
		pso[i]:SetHeight(5)
		pso[i]:SetWidth(pso:GetWidth()/3-2)
		pso[i]:SetStatusBarTexture(cfg.statusbar_texture)
		pso[i]:SetStatusBarColor(.86,.22,1)
		pso[i]:SetFrameLevel(11)
		pso[i].bg = pso[i]:CreateTexture(nil, "BORDER")
		pso[i].bg:SetTexture(cfg.statusbar_texture)
		pso[i].bg:SetPoint("TOPLEFT", pso[i], "TOPLEFT", 0, 0)
		pso[i].bg:SetPoint("BOTTOMRIGHT", pso[i], "BOTTOMRIGHT", 0, 0)
		pso[i].bg.multiplier = 0.3
		
		--helper backdrop
		local h = CreateFrame("Frame", nil, pso[i])
		--h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		--lib.createBackdrop(h,1)
		
		if (i == 1) then
			pso[i]:SetPoint('LEFT', pso, 'LEFT', 1, 0)
		else
			pso[i]:SetPoint('TOPLEFT', pso[i-1], 'TOPRIGHT', 2, 0)
		end
	end
	
	self.PriestShadowOrbs = pso
end


-- SoulShard bar
lib.addShards = function(self)
	if playerClass ~= "WARLOCK" then return end

  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'
	
	local wsb = CreateFrame("Frame", "WarlockSpecBars", self)
	wsb:SetPoint("CENTER", point, anchor, cfg.resourcebarX, cfg.resourcebarY)
	wsb:SetWidth(self.Health:GetWidth()/2+50)
	wsb:SetHeight(11)
	--wsb:SetFrameLevel(10)
  lib.addBackground(wsb)
	
	for i = 1, 4 do
		wsb[i] = CreateFrame("StatusBar", "WarlockSpecBars"..i, wsb)
		wsb[i]:SetHeight(9)
		wsb[i]:SetStatusBarTexture(cfg.statusbar_texture)
		wsb[i]:SetStatusBarColor(.86,.22,1)
		wsb[i].bg = wsb[i]:CreateTexture(nil,"BORDER")
		wsb[i].bg:SetTexture(cfg.statusbar_texture)
		wsb[i].bg:SetVertexColor(0,0,0)
		wsb[i].bg:SetPoint("TOPLEFT",wsb[i],"TOPLEFT",0,0)
		wsb[i].bg:SetPoint("BOTTOMRIGHT",wsb[i],"BOTTOMRIGHT",0,0)
		wsb[i].bg.multiplier = .3
		
		local h = CreateFrame("Frame",nil,wsb[i])
		--h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		
		if i == 1 then
			wsb[i]:SetPoint("LEFT", wsb, "LEFT", 1, 0)
		else
			wsb[i]:SetPoint("LEFT", wsb[i-1], "RIGHT", 2, 0)
		end
	end
	
	self.WarlockSpecBars = wsb
end


-- HolyPowerbar
lib.addHolyPower = function(self)
	if playerClass ~= "PALADIN" then return end
	
  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'

	local php = CreateFrame("Frame", nil, self)
	php:SetPoint('CENTER', point, anchor, 0, 0)
	php:SetHeight(5)
	php:SetWidth(self.Health:GetWidth()/2+75)
	
	--local maxHolyPower = UnitPowerMax("player",SPELL_POWER_HOLY_POWER)
	
	for i = 1, 5 do
		php[i] = CreateFrame("StatusBar", self:GetName().."_Holypower"..i, self)
		php[i]:SetHeight(5)
		php[i]:SetWidth((php:GetWidth()/5)-2)
		php[i]:SetStatusBarTexture(cfg.statusbar_texture)
		php[i]:SetStatusBarColor(.9,.95,.33)
		php[i]:SetFrameLevel(11)
		php[i].bg = php[i]:CreateTexture(nil, "BORDER")
		php[i].bg:SetTexture(cfg.statusbar_texture)
		php[i].bg:SetPoint("TOPLEFT", php[i], "TOPLEFT", 0, 0)
		php[i].bg:SetPoint("BOTTOMRIGHT", php[i], "BOTTOMRIGHT", 0, 0)
		php[i].bg.multiplier = 0.3

		local h = CreateFrame("Frame", nil, php[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		--lib.createBackdrop(h,1)
		
		if (i == 1) then
			php[i]:SetPoint('LEFT', php, 'LEFT', 1, 0)
		else
			php[i]:SetPoint('TOPLEFT', php[i-1], "TOPRIGHT", 2, 0)
		end
	end
	
	self.PaladinHolyPower = php
end


-- Runebar
lib.addRunes = function(self)
	if playerClass ~= "DEATHKNIGHT" then return end

  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'

	self.Runes = CreateFrame("Frame", nil, self)
	self.Runes:SetPoint('CENTER', point, anchor, 0, 0)
	self.Runes:SetHeight(5)
	self.Runes:SetWidth(self.Health:GetWidth()-15)
	
	for i= 1, 6 do
		self.Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
		self.Runes[i]:SetHeight(5)
		self.Runes[i]:SetWidth((self.Health:GetWidth() / 6)-5)
		self.Runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
		self.Runes[i]:SetFrameLevel(11)
		self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BORDER")
		self.Runes[i].bg:SetTexture(cfg.statusbar_texture)
		self.Runes[i].bg:SetPoint("TOPLEFT", self.Runes[i], "TOPLEFT", 0, 0)
		self.Runes[i].bg:SetPoint("BOTTOMRIGHT", self.Runes[i], "BOTTOMRIGHT", 0, 0)
		self.Runes[i].bg.multiplier = 0.3
		
		local h = CreateFrame("Frame", nil, self.Runes[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		--lib.createBackdrop(h,1)
		
		if (i == 1) then
			self.Runes[i]:SetPoint('LEFT', self.Runes, 'LEFT', 1, 0)
		else
			self.Runes[i]:SetPoint('TOPLEFT', self.Runes[i-1], 'TOPRIGHT', 2, 0)
		end
	end
end


-- Combo Points
lib.addCPoints = function(self)
	if playerClass ~= "ROGUE" and playerClass ~= "DRUID" then return end

  local point  = cfg.resourcebarP and cfg.resourcebarP or UIParent
  local anchor = cfg.resourcebarA and cfg.resourcebarA or 'BOTTOM'

	local dcp = CreateFrame("Frame", nil, self)
	dcp:SetPoint('CENTER', point, anchor, 0, 0)
	dcp:SetHeight(5)
	dcp:SetWidth(self.Health:GetWidth()/2+75)

	for i= 1, 5 do
		dcp[i] = CreateFrame("StatusBar", self:GetName().."_CPoints"..i, self)
		dcp[i]:SetHeight(5)
		dcp[i]:SetWidth((dcp:GetWidth()/5)-2)
		dcp[i]:SetStatusBarTexture(cfg.statusbar_texture)
		dcp[i]:SetFrameLevel(11)
		dcp[i].bg = dcp[i]:CreateTexture(nil, "BORDER")
		dcp[i].bg:SetTexture(cfg.statusbar_texture)
		dcp[i].bg:SetPoint("TOPLEFT", dcp[i], "TOPLEFT", 0, 0)
		dcp[i].bg:SetPoint("BOTTOMRIGHT", dcp[i], "BOTTOMRIGHT", 0, 0)
		dcp[i].bg.multiplier = 0.3
		
		local h = CreateFrame("Frame", nil, dcp[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		--lib.createBackdrop(h,1)
		
		if (i == 1) then
			dcp[i]:SetPoint('LEFT', dcp, 'LEFT', 1, 0)
		else
			dcp[i]:SetPoint('TOPLEFT', dcp[i-1], 'TOPRIGHT', 2, 0)
		end
	end
	dcp[1]:SetStatusBarColor(.3,.9,.3)
	dcp[2]:SetStatusBarColor(.3,.9,.3)
	dcp[3]:SetStatusBarColor(.3,.9,.3)
	dcp[4]:SetStatusBarColor(.9,.9,0)
	dcp[5]:SetStatusBarColor(.9,.3,.3)	
	--end
	
	self.DrkCPoints = dcp
end


-- Heal Prediction
lib.addHealPred = function(self)
	if not cfg.showIncHeals then return end
	
	local mhpb = CreateFrame('StatusBar', nil, self.Health)
	mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	mhpb:SetWidth(self:GetWidth())
	mhpb:SetStatusBarTexture(cfg.statusbar_texture)
	if self.mystyle == "raid" then
		mhpb:SetStatusBarColor(0, 200/255, 0, 0.4)
	else
		mhpb:SetFrameLevel(2)
		mhpb:SetStatusBarColor(0, 200/255, 0, 0.8)
	end

	local ohpb = CreateFrame('StatusBar', nil, self.Health)
	ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	ohpb:SetWidth(self:GetWidth())
	ohpb:SetStatusBarTexture(cfg.statusbar_texture)
	if self.mystyle == "raid" then
		ohpb:SetStatusBarColor(0, 200/255, 0, 0.4)
	else
		ohpb:SetStatusBarColor(0, 200/255, 0, 0.8)
		ohpb:SetFrameLevel(2)
	end

	self.HealPrediction = {
		myBar = mhpb,
		otherBar = ohpb,
		maxOverflow = 1.01,
	}
end


-- Plugins -------------------------------------------


lib.addRaidDebuffs = function(self)
	local raid_debuffs = cfg.DebuffWatchList
	
	local debuffs = raid_debuffs.debuffs
	local CustomFilter = function(icons, ...)
		local _, icon, _, _, _, _, dtype, _, _, _, _, _, spellID = ...
		name = tostring(spellID)
		if debuffs[name] then
			icon.priority = debuffs[name]
			return true
		else
			icon.priority = 0
		end
	end

	local debuffs = CreateFrame("Frame", nil, self)
	debuffs:SetWidth(12)
	debuffs:SetHeight(12)
	debuffs:SetFrameLevel(7)
	debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
	debuffs.size = 12
	
	debuffs.CustomFilter = CustomFilter
	self.raidDebuffs = debuffs
end


lib.addExperienceBar = function(self)
	self.Experience = CreateFrame('StatusBar', nil, self)
	self.Experience:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', ((self.Health:GetWidth()-self.Portrait:GetWidth())/2), 29)
	self.Experience:SetWidth(self.Portrait:GetWidth())
	self.Experience:SetHeight(3)
	self.Experience:SetFrameLevel(6)
	self.Experience:SetStatusBarTexture(cfg.statusbar_texture)
	self.Experience:GetStatusBarTexture():SetHorizTile(false)
	self.Experience:SetStatusBarColor(.407, .13, .545)
	
	self.Experience.Rested = CreateFrame('StatusBar',nil,self.Experience)
	self.Experience.Rested:SetAllPoints(self.Experience)
	self.Experience.Rested:SetStatusBarTexture(cfg.statusbar_texture)
	self.Experience.Rested:SetStatusBarColor(.117,.55,1)

	self.Experience.Rested.bg = self.Experience.Rested:CreateTexture(nil, 'BACKGROUND')
	self.Experience.Rested.bg:SetAllPoints(self.Experience)
	self.Experience.Rested.bg:SetTexture(cfg.statusbar_texture)
	self.Experience.Rested.bg:SetVertexColor(0,0,0)

	local h = CreateFrame("Frame", nil, self.Experience.Rested)
	h:SetFrameLevel(5)
	h:SetPoint("TOPLEFT",-3,3)
	h:SetPoint("BOTTOMRIGHT",3,-3)
		local backdrop_tab = {
			bgFile = cfg.backdrop_texture,
			edgeFile = cfg.backdrop_edge_texture,
			tile = false,
			tileSize = 0,
			edgeSize = 4,
			insets = {
			  left = 2,
			  right = 2,
			  top = 2,
			  bottom = 2,
			},
		  }
	h:SetBackdrop(backdrop_tab);
	h:SetBackdropColor(0,0,0,1)
	h:SetBackdropBorderColor(0,0,0,0.8)
	
	self.Experience.Text = lib.genFontstring(self.Experience,cfg.smallfont,9,'OUTLINE')
	self.Experience.Text:SetPoint("CENTER",self.Experience,"BOTTOM",0,0)
	self:Tag(self.Experience.Text,"[drk:xp]")
			
	self.Experience.Text:SetAlpha(0)
	self.Experience.PostUpdate = ExpOverrideText
end

 
-- Add hilight texture
lib.addHighlight = function(f)
    local OnEnter = function(f)
		UnitFrame_OnEnter(f)
		f.Highlight:Show()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0.9)
		end
		if f.mystyle == "raid" then
			if not cfg.showTooltips then GameTooltip:Hide() end
			if cfg.showRoleIcons then f.LFDRole:SetAlpha(1) end
		end
    end
    local OnLeave = function(f)
		UnitFrame_OnLeave(f)
		f.Highlight:Hide()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0)
		end
		if f.mystyle == "raid" then
			if cfg.showRoleIcons then f.LFDRole:SetAlpha(0) end
		end
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.highlight_texture)
    hl:SetVertexColor(.5,.5,.5,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
end


-----------------------------
-- HANDOVER
-----------------------------


--hand the lib to the namespace for further usage...this is awesome because you can reuse functions in any of your layout files
ns.lib = lib
