function onEvent(name, value1, value2)
if name == 'Health Drain' then
	function opponentNoteHit(id, noteData, noteType, isSustainNote)
		if getProperty('health') > 0.4 and getProperty('health') < (value1 / 50) then -- Health is from 0 to 2, so dividing the value by 50 allow to just turn it into percentage easly
			setProperty('health', 0.4)
		else if  getProperty('health') > 0.4 and getProperty('health') > (value1 / 50) then
			setProperty('health', getProperty('health')-(value1 / 50))
		end
		end
	end
end
end