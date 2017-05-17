local _ssid = "wifi-12-private";
local _pass = "9263777101";
local _addr = "http://192.168.1.92:80/toggle"

local LED_TMR_ID = 1;
local CDI_TMR_ID = 2;

local PIN_SW  = 2; -- GPIO_4
--local PIN_DHT = 7; -- GPIO13 
local PIN_LED = 4;  
local PIN_CDI = 1; -- GPIO_5
local PIN_SDA = 6; -- GPIO12
local PIN_SCL = 5; -- GPIO14

local DEBUG = false;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_LED_BLINK = 'led-blink' .. ext;
local LC_PPM_RUN   = 'ppm-run' .. ext;
local LC_FIFI_CONN = 'wifi-connect' .. ext;
local LC_WEB_SRV   = 'web-srv' .. ext;
local LC_TOUCH     = 'touch' .. ext;
local LC_RMT_TOGGL = "rmt-toggle" .. ext;

if (DEBUG) then
    local led_blink = dofile(LC_LED_BLINK);
    led_blink.start(PIN_LED, LED_TMR_ID);
end 

local ppm = 0;
local ppm_run = dofile(LC_PPM_RUN);
tmr.alarm(CDI_TMR_ID, 5000, tmr.ALARM_AUTO, function()
    ppm_run.start(PIN_CDI, function(ppm_value)
        --if DEBUG then print("ppm  = ", ppm); end
        ppm = ppm_value;
    end);
end)

local wifi = dofile(LC_FIFI_CONN);
local touch  = dofile(LC_TOUCH);
local toggle = dofile(LC_RMT_TOGGL);
local web_srv = dofile(LC_WEB_SRV);

wifi.start(_ssid, _pass, 
    function()
        touch.start(PIN_SW, 
            function(level, time) 
                toggle.toggle(_addr);
            end
        );
        web_srv.start(8080, PIN_SDA, PIN_SCL,
            function() 
                return ppm;
            end
        );
        print("wifi connected");
    end
);

