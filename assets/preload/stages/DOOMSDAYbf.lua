function onCreate()
	-- background shit
	makeLuaSprite('room', 'background/bedroom/room', -700,-400);
	addLuaSprite('room', false);

	makeLuaSprite('suicide', 'background/bedroom/suicide', -700,-400);
	addLuaSprite('suicide', false);
	setProperty('suicide.visible', false);	
	
	-- stage
	makeLuaSprite('stagefb', 'background/bedroom/doomsdayfb/stagefb', -890, -200)
	addLuaSprite('stagefb', false)
	setLuaSpriteScrollFactor('stagefb', 1, 1)
	setProperty('stagefb.visible', false);	

	makeLuaSprite('curtainstage', 'background/bedroom/doomsdayfb/curtainstage', -890, -450)
	addLuaSprite('curtainstage', false)
	setLuaSpriteScrollFactor('curtainstage', 1, 1)
	scaleObject('curtainstage', 1, 1.1)
	setProperty('curtainstage.visible', false);	

	makeLuaSprite('bbcurtian', 'background/bedroom/doomsdayfb/bbcurtian', -890, -450)
	addLuaSprite('bbcurtian', false)
	setLuaSpriteScrollFactor('bbcurtian', 1, 1)
	scaleObject('bbcurtian', 1, 1.1)
	setProperty('bbcurtian.visible', false);	

	makeLuaSprite('curtianbig', 'background/bedroom/doomsdayfb/curtianbig', -890, -450)
	addLuaSprite('curtianbig', false)
	setLuaSpriteScrollFactor('curtianbig', 1, 1)
	scaleObject('curtianbig', 1, 1.1)
	setProperty('curtianbig.visible', false);	

	makeLuaSprite('FUCKINGCHAIR', 'background/bedroom/doomsdayfb/FUCKINGCHAIR', -1390, -500)
	addLuaSprite('FUCKINGCHAIR', true)
	setLuaSpriteScrollFactor('FUCKINGCHAIR', 1, 1)
	setProperty('FUCKINGCHAIR.visible', false);
	scaleObject('FUCKINGCHAIR', 1.3, 1.3)

	makeLuaSprite('people', 'background/bedroom/doomsdayfb/people', -890, -300)
	addLuaSprite('people', true)
	setLuaSpriteScrollFactor('people', 1, 1)
	setProperty('people.visible', false);		
	
	-- fire
	makeLuaSprite('wall', 'background/bedroom/bedroomf/wall', -700,-400);
	addLuaSprite('wall', false);
	setProperty('wall.visible', false);	
	
	makeLuaSprite('firewall', 'background/bedroom/bedroomf/firewall', -700,-400);
	addLuaSprite('firewall', false);
	setProperty('firewall.visible', false);	

	makeLuaSprite('floor', 'background/bedroom/bedroomf/floor', -700,-400);
	addLuaSprite('floor',false);
	setProperty('floor.visible', false);		
	
	makeLuaSprite('firefront', 'background/bedroom/bedroomf/firefront', -700,-400);
	addLuaSprite('firefront', true);
	setProperty('firefront.visible', false);	

    makeLuaSprite('shading', 'background/bedroom/bedroomf/shading', -700,-400);
	addLuaSprite('shading', true);
	setProperty('shading.visible', false);	
	
	-- blood
    makeLuaSprite('blood', 'background/bedroom/blood', 0, 0);
	addLuaSprite('blood', true);
	setProperty('blood.visible', false);	
	setObjectCamera('blood', 'hud');
	
	-- stage 2 !
	makeAnimatedLuaSprite('BLOODYTHING','background/bedroom/doomsdayfb2/DoomsdayBack', -890, -400)
	scaleLuaSprite('BLOODYTHING', 1, 1);
	addAnimationByPrefix('BLOODYTHING','Tearflow', 'Tearflow', 24, true)
	addLuaSprite('BLOODYTHING', false);
	setProperty('BLOODYTHING.visible', false);
	
	makeLuaSprite('redlight', 'background/bedroom/doomsdayfb2/redlight', -890, -400)
	addLuaSprite('redlight', false)
	setLuaSpriteScrollFactor('redlight', 1, 1)
	setProperty('redlight.visible', false);	
	
	makeLuaSprite('stagefx', 'background/bedroom/doomsdayfb2/stage', -890, -200)
	addLuaSprite('stagefx', false)
	setLuaSpriteScrollFactor('stagefx', 1, 1)
	setProperty('stagefx.visible', false);	

	makeLuaSprite('curtainstageX', 'background/bedroom/doomsdayfb2/backcurtains', -890, -450)
	addLuaSprite('curtainstageX', false)
	setLuaSpriteScrollFactor('curtainstageX', 1, 1)
	scaleObject('curtainstageX', 1, 1.1)
	setProperty('curtainstageX.visible', false);	

	makeLuaSprite('Xcurtian', 'background/bedroom/doomsdayfb2/frontcurtains', -890, -450)
	addLuaSprite('Xcurtian', false)
	setLuaSpriteScrollFactor('Xcurtian', 1, 1)
	scaleObject('Xcurtian', 1, 1.1)
	setProperty('Xcurtian.visible', false);	

	makeLuaSprite('pieces', 'background/bedroom/doomsdayfb2/pieces', -890, -450)
	addLuaSprite('pieces', false)
	setLuaSpriteScrollFactor('pieces', 1, 1)
	scaleObject('pieces', 1, 1.1)
	setProperty('pieces.visible', false);	

	makeLuaSprite('FUCKINGFUCK', 'background/bedroom/doomsdayfb2/BROKENCHAIR', -1390, -500)
	addLuaSprite('FUCKINGFUCK', true)
	setLuaSpriteScrollFactor('FUCKINGFUCK', 1, 1)
	setProperty('FUCKINGFUCK.visible', false);
	scaleObject('FUCKINGFUCK', 1.3, 1.3)

	makeAnimatedLuaSprite('debris','background/bedroom/doomsdayfb2/debris', -890, -400)
	scaleLuaSprite('debris', 1, 1);
	addAnimationByPrefix('debris','fallingdebris', 'fallingdebris', 24, true)
	addLuaSprite('debris', true);
	setProperty('debris.visible', false);
	scaleObject('debris', 1.3, 1.3)
	
	-- red mist
	makeLuaSprite('skyx', 'background/bedroom/redmist/sky', -700,-400);
	addLuaSprite('skyx', false);
	setProperty('skyx.visible', false);	

	makeLuaSprite('lighteffect', 'background/bedroom/redmist/lighteffect', -700,-400);
	addLuaSprite('lighteffect', false);
	setProperty('lighteffect.visible', false);			
	
	makeLuaSprite('roomx', 'background/bedroom/redmist/room', -700,-400);
	addLuaSprite('roomx', false);
	setProperty('roomx.visible', false);	
	
	makeLuaSprite('shadingx', 'background/bedroom/redmist/shading', -700,-400);
	addLuaSprite('shadingx', false);
	setProperty('shadingx.visible', false);	
	
end