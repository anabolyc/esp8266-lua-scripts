local M = {};

M.start = function(PIN_SDA, PIN_SCL)
    
    local init = bme280.init(PIN_SDA, PIN_SCL);
    print("init", init);

    local P, T = bme280.baro();
    local PH = P * 75 / 1000;
    print("bme280.baro()", P, PH, T);
    
end

return M;
