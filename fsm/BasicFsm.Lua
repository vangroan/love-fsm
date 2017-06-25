--[[
    A Basic Finite State Machine that can hold a single active state.
]]


local BasicFsm = {}
local meta = { __index = BasicFsm }


function BasicFsm:new()
    local o = setmetatable({}, meta)
    
    o.current = nil
    o.states = {}
    
    return o
end


function BasicFsm:add_state(key, state)
    if self.states[key] ~= nil then error('Key "' .. key .. '" exists in states') end
    self.states[key] = state
end


return BasicFsm
