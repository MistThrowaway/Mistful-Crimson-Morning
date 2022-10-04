local followchars = true
local xx = -12
local yy = -60
local xx2 = 105
local yy2 = -60
local ofs = 16
local del = 0
local del2 = 0

function onCreate()

	setProperty('gfGroup.visible', false);

	-- part 1
	makeLuaSprite('sky', 'background/served/p1/sky', -1037, -780)
	addLuaSprite('sky', false)
	setScrollFactor('sky', 0.5, 0.5);
	
	makeLuaSprite('mountains', 'background/served/p1/mountains', -1237, -680)
	addLuaSprite('mountains', false)
	setScrollFactor('mountains', 0.8, 0.8);
	
	makeLuaSprite('ground', 'background/served/p1/ground', -1437, -780)
	addLuaSprite('ground', false)
	setScrollFactor('ground', 1, 1);
	
	-- part 2
	makeLuaSprite('sky2', 'background/served/p2/sky', -1037, -480)
	addLuaSprite('sky2', false)
	setScrollFactor('sky2', 0.5, 0.5);
	
	makeLuaSprite('ground2', 'background/served/p2/ground', -1437, -780)
	addLuaSprite('ground2', false)
	setScrollFactor('ground2', 1, 1);
	
	-- platforms
	makeLuaSprite('platforms', 'background/served/platform/pillar', -1255, -85)
	addLuaSprite('platforms', false)
	setLuaSpriteScrollFactor('platforms', 1, 1)
	
	makeLuaSprite('platforms2', 'background/served/platform/pillar', -45, -85)
	addLuaSprite('platforms2', false)
	setLuaSpriteScrollFactor('platforms2', 1, 1)

	makeLuaSprite('bus', 'background/served/bus/bus', -4845, -885)
	addLuaSprite('bus', false)
	setLuaSpriteScrollFactor('bus', 1, 1)
	
	makeLuaSprite('light', 'background/served/platform/light', -1245, -1485)
	addLuaSprite('light', true)
	setLuaSpriteScrollFactor('light', 1, 1)

	-- visiblity
	setProperty('sky.visible', true);	
	setProperty('mountains.visible', true);	
	setProperty('ground.visible', true);	
	
	setProperty('sky2.visible', false);	
	setProperty('ground2.visible', false);	
	
	setProperty('platforms.visible', false);
	setProperty('platforms2.visible', false);
	setProperty('bus.visible', false);
	setProperty('light.visible', false);
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

function onStepHit()
	if curStep == 1056 then
	xx = -102
	end
	if curStep == 1072 then
	xx = -12
	end
end