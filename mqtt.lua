HOST = "m10.cloudmqtt.com"
PORT = "12948"
USER_NAME = "qegbzezg"
PASSWORD = "GaD8XPkgNZMH"

DRIVER_FILE="driver.lua"
SETUP_FILE="setup.lua"
RUN_FILE="run.lua"

client = mqtt.Client(node.chipid(), 30000, USER_NAME, PASSWORD)

attr_config = {}
chip_id = node.chipid()


function onConnect()
  print('connected')
  gpio.write(light_pin,gpio.HIGH)
  runExistingProgram()
  register_info = {}
  register_info["id"] = chip_id
  register_info["ip"] = wifi.sta.getip()
  register_info["mac"] = wifi.ap.getmac()
  register_info["ssid"] = ssid
  client:publish("/register",cjson.encode(register_info),0,0, function(conn) end)
  client:subscribe( "/driver/" .. chip_id, 0, function(conn) end)
  client:subscribe( "/setup/" .. chip_id, 0, function(conn) end)
  client:subscribe( "/run/" .. chip_id, 0, function(conn) end)
  client:subscribe( "/command/" .. chip_id, 0, function(conn) end)
  client:subscribe( "/savefile/" .. chip_id, 0, function(conn) end)
end

function evalString(string)
  local func = loadstring(string)
  if(func) then
    func()
  end
end            

function onMessage(conn, topic, data)
   print(topic .. "#:" .. data)
   if topic=="/driver/" .. chip_id then
     writeConfig(DRIVER_FILE, data)
   elseif topic=="/setup/" .. chip_id then
     writeConfig(SETUP_FILE, data)
     evalString(data)
   elseif topic=="/run/" .. chip_id then
     writeConfig(RUN_FILE, data)
     evalString(data)
   elseif topic=="/command/" .. chip_id then
     evalString(data)
   elseif topic=="/savefile/" .. chip_id then
     local dataJson=cjson.decode(data)
     writeConfig(dataJson["filename"], dataJson["payload"])
   else
     client:publish("/noice/" .. chip_id ,"##" .. topic .. "##" .. data ,0,0, function(conn) end)
   end        
end

function writeConfig(filename, string)
    file.open(filename, "w+")
    file.write(string)
    file.flush()
    file.close()
end

function runExistingProgram()
    if files[DRIVER_FILE] and files[SETUP_FILE] and files[RUN_FILE] then
        dofile(SETUP_FILE)
        dofile(RUN_FILE)
    end
end

client:connect(HOST, PORT, 0, onConnect)
client:on("message", onMessage)

