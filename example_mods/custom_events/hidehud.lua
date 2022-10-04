function onEvent(name,value1)
if name == 'hidehud' then
	if value1 == '0' then
    doTweenAlpha('hud', 'camHUD', 0, 1, 'linear')
  end		
    if value1 == '1' then
    doTweenAlpha('hud', 'camHUD', 1, 1, 'linear')
end
   end 
end