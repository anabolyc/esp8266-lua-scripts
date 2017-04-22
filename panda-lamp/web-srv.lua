local M = {};

local started = false;

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
    gpio.write(PIN_SW, gpio.LOW);
end

local off = function(PIN_SW)
    gpio.write(PIN_SW, gpio.HIGH);
end

local toggle = function(PIN_SW)
    value = gpio.read(PIN_SW);
    if (value == gpio.HIGH) then
        print(PIN_SW, "::state -> LOW"); 
        gpio.write(PIN_SW, gpio.LOW);    
        return true;
    else
        print(PIN_SW, "::state -> HIGH"); 
        gpio.write(PIN_SW, gpio.HIGH);
        return false;
    end
end

local getState = function(PIN_SW)
    value = gpio.read(PIN_SW);
    print(PIN_SW, "::state <- ", value == gpio.HIGH and "HIGH" or "LOW" ); 
    return value == gpio.LOW ;
end

M.start = function(_port, PIN_SW, fs_srv) 

    if started then
        print("Warning: server already started, exiting...");
        return;
    end

    gpio.mode(PIN_SW, gpio.OUTPUT);
    off(PIN_SW);
    
    print("Listenting on ", _port);
    srv = net.createServer(net.TCP);
    srv:listen(_port, function(conn)
        
        conn:on("receive", function(sck, request)
            --print(request);
            local _, __, method, path = string.find(request, "([A-Z]+) (.-) HTTP");
            if (path == "/") then path = "/index.html" end
            
            print(method, path, "fs = ", fs_srv.exists(path));
            
            local buf = "";
            if (path == "/on") and (method == "POST") then
                on(PIN_SW);
                buf = OK();
                
            elseif (path == "/off") and (method == "POST") then
                off(PIN_SW);
                buf = OK();
                
            elseif (path == "/toggle") and (method == "POST") then
                local state = toggle(PIN_SW);
                buf = OK("{\"state\":"..(state and "true" or "false").."}");

            elseif (path == "/state") and (method == "GET") then
                local state = getState(PIN_SW);
                buf = OK("{\"state\":"..(state and "true" or "false").."}");
            elseif (fs_srv.exists(path)) and (method == "GET") then
                fs_srv.serve(path, sck, function(body, next) 
                    conn:send(body, next);
                end);
                buf = "";
            else
                buf = FAIL();
            end

            if (buf ~= "") then
                conn:send(buf, function()
                    print("conn:close");
                    sck:close();
                    collectgarbage();
                end);
            end
        end)
    end);
    started = true;
    print("API web server started");
end

return M;
