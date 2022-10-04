function onEvent(name)
	if name == "shoot" then
		removeLuaSprite('warn', true)
		cancelTimer('warn')
		makeLuaSprite('warn', 'space', 0, 150)
		screenCenter('warn', 'x')
		addLuaSprite('warn', true)
		setObjectCamera('warn', 'hud')
		setObjectOrder('warn', 2)
		playSound('gunload');
		runTimer('warn', 2)
		function onTimerCompleted(name)
			if name == 'warn' then
					triggerEvent('Play Animation', 'shoot', 'phase2alt')
					triggerEvent('Play Animation', 'hurt', 'boyfriend')
					setProperty('health', getProperty('health') - 100000000)
					playSound('gunshoot');
					removeLuaSprite('warn', true)
					triggerEvent('Screen Shake', '0.25, 0.012', '0.1, 0.008')
				end
			end
		end
	end

function onUpdate()
	if keyReleased('space') and getProperty('warn.x') ~= 'warn.x' then
		removeLuaSprite('warn',true);
		cancelTimer('warn');
		triggerEvent('Play Animation', 'shoot', 'phase2alt')
		triggerEvent('Play Animation', 'dodge', 'boyfriend')
		triggerEvent('Screen Shake', '0.25, 0.012', '0.1, 0.008')
		playSound('gunshoot');
	end
end