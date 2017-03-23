local M = {};

M.start = function(PIN_SNS, callback)

    gpio.mode(PIN_SNS, gpio.INPUT);

    gpio.trig(PIN_SNS, "down", 
        function(level, timer)
            print("[event] level = ", level == gpio.HIGH  and ">" or "<");
            callback(level, timer);
        end
    );

end

return M;
