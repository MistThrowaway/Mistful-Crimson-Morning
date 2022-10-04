function onCreate()
	triggerEvent('Goodbye Hud', '0', '0.1')
end

function onStepHit()
	if curStep > 55 and curStep < 63 then
	triggerEvent('Screen Shake', '0.25, 0.012', '0.1, 0.008')
	end
end