local _ssid = "wifi-12-private";
local _pass = "9263777101";

local LED_TMR_ID = 1;
local PIN_LED = 4;  

local DEBUG = true;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_LED_BLINK = 'led-blink' .. ext;
local LC_FIFI_CONN = 'wifi-connect' .. ext;

local led_blink = dofile(LC_LED_BLINK);
led_blink.start(PIN_LED, LED_TMR_ID);

local wifi = dofile(LC_FIFI_CONN);
wifi.start(_ssid, _pass, 
    function()
        print("wifi connected");
    end
);
