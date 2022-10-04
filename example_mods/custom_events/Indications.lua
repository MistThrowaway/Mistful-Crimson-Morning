function onEvent(name, value1, value2)
   if name == 'db tutorial' then
		makeLuaSprite('image2', value1, 0, 0);
		addLuaSprite('image2', true);
		doTweenAlpha('hello2','image2',0,0.0000001,'QuadInOut')
		setObjectCamera('image2', 'hud');
		runTimer('wait2', 0.1);
    
    end
end 
    
function onTimerCompleted(tag, loops, loopsleft)
    if tag == 'wait2' then
        doTweenAlpha('byelol','image2',1,0.7,'QuadInOut')
        runTimer('ggez', 2.2)
    end
    if tag == 'ggez' then
        doTweenAlpha('byebye2','image2',0,1,'QuadInOut')
    end
 end

function onTweenCompleted(tag)
    if tag == 'byebye2' then
        removeLuaSprite('image2', true)
    end
end
