HOST = "192.168.199.10"
PORT = "1883"
TARGET_TEMP=26.0

client = mqtt.Client(node.chipid(), 30000)

function blink(n)
    for i=n, 1, -1
    do 
      gpio.write(light_pin,gpio.HIGH);
      tmr.delay(500000)
      gpio.write(light_pin,gpio.LOW);
    end 
end

t = require("ds18b20")
function setup_sensor(t) 
    -- ESP-01 GPIO Mapping
    t.setup(sensor_pin)
    addrs = t.addrs()
    if (addrs ~= nil) then
      print("Total DS18B20 sensors: "..table.getn(addrs))
    end
    -- Just read temperature
    print("Temperature: "..t.read().."'C")
end
setup_sensor(t)

-- on receive message
function onMessage(conn, topic, data)
  if data ~= nil then
    print(topic..":"..data)
    if data=='off' then
        gpio.write(relay_pin,gpio.HIGH);
    else 
        blink(2)
        gpio.write(relay_pin,gpio.LOW);
    end
  end
end

function broadcast_temp()
    tmr.alarm(0, 3000, 1, function()
        client:publish("/tempeature",string.format("%.1f", t.read()),0,0, function(conn) end)
        if t.read() > TARGET_TEMP then
           client:publish("/control","off", 0, 0, function(conn) end)
        else 
           client:publish("/control","on", 0, 0, function(conn) end)
        end
    end)
end

function onConnect()
  print('connected')
  client:subscribe( "/all", 0, function() print("subscribed") end)
  client:subscribe( "/announcements", 0, function() print("subscribed") end)
  client:subscribe( "/chip/" .. node.chipid(), 0, function() print("subscribed") end)
  client:subscribe( "/ip/" .. wifi.sta.getip(), 0, function() print("subscribed") end)
  client:subscribe("/control",0, function() print("subscribe success") end)
  broadcast_temp()
end

client:connect(HOST, PORT, 0, onConnect)
client:on("message", onMessage)

