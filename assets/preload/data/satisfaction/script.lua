local xx2 = 420;
local yy2 = 450;
local xx = 850;
local yy = 350;
local ofs = 50;
local ofs2 = 50;
local followchars = true;
local del = 0;
local del2 = 0;
local fuckme = 0.7;
local fuckme2 = 0.7;

function onCreatePost()
        setPropertyFromGroup('playerStrums', 0, 'x', defaultOpponentStrumX0)
        setPropertyFromGroup('playerStrums', 1, 'x', defaultOpponentStrumX1)
        setPropertyFromGroup('playerStrums', 2, 'x', defaultOpponentStrumX2)
        setPropertyFromGroup('playerStrums', 3, 'x', defaultOpponentStrumX3 )
        setPropertyFromGroup('playerStrums', 4, 'x', defaultOpponentStrumX4 )

        setPropertyFromGroup('opponentStrums', 0, 'x', defaultPlayerStrumX0 + 40)
        setPropertyFromGroup('opponentStrums', 1, 'x', defaultPlayerStrumX1 + 40)
        setPropertyFromGroup('opponentStrums', 2, 'x', defaultPlayerStrumX2 + 40)
        setPropertyFromGroup('opponentStrums', 3, 'x', defaultPlayerStrumX2 + 160)
        setPropertyFromGroup('opponentStrums', 4, 'x', defaultPlayerStrumX3 + 40)	
end

function onStepHit()
	if curStep == 880 then
        triggerEvent('Play Animation', 'talk', 'dad')
	end
	if curStep == 149 then
	setProperty('squidward.visible', false);
	setProperty('squidward2.visible', true);
    luaSpritePlayAnimation('squidward2', 'idle')
	end
end

function onBeatHit()
if curBeat == 32 then 
	setProperty('squidward.visible', true);
    luaSpritePlayAnimation('squidward', 'hey')
end

if curBeat == 260 then
	xx = 600;
	yy = 350;
	xx2 = 600;
	yy2 = 350;
	ofs2 = 0;
	ofs = 10;
	fuckme = 0.6;
	fuckme2 = 0.58;
	setProperty('standoff.visible', true);	
	setProperty('light.visible', true);
	setProperty('kitchen.visible', false);	
	setProperty('bluelight.visible', false);
	setProperty('yellowlight.visible', false);		
	setProperty('krabs.visible', false);	
	setProperty('squidward.visible', false);	
	setProperty('boyfriendGroup.visible', false);	
	end
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
			setProperty('defaultCamZoom',fuckme)
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'talk' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
        else
			setProperty('defaultCamZoom',fuckme2)
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
	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
    
end