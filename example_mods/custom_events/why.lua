local work = false

function onEvent(n,v1,v2)
	if n == 'why' then
		work=true
	end
end

function onUpdate(elapsed)
	if work == true then
			for i=0,4,1 do
			setPropertyFromGroup('opponentStrums', i, 'visible', false)
		end
		for i = 0, getProperty('unspawnNotes.length')-1 do
			if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then	
				setPropertyFromGroup('unspawnNotes', i, 'visible', false); --Change texture
				end
			end
				songPos = getSongPosition()
				local currentBeat = (songPos/1000)
	noteTweenY('player1', 4, defaultPlayerStrumY3 - 600*math.sin((currentBeat+8*0.1)*math.pi), 3)
	noteTweenY('player2', 5, defaultPlayerStrumY1 + 300*math.sin((currentBeat+8*0.1)*math.pi), 3)
	noteTweenY('player3', 6, defaultPlayerStrumY0 - 600*math.sin((currentBeat+8*0.1)*math.pi), 3)
	noteTweenY('player4', 7, defaultPlayerStrumY2 + 300*math.sin((currentBeat+8*0.1)*math.pi), 3)

        noteTweenX('playerx1', 4, defaultPlayerStrumX0 - 300+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	noteTweenX('playerx2', 5, defaultPlayerStrumX1 + -300+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	noteTweenX('playerx3', 6, defaultPlayerStrumX2 - 300+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	noteTweenX('playerx4', 7, defaultPlayerStrumX3 + -300+math.sin((currentBeat+8*0.1)*math.pi), 0.2)

	noteTweenX('opponentx1', 0, defaultOpponentStrumX0 - -341+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	noteTweenX('opponentx2', 1, defaultOpponentStrumX1 + 341+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	noteTweenX('opponentx3', 2, defaultOpponentStrumX2 - -341+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	noteTweenX('opponentx4', 3, defaultOpponentStrumX3 + 341+math.sin((currentBeat+8*0.1)*math.pi), 0.2)
	end
end

		 		