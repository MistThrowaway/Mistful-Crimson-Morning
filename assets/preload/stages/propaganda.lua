local ofs = 15
local lockcam = true
local del = 0
local del2 = 0

function onCreate()
	setProperty('gfGroup.visible', false)
	makeLuaSprite('showroom', 'background/propaganda/propaganda', -1200,-400)
	addLuaSprite('showroom', false)
end

function onUpdate(elapsed)
    xx2 = getCharacterX('boyfriend') - 300
    yy2 = getCharacterY('boyfriend') + 300

    if lockcam == true then
        if mustHitSection == false then
            triggerEvent('Camera Follow Pos',xx2,yy2)
        else
            triggerEvent('Camera Follow Pos',xx2,yy2)
        end
    end
end