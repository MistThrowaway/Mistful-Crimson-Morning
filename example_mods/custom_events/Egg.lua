local Dodged = false;
local canDodge = false;
local DodgeTime = 0;
local rings = 0

function onCreate()
    makeLuaText('rings', 'Rings: '..rings, 0, 0, 0)
    setTextSize('rings', 32)
    setTextBorder('rings', 2, '000000')
    setTextColor('rings', 'FFFFFF')
    setTextAlignment('rings', 'center')
    setTextFont('rings', 'vcr.ttf')
    addLuaText('rings')
    setObjectCamera('rings', 'other')
end

function onEvent(name, value1, value2)
    if name == "Egg" then
    DodgeTime = (value1);
	
    makeLuaSprite('egghunt', 'egg', 100, -100);
    setObjectCamera('egghunt', 'other');
    addLuaSprite('egghunt',false)
	
	canDodge = true;
	runTimer('timer', DodgeTime);
    end
end

function onUpdate()
    if canDodge == true and keyJustPressed('space') then

    rings = rings + 1;
    Dodged = true;
    removeLuaSprite('egghunt');
    canDodge = false
    end

    setTextBorder('rings', 4, '000000')
    setTextString('rings', ''..rings)
    setTextSize('rings', 70)
    setProperty('rings.x', screenWidth /1 - getProperty('rings.width') / 1)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'timer' and Dodged == false then
        removeLuaSprite('egghunt');
    end
    if tag == 'timer' and Dodged == true then
        Dodged = false
    end
end

function onStepHit()
    if curStep == 980 then
        if rings < 6 then
            setProperty('health', 0);
        end
    end
end