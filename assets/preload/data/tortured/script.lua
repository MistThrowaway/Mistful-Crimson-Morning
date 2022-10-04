function onStepHit()
	if curStep == 32 or curStep == 208 or curStep == 291 then
	playSound('thunder', 2)
	setProperty('thunder1.visible', true);	
    end
	if curStep == 33 or curStep == 209 or curStep == 292 then
	setProperty('thunder1.visible', false);	
    end
	if curStep == 37 or curStep == 135 then
	playSound('thunder', 2)
	setProperty('thunder2.visible', true);	
    end
	if curStep == 38 or curStep == 136 then
	setProperty('thunder2.visible', false);	
    end
	if curStep == 96 or curStep == 278 or curStep == 368 then
	playSound('thunder', 2)
	setProperty('thunder3.visible', true);	
    end
	if curStep == 97 or curStep == 279 or curStep == 369 then
	setProperty('thunder3.visible', false);	
    end
	if curStep == 128 or curStep == 217 then
	playSound('thunder', 2)
	setProperty('thunder4.visible', true);	
    end
	if curStep == 129 or curStep == 218 then
	setProperty('thunder4.visible', false);	
    end
end