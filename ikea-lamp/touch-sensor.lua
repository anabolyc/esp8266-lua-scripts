local M = {};

M.start = function(PIN_TCH, PIN_SW)
    gpio.mode(PIN_TCH, gpio.INPUT);
    gpio.mode(PIN_SW , gpio.OUTPUT);

    local MIN_JUMP_TIME = 50;
    local last_val = gpio.LOW;
    local last_down = tmr.now();
    local last_up = tmr.now();
    
    gpio.trig(PIN_TCH, "both", 
        function(level, timer)
            --print(PIN_TCH, "event", " level=", level, " timer=", timer);
            if (level == gpio.HIGH) then
                --print(PIN_TCH, "HIGH", timer / 1000, (timer - last_up) / 1000 );
                last_up = timer;
            else
                --print(PIN_TCH, "LOW", timer / 1000, (timer - last_down) / 1000 );
                last_down = timer;
            end
            

            if (level == gpio.LOW and last_val == gpio.HIGH) then
                local diff = (last_down - last_up) / 1000;
                print(PIN_TCH, "SPEND: ", diff) 
                if (diff > MIN_JUMP_TIME) then
                
                    value = gpio.read(PIN_SW);
                    if (value == gpio.HIGH) then
                        print(PIN_TCH, "::", PIN_SW, " -> LOW");
                        gpio.write(PIN_SW, gpio.LOW);    
                    else
                        print(PIN_TCH, "::", PIN_SW, " -> HIGH");
                        gpio.write(PIN_SW, gpio.HIGH);
                    end
                end
            end

            last_val = level;
        end
    );
end

return M;
