local M = {};

local started = false;
local state   = false;

local OK = function(content)
    local s = "HTTP/1.1 200 OK\r\n";
    if (content) then s = s.."Content-type: application/json\r\n"; end
    s = s.."Connection: close\r\n\r\n";
    if (content) then s = s..content; end
    return s;
end

local FAIL = function()
    return "HTTP/1.1 404 Not Found\r\n".."Connection: close\r\n\r\n";
end

local on = function(PIN_SW)
    print(PIN_SW, "::state -> HIGH"); 
    gpio.write(PIN_SW, gpio.HIGH);
    return true;
end

local off = function(PIN_SW)
    print(PIN_SW, "::state -> LOW");
    gpio.write(PIN_SW, gpio.LOW);
    return false;
end

local toggle = function(PIN_SW)
    value = gpio.read(PIN_SW);
    if (value == gpio.HIGH) then
        print(PIN_SW, "::state -> LOW"); 
        gpio.write(PIN_SW, gpio.LOW);    
        return false;
    else
        print(PIN_SW, "::state -> HIGH"); 
        gpio.write(PIN_SW, gpio.HIGH);
        return true;
    end
end

local getState = function(PIN_SW)
    value = gpio.read(PIN_SW);
    print(PIN_SW, "::state <- ", value == gpio.HIGH and "HIGH" or "LOW" ); 
    return value == gpio.HIGH ;
end

M.start = function(_port) 
    if started then
        print("Warning: server already started, exiting...");
        return;
    end

    print("Listenting on ", _port);
    srv = net.createServer(net.TCP);
    srv:listen(_port, function(conn)
        
        conn:on("receive", function(sck, request)
            --print(request);
            local _, __, method, command, pin = string.find(request, "([A-Z]+) [/](%w+)[/](%w+) HTTP");
            --print("method : ", method);
            --print("command: ", command);
            --print("pin    : ", pin);
            
            local buf = "";
            if (command == "on") and (method == "POST") then
                on(pin);
                buf = OK();

            elseif (command == "off") and (method == "POST") then
                off(pin);
                buf = OK();

            elseif (command == "toggle") and (method == "POST") then
                local state = toggle(pin);
                buf = OK("{\"state\":"..(state and "true" or "false").."}");

            elseif (command == "state") and (method == "GET") then
                local state = getState(pin);
                buf = OK("{\"state\":"..(state and "true" or "false").."}");

            else
                buf = FAIL();

            end

            conn:send(buf, function()
                sck:close();
                collectgarbage();
            end);
        end)
    end);
    started = true;
end

return M;
