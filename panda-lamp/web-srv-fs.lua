local M = {};

local TMR_INTERVAL = 10;
local contentTypes = {
    ["css"] = "text/css", 
    ["tml"] = "text/html", 
    [".js"] = "application/javascript" 
}

local filesList = {};

local jobId = 0;
local jobs = {};

M.start = function(TMR_ID)    
    l = file.list();
    for name, size in pairs(l) do
        local ext = string.sub(name, -3);
        if (ext ~= "lua") and (ext ~= ".lc") then
            print("name:"..name..", size:"..size);
            filesList[name] = size;
        end
    end 

    tmr.alarm(TMR_ID, TMR_INTERVAL, tmr.ALARM_AUTO, function() 
        for id, job in pairs(jobs) do
            --print(id, job)
            
            if (job.ready) then
                local ln = job.fileHandle:read();
                
                if (ln == nil) then
                    job.fileHandle:close()
                    fn = nil
                    --job.socket:close()
                    jobs[id] = nil
                else
                    job.ready = false;   
                    job.send(ln, function()
                        job.ready = true
                    end)
                end             
            end
        end
    end);   
    
    print("Static web server started");
end

M.exists = function(name)
    for fileName, size in pairs(filesList) do 
        if ("/" .. fileName == name) then
            return true;
        end
    end
    return false;
end

local sendHeaders = function(fileName, fileSize, send)
    send("HTTP/1.1 200 OK\r\n");
    send("Content-type: "..contentTypes[string.sub(fileName, -3)].."; charset=UTF-8\r\n");
    send("Content-Length:"..fileSize.."\r\n");
    send("Connection: keep-alive\r\n\r\n");
end

M.serve = function(path, socket, callback)
    local fileName = string.sub(path, 2);
    local fileSize = 0;
    for fn, size in pairs(filesList) do 
        if (fileName == fn) then
            fileSize = size;
        end
    end

    local ln = "";
    local fn = file.open(fileName);
    if fn then
        sendHeaders(fileName, fileSize, callback)
        
        local job = {
            send = callback,
            fileHandle = fn,
            socket = socket,
            ready = true
        };
        
        jobs[jobId] = job;
        jobId = jobId + 1;
    end
end

return M;
