local xx = 420
local yy = 350
local xx2 = 850
local yy2 = 500
local ofs = 50
local followchars = true
local del = 0
local del2 = 0

function onCreate()
	-- Phase 1
	makeLuaSprite('wall2', 'background/surgery/dark/wall', -650, -370)
	addLuaSprite('wall2', false)

	makeLuaSprite('light2', 'background/surgery/dark/light', -650, -330)
	addLuaSprite('light2', true)
	
	makeLuaSprite('wall', 'background/surgery/wall', -650, -330)
	addLuaSprite('wall', false)
	setProperty('wall.visible', false)
	
	makeLuaSprite('floor', 'background/surgery/floor', -650, -330)
	addLuaSprite('floor', false)
	setProperty('floor.visible', false)

	makeLuaSprite('table', 'background/surgery/table', -650, -330)
	addLuaSprite('table', false)
	setProperty('table.visible', false)
	
	makeLuaSprite('light', 'background/surgery/light', -650, -330)
	addLuaSprite('light', true)
	setProperty('light.visible', false)

    -- Phase 1 (Pixel)
    makeLuaSprite('pixelwall', 'background/surgery/wall-pixel', -650, -330)
    setProperty('pixelwall.antialiasing', true)
    scaleObject('pixelwall', 10.24, 9.723)
    updateHitbox('pixelwall')
    addLuaSprite('pixelwall', false)
    setProperty('pixelwall.visible', false)

    makeLuaSprite('pixelfloor', 'background/surgery/floor-pixel', -650, -330)
    setProperty('pixelfloor.antialiasing', true)
    scaleObject('pixelfloor', 10.24, 9.723)
    updateHitbox('pixelfloor')
    addLuaSprite('pixelfloor', false)
    setProperty('pixelfloor.visible', false)

    makeLuaSprite('pixeltable', 'background/surgery/table-pixel', -650, -330)
    setProperty('pixeltable.antialiasing', true)
    scaleObject('pixeltable', 10.24, 9.723)
    updateHitbox('pixeltable')
    addLuaSprite('pixeltable', false)
    setProperty('pixeltable.visible', false)

	-- Phase 2
	makeAnimatedLuaSprite('DeadHallway', 'background/surgery/phase2/DeadHallway', -700, -330)
	addAnimationByPrefix('DeadHallway', 'deadhallway', 'deadhallway', 24, true)
	addLuaSprite('DeadHallway', false)
	setProperty('DeadHallway.visible', false)
	
	makeAnimatedLuaSprite('BF_BODY', 'background/surgery/phase2/BF_BODY', 250, 200)
	addAnimationByPrefix('BF_BODY', 'BF BODY idle', 'BF BODY idle', 24, true)
	addLuaSprite('BF_BODY', false)
	setProperty('BF_BODY.visible', false)

    -- Preload characters
    addCharacterToList('SPONGECHASE', '1')
    addCharacterToList('PATRICKCHASE', '2')
    addCharacterToList('bf-head', '3')
end

function onUpdate()
	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end
    if followchars == true then
        if mustHitSection == false then
			setProperty('defaultCamZoom',0.7)
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos', xx - ofs, yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos', xx + ofs, yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos', xx, yy - ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos', xx, yy + ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos', xx - ofs, yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos', xx + ofs, yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos', xx, yy - ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos', xx, yy + ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos', xx, yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos', xx, yy)
            end
        else
            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos', xx2 - ofs, yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos', xx2 + ofs, yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos', xx2, yy2 - ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos', xx2, yy2 + ofs)
            end
			if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos', xx2, yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos', '', '')
    end
end

function onStepHit()
	if curStep == 1487 then
	    xx = 620
	    yy = 350
	    xx2 = 620
	    yy2 = 350
	    ofs = 0
	end
end
