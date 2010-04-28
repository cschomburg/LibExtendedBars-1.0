--[[
Name: LibExtendedBars-1.0
Author: Cargor (xconstruct@gmail.com)
Dependencies: LibStub
License: GPL 2
Description: Status bars which can grow in any direction
]]

local lib = LibStub:NewLibrary("LibExtendedBars-1.0", 2)
if(not lib) then return end

local data, defaults = {}, {__index={
	anchor = "LEFT",
	orient = "HORIZONTAL",
	min = 0,
	max = 1,
	value = 1,
	horizTile = false,
	vertTile = false,
	mode = "crop",
}}

local Prototype = CreateFrame"Frame"
Prototype.__index = Prototype

local function calcInsets(val, first, second)
	val = 1-val
	if(first and second) then
		return val/2, val/2
	else
		return first and val or 0, second and val or 0
	end
end

local function updateBar(self)
	local width, height = self:GetWidth(), self:GetHeight()
	if(not width or width == 0 or not height or height == 0) then return end

	local cfg = data[self]

	local value, min, max = cfg.value, cfg.min, cfg.max
	local var = (max-min == 0) and 0 or (value-min)/(max-min)
	var = (var <= 0 and 1e-5) or (var > 1 and 1) or var
	local x, y = cfg.sizeX and var or 1, cfg.sizeY and var or 1

	cfg.bar:SetWidth(width*x)
	cfg.bar:SetHeight(height*y)

	if(cfg.mode == "crop") then
		local left, right = calcInsets(x, cfg.calcLeft, cfg.calcRight)
		local top, bottom = calcInsets(y, cfg.calcTop, cfg.calcBottom)
		cfg.bar:SetTexCoord(left, 1-right, top, 1-bottom)
	end
end

function lib.CreateExtendedBar(name, parent, anchor, orientation)
	if(type(name) == "table") then
		cfg = name
	else
		cfg = {anchor = anchor, parent = parent, orient = orientation}
	end

	local cfg = setmetatable(cfg, defaults)
	local frame = setmetatable(CreateFrame("Frame", nil, cfg.parent), Prototype)

	local bar = frame:CreateTexture(nil, "OVERLAY")
	cfg.bar = bar

	hooksecurefunc(frame, "SetPoint", updateBar)
	hooksecurefunc(frame, "SetHeight", updateBar)
	hooksecurefunc(frame, "SetWidth", updateBar)

	data[frame] = cfg

	frame:SetOrientation(cfg.orient)
	frame:SetAnchor(cfg.anchor)

	return frame
end

function Prototype:SetAnchor(anchor)
	local cfg = data[self]
	cfg.anchor = anchor

	cfg.calcLeft = not cfg.anchor:match("LEFT")
	cfg.calcRight = not cfg.anchor:match("RIGHT")
	cfg.calcTop = not cfg.anchor:match("TOP")
	cfg.calcBottom = not cfg.anchor:match("BOTTOM")

	cfg.bar:ClearAllPoints()
	cfg.bar:SetPoint(anchor)
	updateBar(self)
end

function Prototype:SetMinMaxValues(min, max)
	data[self].min, data[self].max = min, max
	updateBar(self)
end

function Prototype:SetOrientation(value)
	data[self].orient = value
	data[self].sizeX = (value == "HORIZONTAL" or value == "BOTH")
	data[self].sizeY = (value == "VERTICAL" or value == "BOTH")
	updateBar(self)
end

function Prototype:SetStatusBarColor(...)
	data[self].bar:SetVertexColor(...)
end

function Prototype:SetStatusBarTexture(...)
	data[self].bar:SetTexture(...)
	data[self].bar:SetHorizTile(cfg.horizTile)
	data[self].bar:SetVertTile(cfg.vertTile)
	updateBar(self)
end

function Prototype:SetValue(value)
	data[self].value = value
	updateBar(self)
end

function Prototype:GetObjectType() return "ExtendedBar" end
function Prototype:GetAnchor() return data[self].anchor end
function Prototype:GetMinMaxValues() return data[self].min, data[self].max end
function Prototype:GetOrientation() return data[self].orient end
function Prototype:GetStatusBarColor() return data[self].bar:GetVertexColor() end
function Prototype:GetStatusBarTexture() return data[self].bar end
function Prototype:GetValue() return data[self].value end