local xx = 420;
local yy = 550;
local xx2 = 750;
local yy2 = 550;
local ofs = 50;
local followchars = true;
local del = 0;
local del2 = 0;

function onCreate()
	makeLuaSprite('sky', 'background/island/sky', -700,-400);
	setLuaSpriteScrollFactor('sky', 0.6, 0.6)
	scaleLuaSprite('sky',2,2);

	makeLuaSprite('sun', 'background/island/sun', -700,-400);
	setLuaSpriteScrollFactor('sun', 0.7, 0.7)

	makeLuaSprite('backtrees', 'background/island/backtrees', -700,-250);
	setLuaSpriteScrollFactor('backtrees', 0.8, 0.8)

	makeLuaSprite('foretrees', 'background/island/foretrees', -700,-250);
	setLuaSpriteScrollFactor('foretrees', 0.9, 0.9)

	makeLuaSprite('ground', 'background/island/ground', -700,-250);
	
	makeLuaSprite('water', 'background/island/water', -700,-250);
	
	addLuaSprite('sky', false);
	addLuaSprite('sun', false);
	addLuaSprite('backtrees', false);
	addLuaSprite('foretrees', false);
	addLuaSprite('ground', false);
	addLuaSprite('water', false);

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
	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
    
end