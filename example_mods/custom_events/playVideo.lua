function onEvent(name, value1, value2)
     if name == 'playVideo' then
          startVideo(value1, value2)
          return Function_Stop
     end
     return Function_Continue
end