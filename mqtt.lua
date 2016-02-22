HOST = "192.168.199.8"
PORT = "1883"

client = mqtt.Client(node.chipid(), 30000)

attr_config = {}
chip_id = node.chipid()

function onConnect()
  print('connected')
  register_info = {}
  register_info["id"] = chip_id
  register_info["ip"] = wifi.sta.getip()
  register_info["mac"] = wifi.ap.getmac()
  register_info["ssid"] = ssid
  client:publish("/register",cjson.encode(register_info),0,0, function(conn) end)
  client:subscribe( "/config/" .. chip_id, 0, function(conn) print("/config/") end)
  client:subscribe( "/run/" .. chip_id, 0, function(conn) print("/run/") end)
  client:subscribe( "/command/" .. chip_id, 0, function(conn) print("/command/") end)
end

function eval_string(string)
  local func = loadstring(string)
  if(func) then
    func()
  end
end            

function onMessage(conn, topic, data)
    print(data)
   if topic=="/config/" .. chip_id then
      eval_string(data)
   elseif topic=="/run/" .. chip_id then
       eval_string(data)
   elseif topic=="/command/" .. chip_id then
       eval_string(data)
   else
       client:publish("/noice/" .. chip_id ,"##" .. topic .. "##" .. data ,0,0, function(conn) end)
   end        
end
client:connect(HOST, PORT, 0, onConnect)
client:on("message", onMessage)
