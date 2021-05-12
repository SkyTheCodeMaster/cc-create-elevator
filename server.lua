-- CONFIG
-- Channel that communication will run on.
local talk_channel = 30000
-- Floor layout, with names.
--[[
  The format for the floors is:
  name: a custom name for the floor
  height: the height to set the piston to to reach said floor
]]
local floors = {
  {name = "ground", height = 0},
  {name = "middle", height = 5},
  {name = "top", height = 10},
}
-- Elevator height
local height = 10
--

-- Download sUtils if not present
local sUtils
if not fs.exists("sUtils.lua") then
  local h,err = http.get("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyDocs/defec5a277d6f629ab81b68f4a5b1c7d94ced5bc/src/main/misc/sUtils.lua")
  if err then error("Something went wrong whilst downloading sUtils!") end
  local content = h.readAll() h.close()
  sUtils = load(content,"=prewebquire-package","t",_ENV)()
  -- Write sUtils to a file for later
  sUtils.fwrite("sUtils.lua",content)
else
  sUtils = require("sUtils")
end
-- Download piston library (This works for gantry carriages too)
local piston = sUtils.savequire("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyDocs/defec5a277d6f629ab81b68f4a5b1c7d94ced5bc/src/main/create/piston.lua")

-- Check for the modem.
local modem = peripheral.find("modem")
if not modem then
  error("This program requires a modem to function!")
end

-- Main program
local elevator = piston.create(nil,height)

-- Possible multi elevator support?
local function moveto(lift,height)
  if lift.curHeight > height then
    local diff = lift.curHeight - height
    lift.lower(diff)
  elseif lift.curHeight < height then
    local diff = height - lift.curHeight
    lift.raise(diff)
  end
end

while true do
  local _,_,_,_,data = os.pullEvent("modem_message")
  if type(data) == "table" and data.id == os.getComputerID() then
    local sender = data.sendid
    if data.type == "move" then
      local height = data.height
      moveto(elevator,height)
    elseif data.type == "listfloors" then
      modem.transmit(talk_channel,talk_channel,{
        sendid = os.getComputerID(),
        id = sender,
        data = floors
      })
    end
  end
end
