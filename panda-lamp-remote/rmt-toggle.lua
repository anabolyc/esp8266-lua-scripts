local M = {};

M.toggle = function(host)
    print("host: ", host);
    
    http.post(host, "", "",
        function(code, data)
            if (code < 0) then
                print("HTTP request failed")
            else
                print(code, data)
            end
        end
    );
end

return M;
