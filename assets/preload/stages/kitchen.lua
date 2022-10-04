function onCreate()

	setProperty('gfGroup.visible', false);
	setPropertyFromClass('GameOverSubstate', 'characterName', 'bfmc');

	-- phase 1
	makeLuaSprite('bluelight', 'background/kitchen/phase1/bluelight', -700,-400);
	addLuaSprite('bluelight', false);
	
	makeLuaSprite('kitchen', 'background/kitchen/phase1/kitchen', -700,-400);
	addLuaSprite('kitchen', false);
	
	makeLuaSprite('krabs', 'background/kitchen/phase1/krabs', 1300, -100);
	addLuaSprite('krabs', false);
	scaleLuaSprite('krabs',0.65,0.65);
	
	makeAnimatedLuaSprite('squidward','background/kitchen/phase1/mc_squidfart', 700, -380)
	scaleLuaSprite('squidward', 1.1, 1.1);
	addAnimationByPrefix('squidward','idle', 'idle', 24, true)
	addAnimationByPrefix('squidward','hey', 'hey', 24, true)
	addLuaSprite('squidward', false);
	setProperty('squidward.visible', false);
	
	makeAnimatedLuaSprite('squidward2','background/kitchen/phase1/mc_squidfart', 780, -330)
	scaleLuaSprite('squidward2', 1.1, 1.1);
	addAnimationByPrefix('squidward2','idle', 'idle', 24, true)
--	addAnimationByPrefix('squidward','hey', 'hey', 24, true)
	addLuaSprite('squidward2', false);
	setProperty('squidward2.visible', false);
	
	makeLuaSprite('yellowlight', 'background/kitchen/phase1/yellowlight', -700,-400);
	addLuaSprite('yellowlight', true);
	
	-- phase 2
	makeLuaSprite('standoff', 'background/kitchen/phase2/standoff', -700,-400);
	addLuaSprite('standoff', false);
	
	makeLuaSprite('light', 'background/kitchen/phase2/light', -700,-400);
	addLuaSprite('light', true);
	
	setProperty('standoff.visible', false);	
	setProperty('light.visible', false);	

end