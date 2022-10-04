local followchars = true
local xx = 50
local yy = -60
local xx2 = 55
local yy2 = -60
local ofs = 16
local del = 10
local del2 = 20

function onCreate()
	makeLuaSprite('sky', 'background/tortured/sky', -1250, -780)
	addLuaSprite('sky', false)
	setLuaSpriteScrollFactor('sky', 1, 1)
	
	makeLuaSprite('backfloor', 'background/tortured/backfloor', -1250, -840)
	addLuaSprite('backfloor', false)
	setLuaSpriteScrollFactor('backfloor', 1, 1)

	makeLuaSprite('mountains', 'background/tortured/mountains', -1250, -700)
	addLuaSprite('mountains', false)
	setLuaSpriteScrollFactor('mountains', 1, 1)

	makeLuaSprite('floor', 'background/tortured/floor', -1250, -840)
	addLuaSprite('floor', false)
	setLuaSpriteScrollFactor('floor', 1, 1)
	
	-- THUNDER
	makeLuaSprite('thunder1', 'background/tortured/thunder/thunder1', -1250, -840)
	addLuaSprite('thunder1', false)
	setLuaSpriteScrollFactor('thunder1', 1, 1)
	
	makeLuaSprite('thunder2', 'background/tortured/thunder/thunder2', -1250, -840)
	addLuaSprite('thunder2', false)
	setLuaSpriteScrollFactor('thunder2', 1, 1)
	
	makeLuaSprite('thunder3', 'background/tortured/thunder/thunder3', -1250, -840)
	addLuaSprite('thunder3', false)
	setLuaSpriteScrollFactor('thunder3', 1, 1)
	
	makeLuaSprite('thunder4', 'background/tortured/thunder/thunder4', -1250, -840)
	addLuaSprite('thunder4', false)
	setLuaSpriteScrollFactor('thunder4', 1, 1)
	
	-- visiblity
	setProperty('thunder1.visible', false);	
	setProperty('thunder2.visible', false);	
	setProperty('thunder3.visible', false);	
	setProperty('thunder4.visible', false);	
end

function onUpdate(elapsed)
	if followchars == true then
		if mustHitSection == false then
		  if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
			triggerEvent('Camera Follow Pos',xx-ofs,yy)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
			triggerEvent('Camera Follow Pos',xx+ofs,yy)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singUP' then
			triggerEvent('Camera Follow Pos',xx,yy-ofs)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
			triggerEvent('Camera Follow Pos',xx,yy+ofs)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
			triggerEvent('Camera Follow Pos',xx-ofs,yy)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
			triggerEvent('Camera Follow Pos',xx+ofs,yy)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
			triggerEvent('Camera Follow Pos',xx,yy-ofs)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
			triggerEvent('Camera Follow Pos',xx,yy+ofs)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
			triggerEvent('Camera Follow Pos',xx,yy)
		  end
		  if getProperty('dad.animation.curAnim.name') == 'idle' then
			triggerEvent('Camera Follow Pos',xx,yy)
		  end
		else
		  if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
			triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
			triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
			triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
			triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
			triggerEvent('Camera Follow Pos',xx2,yy2)
		  end
		  if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
			triggerEvent('Camera Follow Pos',xx2,yy2)
		  end
		end
	else
		triggerEvent('Camera Follow Pos','','')
	end
end