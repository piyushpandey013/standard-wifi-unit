smart_link_pin=1
light_pin=2
sensor_pin = 3
relay_pin=4

gpio.mode(smart_link_pin, gpio.INT)
gpio.mode(sensor_pin,  gpio.INPUT)
gpio.mode(light_pin,  gpio.OUTPUT)
gpio.mode(relay_pin,  gpio.OUTPUT)

l = file.list();
for k,v in pairs(l) do
    print("name:"..k..", size:"..v)
end

function run()
    dofile("mqtt.lua")
end

function wait_for_wifi_conn(ssid,passwd)
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
              run()
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

function smart()
    wifi.startsmart(0 ,wait_for_wifi_conn)
end

gpio.trig(smart_link_pin,"up",smart)
wait_for_wifi_conn(run)


