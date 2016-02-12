light_pin=2
sensor_pin = 3
relay_pin=4
--smart_link_pin=3
--
--gpio.mode(smart_link_pin, gpio.INT)
gpio.mode(sensor_pin,  gpio.INPUT)
gpio.mode(light_pin,  gpio.OUTPUT)
gpio.mode(relay_pin,  gpio.OUTPUT)



--WIFI_CONFIG="wifi.cfg"
l = file.list();
for k,v in pairs(l) do
    print("name:"..k..", size:"..v)
end
--success = file.open(WIFI_CONFIG,"r")
--if(success) then
--    ssid = file.readline()
--    print("SSID:", ssid)
--    passwd = file.readline()
--    print("PASSWORD:", passwd)
--    file.close()
--    wifi.setmode(wifi.STATION)
--    if(ssid and passwd) then
--        wifi.sta.config(ssid,passwd)
--        print("myIP:",wifi.sta.getip())
--    end
--end

wifi.setmode(wifi.STATION)
wifi.sta.config("RippleHome",18629660612)
print(wifi.sta.getip())



--function write_config_to_file(ssid,passwd)
--    file.remove(WIFI_CONFIG)
--    file.open(WIFI_CONFIG,"a+")
--    file.writeline(ssid)
--    file.writeline(passwd)
--    file.close()
--end
--
--function callback(ssid, password)
--    print("get wifi config");
--    blink(4)
--    print(string.format("Success. SSID:%s ; PASSWORD:%s", ssid, password));
--    write_config_to_file(ssid,password)
--end
--
--function smart()
--    print("start smarting")
--    wifi.startsmart(0 ,callback)
--end

--gpio.trig(smart_link_pin,"up",smart)
--print("get config:", wifi.sta.getconfig())
--i = 0
--repeat
--      tmr.delay(3000000)
--      i= i+1
--      print("try connecting.: current status", wifi.sta.status())
--      wifi.sta.connect()
--until (wifi.sta.status()==5) or (i==50)
--print(wifi.sta.status(),wifi.sta.getip())
--wifi.sta.connect()

-- Configure the ESP as a station (client)


-- Your Wifi connection data

local SSID = "RippleHome"

local SSID_PASSWORD = "18629660612"

function wait_for_wifi_conn(cb)
    tmr.alarm (1, 1000, 1, function()
        if wifi.sta.getip() == nil then
           print ("-- Waiting for Wifi connection")
        else
           tmr.stop(1)
           print ("-- ESP8266 mode is: " .. wifi.getmode( ))
           print ("-- MAC:  " .. wifi.ap.getmac( ))
           print ("-- IP:   " .. wifi.sta.getip( ))
           print ("-- CHIP: " .. node.chipid())
           tmr.alarm(2, 3000, 0, function()
              cb()
          end)
        end
    end)
end

-- Your Wifi connection data
local SSID = "RippleHome"
local SSID_PASSWORD = "18629660612"
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, SSID_PASSWORD)
wifi.sta.autoconnect(1)
print("waitining on wifi")

-- Hang out until we get a wifi connection before the httpd server is started
function run()
    dofile("mqtt.lua")
end

wait_for_wifi_conn(run)


