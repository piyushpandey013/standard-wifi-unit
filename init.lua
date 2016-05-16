files = file.list()
for k,v in pairs(files) do
    print("name:"..k..", size:"..v)
end

light_pin = 1
gpio.mode(light_pin,  gpio.OUTPUT)
gpio.write(light_pin, gpio.LOW)
function run()
    dofile("mqtt.lua")
end

ssid, password, bssid_set, bssid = wifi.sta.getconfig()
function print_config()
    print("\nCurrent Station configuration:\nSSID : "..ssid
    .."\nPassword : "..password
    .."\nBSSID_set : "..bssid_set
    .."\nBSSID: "..bssid.."\n")
end
wifi.setmode(wifi.STATION)
if(ssid ~= '') then
    wifi.sta.autoconnect(1)
    tmr.alarm(1,2000, 1, function() 
      if wifi.sta.getip()==nil then 
         print(" Wait for IP --> "..wifi.sta.status()) 
      else 
         print("New IP address is "..wifi.sta.getip()) 
         tmr.stop(1) 
         print('load mqtt')
            run()
        end 
    end)
else    
    wifi.startsmart(0, function() 
     print("Auto config success!")
     print_config()
     run()
    end)
end
