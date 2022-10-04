--[[
	HI WALDO!!! :3
	context: i originally made this script for waldo
	
	THIS SCRIPT IS BASED FROM/ON THIS ENGINE
	https://youtu.be/M1wEidB5zhk
	
	SCRIPT FROM AND BY RALTYRO
--]]

--[[ Mic'd Up + Psych Engine Looking Settings
	coolBar = true
	hideTimeBar = true
	shiftCameraOnNote = true
	shiftCameraPixels = 32
	smoothCamera = true
	smoothZoom = true
	smoothIntensity = .875
	showNoteCombo = true
	showHealthPercent = false
--]]

--[[ Default Settings
	coolBar = true
	hideTimeBar = true
	shiftCameraOnNote = true
	shiftCameraPixels = 32
	smoothCamera = true
	smoothZoom = true
	smoothIntensity = .65
	showNoteCombo = true
	showHealthPercent = false
--]]
local settings = {
	coolBar = true,
	hideTimeBar = true,
	--fixComboPos = true, impossible to move combo pos in psych lua, i dont wanna recreate it in lua :/
	shiftCameraOnNote = true,
	shiftCameraPixels = 32,
	smoothCamera = true,
	smoothZoom = true,
	smoothIntensity = .65, -- too much smooth or below 0 = camera wont move lmao
	showNoteCombo = true, -- disable this if its annoying lmao
	noteComboX = 311,
	noteComboY = 223,
	showHealthPercent = false -- MEMORY LEAKS WARNING!!!
}

-----------------------------------------------------------------------
-- NO TOUCHIES >:(
-----------------------------------------------------------------------







--[[ EASING ]]--

-- formulas from http://www.robertpenner.com/easing
easing = {
	-- linear
	linear = function(t,b,c,d)
		return c * t / d + b
	end,
	
	-- quad
	inQuad = function(t, b, c, d)
		return c * math.pow(t / d, 2) + b
	end,
	outQuad = function(t, b, c, d)
		t = t / d
		return -c * t * (t - 2) + b
	end,
	inOutQuad = function(t, b, c, d)
		t = t / d * 2
		if t < 1 then return c / 2 * math.pow(t, 2) + b end
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end,
	outInQuad = function(t, b, c, d)
		if t < d / 2 then return outQuad(t * 2, b, c / 2, d) end
		return inQuad((t * 2) - d, b + c / 2, c / 2, d)
	end,
	
	-- cubic
	inCubic = function(t, b, c, d)
		return c * math.pow(t / d, 3) + b
	end,
	outCubic = function(t, b, c, d)
		return c * (math.pow(t / d - 1, 3) + 1) + b
	end,
	inOutCubic = function(t, b, c, d)
		t = t / d * 2
		if t < 1 then return c / 2 * t * t * t + b end
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end,
	outInCubic = function(t, b, c, d)
		if t < d / 2 then return outCubic(t * 2, b, c / 2, d) end
		return inCubic((t * 2) - d, b + c / 2, c / 2, d)
	end,
	
	-- quint
	inQuint = function(t, b, c, d)
		return c * math.pow(t / d, 5) + b
	end,
	outQuint = function(t, b, c, d)
		return c * (math.pow(t / d - 1, 5) + 1) + b
	end,
	inOutQuint = function(t, b, c, d)
		t = t / d * 2
		if t < 1 then return c / 2 * math.pow(t, 5) + b end
		return c / 2 * (math.pow(t - 2, 5) + 2) + b
	end,
	outInQuint = function(t, b, c, d)
		if t < d / 2 then return outQuint(t * 2, b, c / 2, d) end
		return inQuint((t * 2) - d, b + c / 2, c / 2, d)
	end,
	
	-- elastics
	outElastic = function(t, b, c, d, a, p)
		a = a or 3
		p = p or 1
		if t == 0 then return b end
		t = t / d
		if t == 1 then return b + c end
		if not p then p = d * 0.3 end
		local s
		if not a or a < math.abs(c) then
			a = c
			s = p / 4
		else
			s = p / (2 * math.pi) * math.asin(c/a)
		end
		return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
	end
}

--[[ TWEENNUMBER ]]--
local time = 0
local os = os
function os.clock()
	return time
end

tweenReqs = {}

function tnTick()
	local clock = os.clock()
	--print(songPos, #tweenReqs)
	if #tweenReqs > 0 then
		for i,v in next,tweenReqs do
			if clock>v[5]+v[6] then
				v[1][v[2]] =  v[7](v[6],v[3],v[4]-v[3],v[6])
				table.remove(tweenReqs,i)
				if v[9] then
					v[9]()
				end
			else
				v[1][v[2]] = v[7](clock-v[5],v[3],v[4]-v[3],v[6])
				--if (v[8]) then
				--	v[8] = false
				--	v[1][v[2]] = v[7](0,v[3],v[4]-v[3],v[6])
				--end
			end
		end
	end
end

function tweenNumber(maps, varName, startVar, endVar, time, startTime, easeF, onComplete)
	local clock = os.clock()
	maps = maps or getfenv()
	
	if #tweenReqs > 0 then
		for i2,v2 in next,tweenReqs do
			if v2[2] == varName and v2[1] == maps then
				v2[1][v2[2]] =  v2[7](v2[6],v2[3],v2[4]-v2[3],v2[6])
				table.remove(tweenReqs,i2)
				if v2[9] then
					v2[9]()
				end
				break
			end
		end
	end
	
	--print("Created TweenNumber: "..tostring(varName), startVar, endVar, time, startTime, type(onComplete) == "function")
	local t = {
		maps,
		varName,
		startVar,
		endVar,
		startTime or clock,
		time,
		easeF or easing.linear,
		true,
		onComplete
	}
	
	table.insert(tweenReqs,t)
	t[1][t[2]] = t[7](0,t[3],t[4]-t[3],t[6])
	
	return function()
		maps[varName] = t[7](v[6],t[3],t[4]-t[3],t[6])
		table.remove(tweenReqs,table.find(tweenReqs,t))
		if onComplete then
			onComplete()
		end
		return nil
	end
end

function math.clamp(x,min,max)return math.max(min,math.min(x,max))end
function math.lerp(from,to,i)return from+(to-from)*i end

function math.truncate(x, precision, round)
	if (precision == 0) then return math.floor(x) end
	
	precision = type(precision) == "number" and precision or 2
	
	x = x * math.pow(10, precision);
	return (round and math.floor(x + .5) or math.floor(x)) / math.pow(10, precision)
end

function math.snap(x, snap, next, round)
	snap = type(snap) == "number" and snap or 1
	next = type(ntext) == "number" and next or 0
	round = type(round) == "number" and round or .5
	
	return math.floor((x / snap) + round) * snap + (next * snap)
end

function toHexString(red, green, blue, prefix)
	if (prefix == nil) then prefix = true end
	
	return (prefix and "0x" or "") .. (
			string.format("%02X%02X%02X", red, green, blue)
		)
end

function centerOrigin(obj)
	setProperty(obj .. ".origin.x", getProperty(obj .. ".frameWidth") * .5)
	setProperty(obj .. ".origin.y", getProperty(obj .. ".frameHeight") * .5)
end

function getObjectRealClip(spr)
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.frame.x")) ~= "number") then return end
	
	return 
		getProperty(spr .. ".frame.frame.x"),
		getProperty(spr .. ".frame.frame.y"),
		getProperty(spr .. ".frame.frame.width"),
		getProperty(spr .. ".frame.frame.height")
end

function getObjectClip(spr)
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.frame.x")) ~= "number") then return end
	
	return 
		getProperty(spr .. "._frame.frame.x"),
		getProperty(spr .. "._frame.frame.y"),
		getProperty(spr .. "._frame.frame.width"),
		getProperty(spr .. "._frame.frame.height")
end

function setObjectClip(spr, x, y, width, height, offsetX, offsetY, offsetWidth, offsetHeight)
	-- Check and Fix Arguments
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.frame.x")) ~= "number") then return end
	x = (type(x) == "number" and x or getProperty(spr .. ".frame.frame.x")) + (type(offsetX) == "number" and offsetX or 0)
	y = (type(y) == "number" and y or getProperty(spr .. ".frame.frame.y")) + (type(offsetY) == "number" and offsetY or 0)
	width = type(width) == "number" and width >= 0 and width or getProperty(spr .. ".frame.frame.width") + (type(offsetWidth) == "number" and offsetWidth or 0)
	height = type(height) == "number" and height >= 0 and height or getProperty(spr .. ".frame.frame.height") + (type(offsetHeight) == "number" and offsetHeight or 0)
	
	-- ClipRect
	setProperty(spr .. "._frame.frame.x", x)
	setProperty(spr .. "._frame.frame.y", y)
	setProperty(spr .. "._frame.frame.width", width)
	setProperty(spr .. "._frame.frame.height", height)
	
	return x, y, width, height
end

--[[
function getObjectRealFrameOffset(spr)
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.offset.x")) ~= "number") then return end
	
	return 
		getProperty(spr .. ".frame.offset.x"),
		getProperty(spr .. ".frame.offset.y")
end

function getObjectFrameOffset(spr)
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.offset.x")) ~= "number") then return end
	
	return 
		getProperty(spr .. "._frame.offset.x"),
		getProperty(spr .. "._frame.offset.y")
end

function setObjectFrameOffset(spr, x, y, offsetX, offsetY)
	-- Check and Fix Arguments
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.offset.x")) ~= "number") then return end
	x = (type(x) == "number" and x or getProperty(spr .. ".frame.offset.x")) + (type(offsetX) == "number" and offsetX or 0)
	y = (type(y) == "number" and y or getProperty(spr .. ".frame.offset.y")) + (type(offsetY) == "number" and offsetY or 0)
	
	-- Frame Offset
	setProperty(spr .. "._frame.offset.x", x)
	setProperty(spr .. "._frame.offset.y", y)
	
	return x, y
end
]]

local function getCamString(cam)
	return type(cam) ~= "string" and "default" or (
		cam:lower():find("hud") and "camHUD" or
		cam:lower():find("other") and "camOther" or
		"default"
	)
end

local function getCamProperty(cam, p)
	if (p == nil) then p = cam; cam = nil end
	local str = getCamString(cam)
	
	if (str == "default") then
		return p == "scroll.x" and getProperty("camFollowPos.x") or p == "scroll.y" and getProperty("camFollowPos.y") or
			getPropertyFromClass("flixel.FlxG", "camera." .. p)
	end
	
	return getProperty(str .. "." .. p)
end

local function setCamProperty(cam, p, v)
	if (v == nil) then v = p; p = cam; cam = nil end
	local str = getCamString(cam)
	
	if (str == "default") then
		return p == "scroll.x" and setProperty("camFollowPos.x", v) or p == "scroll.y" and setProperty("camFollowPos.y", v) or
			setPropertyFromClass("flixel.FlxG", "camera." .. p, v)
	end
	
	return getProperty(str .. "." .. p, v)
end

local dFont = "Krabby Patty.ttf"

local avZoom = .0375
local cX = -10 + (1280 * avZoom)
local cY = 720 - (720 * avZoom)

local realCamScX = 0
local realCamScY = 0
local realCamAngle = 0
local realCamZoom = 1

local camScX = 0
local camScY = 0
local camAngle = 0
local camZoom = 1

--local prevComboOffset
function onCreate()
	precacheImage("EngineStuff/NoteCombo")
	precacheImage("EngineStuff/coolhealthborder")
	precacheImage("EngineStuff/coolhealthbar")
	
	precacheSound("NoteComboExecute")
	
	--prevComboOffset = getPropertyFromClass("ClientPrefs", "comboOffset")
end

--[[
function onDestroy()
	setPropertyFromClass("ClientPrefs", "comboOffset", prevComboOffset)
end
--]]

function onCreatePost()
	local dS = getPropertyFromClass("ClientPrefs", "downScroll")
	local gAA = getPropertyFromClass("ClientPrefs", "globalAntialiasing")
	
	if (getPropertyFromClass("ClientPrefs", "downScroll")) then
		cY = (720 * avZoom) + (26 * 6)
	end
	
	makeLuaText("score", "Score: ", 1, cX, cY - (26 * 3))
	setTextAlignment("score", "left")
	setTextFont("score", dFont)
	setTextSize("score", 22)
	
	makeLuaText("misses", "Misses: ", 1, cX, cY - (26 * 2))
	setTextAlignment("misses", "left")
	setTextFont("misses", dFont)
	setTextSize("misses", 22)
	
	makeLuaText("rating", "Rating: ", 1, cX, cY - (26))
	setTextAlignment("rating", "left")
	setTextFont("rating", dFont)
	setTextSize("rating", 22)
	
	setProperty("score.wordWrap", false)
	setProperty("score.autoSize", true)
	setProperty("misses.wordWrap", false)
	setProperty("misses.autoSize", true)
	setProperty("rating.wordWrap", false)
	setProperty("rating.autoSize", true)
	
	setProperty("score.antialiasing", gAA)
	setProperty("misses.antialiasing", gAA)
	setProperty("rating.antialiasing", gAA)
	
	setScrollFactor("score", 0, 0)
	setObjectCamera("score", "hud")
	setScrollFactor("misses", 0, 0)
	setObjectCamera("misses", "hud")
	setScrollFactor("rating", 0, 0)
	setObjectCamera("rating", "hud")
	
	addLuaText("score", true)
	addLuaText("misses", true)
	addLuaText("rating", true)
	
	if (settings.hideTimeBar) then
		setProperty("timeTxt.visible", false)
		setProperty("timeBarBG.visible", false)
		setProperty("timeBar.visible", false)
		setProperty("updateTime", false)
	end
	
	--setPropertyFromClass("ClientPrefs", "comboOffset", {605, -307, 717, -248})
	
	realCamScX = getCamProperty("scroll.x")
	realCamScY = getCamProperty("scroll.y")
	realCamAngle = getCamProperty("angle")
	realCamZoom = getCamProperty("zoom")
	
	camScX = realCamScX
	camScY = realCamScY
	camAngle = realCamAngle
	camZoom = realCamZoom
	
	if (settings.coolBar) then
		loadGraphic("healthBarBG", "EngineStuff/coolhealthborder")
		setProperty("healthBarBG.yAdd", -25)
		setProperty("healthBarBG.xAdd", -54)
		
		makeLuaSprite("healthBarP1", "EngineStuff/coolhealthbar")
		makeLuaSprite("healthBarP2", "EngineStuff/coolhealthbar")
		
		setObjectCamera("healthBarP1", "hud")
		setObjectCamera("healthBarP2", "hud")
		
		addLuaSprite("healthBarP1")
		addLuaSprite("healthBarP2")
		
		setObjectOrder("healthBarP1", getObjectOrder("healthBar") - 1)
		setObjectOrder("healthBarP2", getObjectOrder("healthBar") - 1)
		
		--setProperty("healthBar.scale.y", 12 / 19)
		--setProperty("healthBar.antialiasing", gAA)
	end
	
	if (settings.showNoteCombo) then
		makeAnimatedLuaSprite("ntCombo", "EngineStuff/NoteCombo", 0, 0)
		addAnimationByPrefix("ntCombo", "anim", " NoteComboTextAppearAndDisappear", 24, false)
		scaleObject("ntCombo", .56, .56)
		
		setObjectCamera("ntCombo", "hud")
	end
	
	if (settings.showHealthPercent) then
		makeLuaText("healthper", "50%", 200, (1280 / 2) - (200 / 2), getProperty("healthBarBG.y") + (dS and -32 or 32))
		setTextAlignment("healthper", "center")
		setTextFont("healthper", dFont)
		setTextSize("healthper", 26)
		
		--setProperty("healthper.wordWrap", false)
		--setProperty("healthper.autoSize", true)
		setProperty("healthper.antialiasing", gAA)
		
		setScrollFactor("healthper", 0, 0)
		setObjectCamera("healthper", "hud")
		
		addLuaText("healthper", true)
	end
end

scoreSX = 1
scoreSY = 1

missesSX = 1
missesSY = 1

ratingSX = 1
ratingSY = 1

local bfShift = {x = 0, y = 0}
local dadShift = {x = 0, y = 0}

function shiftCamNote(t, dir)
	if (settings.shiftCameraOnNote) then
		local x = dir == 0 and -1 or (dir == 3 and 1) or 0
		local y = dir == 1 and 1 or (dir == 2 and -1) or 0
		tweenNumber(t, "x", x, 0, (stepCrochet / 1000) * 3.14, nil, easing.outCubic)
		tweenNumber(t, "y", y, 0, (stepCrochet / 1000) * 3.14, nil, easing.outCubic)
	end
end

function opponentNoteHit(id, dir)
	shiftCamNote(dadShift, dir)
end

function goodNoteHit(id, dir, typ, sus)
	if (not sus) then
		tweenNumber(nil, "scoreSX", 1.075, 1, .2, nil, easing.linear)
		tweenNumber(nil, "scoreSY", 1.075, 1, .2, nil, easing.linear)
		
		tweenNumber(nil, "ratingSX", 1.075, 1, .2, nil, easing.linear)
		tweenNumber(nil, "ratingSY", 1.075, 1, .2, nil, easing.linear)
	end
	shiftCamNote(bfShift, dir)
end

function noteMiss(id, dir)
	shiftCamNote(bfShift, dir)
end

function noteMissPress(key)
	shiftCamNote(bfShift, key)
end

local isDead = false
function onGameOverStart()
	isDead = true
end

local wowCombo = 0
local prevCombo = 0
local dontPlayCombo = false
local gDt = 0
function onStepHit()
	if (isDead or getProperty("isDead")) then return end
	
	if (math.fmod(curStep, 16) == 0 and getProperty("camZooming") and getCamProperty("zoom") < 1.35 and getPropertyFromClass("ClientPrefs", "camZooms")) then
		camZoom = camZoom + .015
	end
	
	local thing = curBpm <= 140 and math.snap(((-curBpm + 140) / 2.5), 8) + 8 or 8
	
	if (settings.showNoteCombo and math.fmod(curStep, thing) == 0) then
		local combo = getProperty("combo")
		
		wowCombo = math.clamp(combo - prevCombo, 0, 100)
		
		if (wowCombo >= 5 and not dontPlayCombo) then
			local canPlay = false
			
			local n = 0
			local songPos = getSongPosition() - (gDt * 1000)
			local et = songPos + (stepCrochet * thing)
			for i = 0, getProperty("notes.length") - 1 do
				local pos = getPropertyFromGroup("notes", i, "strumTime")
				if (
					getPropertyFromGroup("notes", i, "mustPress")
					and not getPropertyFromGroup("notes", i, "isSustainNote")
					and pos >= songPos and pos < et
				) then
					n = n + 1
				end
			end
			
			canPlay = n <= 0
			
			if (canPlay) then
				objectPlayAnimation("ntCombo", "anim", true, 13)
				setProperty("ntCombo.animation.curAnim.reversed", true)
				playSound("NoteComboExecute", 1)
				
				setProperty("ntCombo.x", settings.noteComboX - 42)
				setProperty("ntCombo.y", settings.noteComboY + 21)
				
				doTweenX("ntComboX", "ntCombo", settings.noteComboX, .12, "quadout")
				doTweenY("ntComboY", "ntCombo", settings.noteComboY, .12, "quadout")
				
				addLuaSprite("ntCombo")
				runTimer("ntCombo", 14 / 24)
				
				dontPlayCombo = true
				
				prevCombo = combo
			end
		end
		
		if (combo < prevCombo) then
			prevCombo = combo
		end
	end
end

function onTimerCompleted(t)
	if (t == "ntCombo") then
		dontPlayCombo = false
		removeLuaSprite("ntCombo", false)
	end
end

local prevFollowXAdd = 0
local prevFollowYAdd = 0
function onUpdate(dt)
	gDt = dt
	time = time + dt
	
	if (settings.smoothCamera) then
		setCamProperty("scroll.x", getCamProperty("scroll.x") - (camScX - realCamScX))
		setCamProperty("scroll.y", getCamProperty("scroll.y") - (camScY - realCamScY))
		setCamProperty("angle", getCamProperty("angle") - (camAngle - realCamAngle))
		setCamProperty("zoom", getCamProperty("zoom") - (camZoom - realCamZoom))
	end
	
	if (isDead or getProperty("isDead")) then return end
	
	local pix = settings.shiftCameraPixels
	local pix2 = settings.shiftCameraPixels * .3
	
	local followXAdd = (bfShift.x * (mustHitSection and pix or pix2)) + (dadShift.x * (mustHitSection and pix2 or pix))
	local followYAdd = (bfShift.y * (mustHitSection and pix or pix2)) + (dadShift.y * (mustHitSection and pix2 or pix))
	
	setProperty("camFollow.x", getProperty("camFollow.x") - prevFollowXAdd)
	setProperty("camFollow.y", getProperty("camFollow.y") - prevFollowYAdd)
	if (settings.shiftCameraOnNote) then
		setProperty("camFollow.x", getProperty("camFollow.x") + followXAdd)
		setProperty("camFollow.y", getProperty("camFollow.y") + followYAdd)
		prevFollowXAdd = followXAdd
		prevFollowYAdd = followYAdd
	else
		prevFollowXAdd = 0
		prevFollowYAdd = 0
	end
end

function onMoveCamera()
	prevFollowXAdd = 0
	prevFollowYAdd = 0
end

local prevScoreTxt = "Score: "
local prevMissesTxt = "Misses: "
local prevRatingTxt = "Rating: "
local prevHealthTxt = "50%"

--local camStrength = 0
function onUpdatePost(dt)
	local isDead = isDead or getProperty("isDead")
	
	realCamScX = getCamProperty("scroll.x")
	realCamScY = getCamProperty("scroll.y")
	realCamAngle = getCamProperty("angle")
	realCamZoom = getCamProperty("zoom")
	
	local camSpeed = isDead and 1 or getProperty("cameraSpeed")
	
	if (settings.smoothCamera) then
		--[[local x = camScX - realCamScX
		local y = camScY - realCamScY
		local distance = math.sqrt((x * x) + (y * y))
		print(distance)
		
		camStrength = math.clamp(math.lerp(camStrength, 0, 0), 0, 2.4)]]
		
		local smooth = ((1 / settings.smoothIntensity) + 1)
		
		local l = math.clamp(dt * 2.4 * smooth * camSpeed, 0, 1)
		
		camScX = math.lerp(camScX, realCamScX, l)
		camScY = math.lerp(camScY, realCamScY, l)
		camAngle = realCamAngle--math.lerp(camAngle, realCamAngle, math.clamp(dt * 2.4 * smooth, 0, 1))
		camZoom = settings.smoothZoom and math.lerp(camZoom, realCamZoom, math.clamp(dt * 3.125 * smooth, 0, 1)) or realCamZoom
		
		setCamProperty("scroll.x", camScX)
		setCamProperty("scroll.y", camScY)
		setCamProperty("angle", camAngle)
		setCamProperty("zoom", camZoom)
	end
	
	tnTick()
	
	if (isDead) then return end
	
	local health = math.clamp(getHealth(), 0, 2)
	local ratingName = getProperty("ratingName")
	
	local scoreTxt = "Score: " .. tostring(getProperty("songScore"))
	local missesTxt = "Misses: " .. tostring(getProperty("songMisses"))
	local ratingTxt = "Rating: " .. (
		ratingName == "?" and "?" or
		(
			ratingName ..
			" (" .. tostring(math.truncate(getProperty("ratingPercent") * 100, 2)) .. "%)" ..
			" - " .. getProperty("ratingFC")
		)
	)
	local healthTxt = tostring(math.floor(health * 50)) .. "%"
	
	setProperty("scoreTxt.visible", false)
	
	local hideHud = getPropertyFromClass("ClientPrefs", "hideHud")
	
	if (scoreTxt ~= prevScoreTxt) then
		setTextString("score", scoreTxt)
		centerOrigin("score")
	end
	setProperty("score.visible", not hideHud)
	setProperty("score.scale.x", scoreSX)
	setProperty("score.scale.y", scoreSY)
	
	if (missesTxt ~= prevMissesTxt) then
		setTextString("misses", missesTxt)
		centerOrigin("misses")
	end
	setProperty("misses.visible", not hideHud)
	setProperty("misses.scale.x", missesSX)
	setProperty("misses.scale.y", missesSY)
	
	if (ratingTxt ~= prevRatingTxt) then
		setTextString("rating", ratingTxt)
		centerOrigin("rating")
	end
	setProperty("rating.visible", not hideHud)
	setProperty("rating.scale.x", ratingSX)
	setProperty("rating.scale.y", ratingSY)
	
	if (settings.showHealthPercent) then
		if (healthTxt ~= prevHealthTxt) then
			setTextString("healthper", healthTxt)
			centerOrigin("healthper")
		end
		setProperty("healthper.visible", not hideHud)
	end
	
	prevScoreTxt = scoreTxt
	prevMissesTxt = missesTxt
	prevRatingTxt = ratingTxt
	prevHealthTxt = healthTxt
	
	if (settings.coolBar) then
		setProperty("healthBar.visible", false)
		
		local healthBarBGAlpha = getProperty("healthBarBG.alpha")
		local healthBarBGVisible = getProperty("healthBarBG.visible")
		local healthBarBGX = getProperty("healthBarBG.x")
		local healthBarBGY = getProperty("healthBarBG.y")
		local healthBarBGA = getProperty("healthBarBG.angle")
		
		local dadColors = getProperty("dad.healthColorArray")
		local bfColors = getProperty("boyfriend.healthColorArray")
		
		local dadColor = tonumber(toHexString(dadColors[1], dadColors[2], dadColors[3]))
		local bfColor = tonumber(toHexString(bfColors[1], bfColors[2], bfColors[3]))
		
		setProperty("healthBarP1.color", dadColor)
		setProperty("healthBarP2.color", bfColor)
		
		local vvv = math.clamp(math.lerp(0, getProperty("healthBarP1.frame.frame.width"), (-health + 2) / 2), 1, 1024)
		setObjectClip("healthBarP1", 0, 0, vvv, -1)
		setObjectClip("healthBarP2", vvv, 0, math.clamp(math.lerp(0, getProperty("healthBarP2.frame.frame.width"), health / 2), 1, 1024), -1)
		
		setProperty("healthBarP1.visible", healthBarBGVisible)
		setProperty("healthBarP1.alpha", healthBarBGAlpha)
		setProperty("healthBarP1.angle", healthBarBGA)
		setProperty("healthBarP1.x", healthBarBGX + 43)
		setProperty("healthBarP1.y", healthBarBGY + 25)
		
		setProperty("healthBarP2.visible", healthBarBGVisible)
		setProperty("healthBarP2.alpha", healthBarBGAlpha)
		setProperty("healthBarP2.angle", healthBarBGA)
		setProperty("healthBarP2.x", healthBarBGX + 43)
		setProperty("healthBarP2.offset.x", -vvv)
		setProperty("healthBarP2.y", healthBarBGY + 25)
	end
end