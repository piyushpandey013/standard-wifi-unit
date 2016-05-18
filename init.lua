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
wifi.setmode(wifi.STATION)
function print_config()
  ssid, password , bssid_set, bssid = wifi.sta.getconfig()
  print("\nCurrent Station configuration:\nSSID : "..ssid
          .."\nPassword : "..password
          .."\nBSSID_set : "..bssid_set
          .."\nBSSID: "..bssid.."\n")
end

function smart_connect()
  wifi.startsmart(0, function() 
                    print("Auto config success!")
                    print_config()
                    run()
  end)
end

if(ssid ~= '') then
  print_config()
  wifi.sta.autoconnect(1)
  tmr.alarm(1, 5000, tmr.ALARM_SINGLE, function()
              tmr.stop(0)
              tmr.unregister(0)
              smart_connect()
  end)
  tmr.alarm(0, 500, tmr.ALARM_AUTO, function() 
              if wifi.sta.getip()==nil then 
                print(" Wait for IP --> "..wifi.sta.status()) 
              else 
                print("New IP address is "..wifi.sta.getip()) 
                tmr.stop(0) 
                tmr.unregister(0)
                print('load mqtt')
                run()
              end 
  end)
else    
  smart_connect()
end
