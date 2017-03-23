local _ssid = "wifi-12-private";
local _pass = "9263777101";
local _addr = "http://192.168.1.92:8080/toggle"

local LED_TMR_ID = 1;
local PIN_SW  = 7;
local PIN_LED = 4;

local DEBUG = true;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_LED_BLINK = 'led-blink' .. ext;
local LC_FIFI_CONN = 'wifi-connect' .. ext;
local LC_TOUCH     = 'touch' .. ext;
local LC_RMT_TOGGL = "rmt-toggle" .. ext;

local led_blink = dofile(LC_LED_BLINK);
led_blink.start(PIN_LED, LED_TMR_ID);

local wifi   = dofile(LC_FIFI_CONN);
local touch  = dofile(LC_TOUCH);
local toggle = dofile(LC_RMT_TOGGL);

wifi.start(_ssid, _pass, 
    function()
        touch.start(PIN_SW, 
            function(level, time) 
                toggle.toggle(_addr);
            end
        );
        print("wifi connected");
    end
);
