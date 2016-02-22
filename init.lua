light_pin=2
sensor_pin = 3
relay_pin=4

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

function print_config()
    ssid, password, bssid_set, bssid=wifi.sta.getconfig()
    print("\nCurrent Station configuration:\nSSID : "..ssid
    .."\nPassword : "..password
    .."\nBSSID_set : "..bssid_set
    .."\nBSSID: "..bssid.."\n")
    return ssid
end
wifi.setmode(wifi.STATION)
if(print_config() ~= '') then
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
