--local _ssid = "wifi-12-private";
--local _pass = "9263777101";

local PIN_SDA = 6;
local PIN_SCL = 5;

local DEBUG = true;
local ext = (DEBUG == true and ".lua" or ".lc");
local LC_BMP_DATA   = 'bmp-data' .. ext;

local bmp_data = dofile(LC_BMP_DATA);
bmp_data.start(PIN_SDA, PIN_SCL);