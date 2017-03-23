local _ssid = "wifi-12-private";
local _pass = "9263777101";

local LED_TMR_ID = 1;
local CDI_TMR_ID = 2;

local PIN_SW  = 0; -- GPIO16
local PIN_LED = 4;

local DEBUG = false;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_LED_BLINK = 'led-blink' .. ext;
local LC_FIFI_CONN = 'wifi-connect' .. ext;
local LC_WEB_SRV   = 'web-srv' .. ext;

local led_blink = dofile(LC_LED_BLINK);
led_blink.start(PIN_LED, LED_TMR_ID);

local wifi = dofile(LC_FIFI_CONN);
local web_srv = dofile(LC_WEB_SRV);
wifi.start(_ssid, _pass, function()
    web_srv.start(8080, PIN_SW);
    print("wifi connected");
end);
