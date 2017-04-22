local _ssid = "wifi-12-private";
local _pass = "9263777101";

local LED_TMR_ID = 1;
local WEB_TMR_ID = 2;

local PIN_SW  = 6;  -- GPIO_01
local PIN_TOUCH = 5; -- GPIO_14
local PIN_LED = 4;

local DEBUG = true;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_LED_BLINK = 'led-blink' .. ext;
local LC_FIFI_CONN = 'wifi-connect' .. ext;
local LC_WEB_SRV   = 'web-srv' .. ext;
local LC_TCH_SENS  = 'touch-sensor' .. ext;
local LC_WEB_SRV_FS= 'web-srv-fs' .. ext;

local led_blink = dofile(LC_LED_BLINK);
led_blink.start(PIN_LED, LED_TMR_ID);

local touch_1 = dofile(LC_TCH_SENS);
touch_1.start(PIN_TOUCH, PIN_SW);

local wifi = dofile(LC_FIFI_CONN);
local web_srv = dofile(LC_WEB_SRV);
local web_srv_fs = dofile(LC_WEB_SRV_FS);

wifi.start(_ssid, _pass, function()
    web_srv_fs.start(WEB_TMR_ID)
    web_srv.start(8080, PIN_SW, web_srv_fs);
    print("wifi connected");
end);
