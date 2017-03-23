local _ssid = "wifi-12-private";
local _pass = "9263777101";

local LED_TMR_ID   = 1;
local PIN_LED      = 4;
local PIN_TOUCH_1  = 6; -- GPIO12
local PIN_TOUCH_2  = 7; -- GPIO13
local PIN_SWITCH_1 = 5; -- GPIO14
local PIN_SWITCH_2 = 0; -- GPIO16
local WEB_SRV_PORT = 8080;

local DEBUG = false;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_LED_BLINK = 'led-blink' .. ext;
local LC_FIFI_CONN = 'wifi-connect' .. ext;
local LC_TCH_SENS  = 'touch-sensor' .. ext;
local LC_WEB_SERV  = 'web-srv' .. ext;

if DEBUG then
    local led_blink = dofile(LC_LED_BLINK);
    led_blink.start(PIN_LED, LED_TMR_ID);
end

local touch_1 = dofile(LC_TCH_SENS);
touch_1.start(PIN_TOUCH_1, PIN_SWITCH_1);

local touch_2 = dofile(LC_TCH_SENS);
touch_2.start(PIN_TOUCH_2, PIN_SWITCH_2);

local web_srv = dofile(LC_WEB_SERV);

local wifi = dofile(LC_FIFI_CONN);
wifi.start(_ssid, _pass, 
    function()
        print("wifi connected");
        web_srv.start(WEB_SRV_PORT);
    end
);

