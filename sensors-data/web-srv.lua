local M = {};

local started = false;

M.start = function(_port, PIN_DHT, PIN_BMP_SDA, PIN_BMP_SCL, cdio_callback) 
    if started then
        print("Warning: server already started, exiting...");
        return;
    end
    
    local bmp_init = bme280.init(PIN_BMP_SDA, PIN_BMP_SCL);
    print ("bmp_init", bmp_init);
    
    print("Listenting on ", _port);
    srv = net.createServer(net.TCP);
    srv:listen(_port, function(conn)
        
        conn:on("receive", function(sck, request)
            --print(request);
            local _, __, method, path = string.find(request, "([A-Z]+) (.-) HTTP");
            
            print(method, path);
            
            local buf;
            if path == "/data" then
                if (method == "GET") or (method == "HEAD") then
                    buf = "HTTP/1.1 200 OK\r\n";
                    buf = buf.."Content-type: application/json\r\n";
                    buf = buf.."Connection: close\r\n\r\n";
    
                    if method == "GET" then
                        buf = buf.."{\r\n";
                        local status, temp, humi, temp_decimal, humi_decimal = dht.read(PIN_DHT)
                        local ppm = cdio_callback();
                        local pres, temp_2 = bme280.baro();
                        
                        if (status == dht.OK) then
                            --print("dht.OK: ", dht.OK);
                            if (temp_2 == nil) then
                                buf = buf..'\t"temp": "null",\r\n';
                            else
                                buf = buf..'\t"temp": "'..temp_2..'",\r\n';
                            end
                            buf = buf..'\t"humidity": "'..humi..'",\r\n';
                            if (pres == nil) then
                                buf = buf..'\t"pressure": "null",\r\n';
                            else
                                buf = buf..'\t"pressure": "'..pres..'",\r\n';
                            end
                            
                            if ppm == nil then
                                buf = buf..'\t"cdio": "null",\r\n';
                            else
                                buf = buf..'\t"cdio": "'..ppm..'",\r\n';
                            end
                            buf = buf..'\t"error": null';
                        elseif (status == dht.ERROR_CHECKSUM) then
                            --print("dht.ERROR_CHECKSUM: ", dht.ERROR_CHECKSUM);
                            buf = buf..'\t"error": "DHT Checksum error"';
                        elseif (status == dht.ERROR_TIMEOUT) then
                            --print("dht.ERROR_TIMEOUT: ", dht.ERROR_TIMEOUT);
                            buf = buf..'\t"error": "DHT Time out"';
                        end
                        buf = buf.."\r\n}\r\n";
                    end
                else
                    buf = "HTTP/1.1 405 Method Not Allowed\r\n";
                    buf = buf.."Allow:HEAD,GET\r\n";
                    buf = buf.."Connection: close\r\n\r\n";
                end
            else
                buf = "HTTP/1.1 404 Not Found\r\n";
                buf = buf.."Connection: close\r\n\r\n";
            end
            --print("request end: ", buf);
            conn:send(buf, function()
                sck:close();
                collectgarbage();
            end);
        end)
    end);
    started = true;
end

return M;
