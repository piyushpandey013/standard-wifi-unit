HOST = "m10.cloudmqtt.com"
PORT = "12948"
USER_NAME = "qegbzezg"
PASSWORD = "GaD8XPkgNZMH"

client = mqtt.Client(node.chipid(), 30000, USER_NAME, PASSWORD)

chip_id = node.chipid()
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
  if data ~= nil and topic == 'heater' then
    print(topic..":"..data)
    if data=='Off' then
        gpio.write(light_pin,gpio.LOW);
        gpio.write(relay_pin,gpio.HIGH);
    else 
        gpio.write(light_pin,gpio.HIGH);
        gpio.write(relay_pin,gpio.LOW);
    end
  end
end

function broadcast_temp()
    response = {}
    response["id"] = chip_id 
    tmr.alarm(0, 5000, 1, function()
        response["temperature"] = t.read()
        client:publish("/temperature",cjson.encode(response),0,0, function(conn) end)
    end)
end

function onConnect()
  print('connected')
  client:subscribe( "/all", 0, function() print("subscribed") end)
  client:subscribe( "/announcements", 0, function() print("subscribed") end)
  client:subscribe( "/chip/" .. chip_id, 0, function() print("subscribed") end)
  client:subscribe( "/ip/" .. wifi.sta.getip(), 0, function() print("subscribed") end)
  client:subscribe("/heater",0, function() print("subscribe success") end)
  broadcast_temp()
end

client:connect(HOST, PORT, 0, onConnect)
client:on("message", onMessage)

