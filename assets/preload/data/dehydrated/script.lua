function onCreate()
	makeAnimatedLuaSprite('spongedie','background/dehydrated/COMEHERE/DrySpongeDeath', getCharacterX('dad') - 580, getCharacterY('dad') - 240);
	addAnimationByPrefix('spongedie', 'death', ' die', 60, false);
	addLuaSprite('spongedie', false);
	setProperty('spongedie.visible', false)

	makeAnimatedLuaSprite('spongebottom', 'background/dehydrated/COMEHERE/DrySpongeBottom', getCharacterX('dad') - 580, getCharacterY('dad') - 240);
	addAnimationByPrefix('spongebottom', 'idle', ' idle' ,60, true);
	addAnimationByPrefix('spongebottom', 'down', ' down' ,60, false);
	addAnimationByPrefix('spongebottom', 'up', ' up' ,60, false);
	addAnimationByPrefix('spongebottom', 'left', ' left' ,60, false);
	addAnimationByPrefix('spongebottom', 'right', ' right' ,60, false);
	objectPlayAnimation('spongebottom', 'idle', false);
	addLuaSprite('spongebottom', false);
	setProperty('spongebottom.visible', false);
	addCharacterToList('dry_chase', '1');
end

function onUpdate(elapsed)
	if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
		objectPlayAnimation('spongebottom', 'left', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
		objectPlayAnimation('spongebottom', 'right', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singUP' then
		objectPlayAnimation('spongebottom', 'up', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
		objectPlayAnimation('spongebottom', 'down', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
		objectPlayAnimation('spongebottom', 'left', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
		objectPlayAnimation('spongebottom', 'right', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
		objectPlayAnimation('spongebottom', 'up', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
		objectPlayAnimation('spongebottom', 'down', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
		objectPlayAnimation('spongebottom', 'idle', false);
	end
	if getProperty('dad.animation.curAnim.name') == 'idle' then
		objectPlayAnimation('spongebottom', 'idle', false);
	end
end

function onStepHit()
	if curStep == 544 then
		triggerEvent('Change Character', '1', 'dry_chase')
		setProperty('backroundrun.visible', true)
		objectPlayAnimation('backroundrun', 'backroundrun idle')
		setProperty('bg.visible', false)
		setProperty('spongebottom.visible', true)
	end
	if curStep == 2096 then
		setProperty('dadGroup.visible', false)
		setProperty('spongebottom.visible', false)
		setProperty('spongedie.visible', true)
		objectPlayAnimation('spongedie', 'death')
	end
end